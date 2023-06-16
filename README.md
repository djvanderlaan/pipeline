---
title: Overview pipeline - version 0.1
author: Edwin de Jonge and Jan van der Laan
date: 2023-06-16
---




## Overview of the general pipeline

The schema below shows an overview of the general pipeline. The cylinder shaped objects are the different object types. The rectangles are the processes transforming the object types. Note that in practice a transformation between two object types can consist of multiple subtransformations. The goal of this schema is to give the outline of the process. The darker green data types are the general components that can be used by the different use-cases. 

```mermaid

flowchart TD

classDef data fill:#033d59,stroke-width:1px, color:#333333;
classDef process fill:#f3a000,stroke-width:1px,color:#333333;
classDef db fill:#c8f3c3,stroke:#333333,color:#333333;
classDef db_rest fill:#98c363,stroke:#333333,color:#333333;

RawEvent[("Raw MNO\nEvent")]:::db
Event[("Event")]:::db
TimeSegment[("Time\nSegment")]:::db
RawEvent[("Raw MNO\nEvent")]:::db
Event[("Event")]:::db
TimeSegment[("Time\nSegment")]:::db
RawNetwork[("Raw MNO\nNetwork\nTopology")]:::db

Network[("Network\nTopology")]:::db_rest
AnchorDB[("Anchor")]:::db_rest
CUDDB[("Continuous User\nDiary")]:::db_rest

derive_achor["Derive Anchor"]:::process
make_cont["Make Continuous"]:::process
label["Label Time Segment"]:::process
clean_up["Import and Clean Events"]:::process
clean_network["Import and Preprocess Topology"]:::process

subgraph proces_events["Process Events"]
  RawEvent --> clean_up --> Event
  Event --> make_cont --> TimeSegment
end

TimeSegment --> derive_achor
subgraph Anchor["Determine Anchors"]
  derive_achor --> AnchorDB
end

AnchorDB --> label
TimeSegment --> label
subgraph cud["Continous User Diary"]
  label --> CUDDB
end

subgraph preprocessnetwork["Prepare Network Topology"]
  RawNetwork --> clean_network --> Network
  Network ---> make_cont
  Network --> clean_up
end



subgraph USECASE["Use Case"]

  DeviceDist[("Device Estimates")]:::db
  Census[("Census Data")]:::db
  RegionCud[("Population Estimates")]:::db
  Regions[("Geographic Regions\n(Use Case Specific)")]:::db

  aggregate["Aggregate&Select\n(Use Case Specific)"]:::process
  cells_to_region["Cells to\n Spatial Region"]:::process
  weight["Statistical Weighting"]:::process

  AnchorDB --> aggregate
  CUDDB --> aggregate
  Network ---> cells_to_region
  Regions --> cells_to_region
  aggregate --> cells_to_region
  cells_to_region --> DeviceDist

  DeviceDist --> weight
  subgraph atnsi["@NSI"]
    Census --> weight
    weight --> RegionCud
  end

end

```

### Main concepts in the general pipeline


#### `Event`
The main information (after preprocessing) obtained from the MNO. Contains discrete events. The main information in the events are the DeviceID, CellID and Time at which the event occured.

```mermaid
classDiagram
  class Event {
    +device_id: DeviceID
    +time: Time
    +cell_id: CellID
    [+location: GeoPoint[WGS84]]
    [+loc_error: Metres]
    [+type_of_event: Enum[InternetTrafic, IncomingOutgoingCall, ..., OutgoingSMS]]
  }
```

#### `Time Segment`
In a `Time Segment` one or more `Events` that are close in space and time are combined. They have a starting and end time and are in principle continuous (there are no gaps between the `Time Segments` e.g. the end time of one segment is the starting time of the next segment). However, it is possible that for certain longer time periodes without events no `Time Segment` is defined. 

The goal of the `Time Segments` is to be able to specify at each moment in time the location of a device. The location is determined by the CellID of the `Events` that are part of the `Time Segment`. 

As the `Time Segments` contain the `Events` no information is lost when converting the `Events` to `Time Segments`. 


```mermaid
classDiagram
  class TimeSegment {
    +start_time: Time
    +end_time: Time
    +events: Event[0..*]
    +type: Enum[Stop, Moving, Other, Missing, OutOfCountry]
  }
```

#### `Anchor`
An `Anchor` is a weighted combination of `Cells` that define a meaningful location for a Device. `Anchor` are, therefore, labelled. For example, the home location of a Device can be defined using a number of Cells each with their own weight. The combination of Cells with their weights can then be used to determine a more precise home location of a device. As, locations such as the home location can change in time, an `Anchor` has a start and end time in which the `Anchor` is valid.

```mermaid
classDiagram
  class Anchor {
    +start_time: Time
    +end_time: Time
    +type: Enum[Home, Work, ...]
    +cells: CellID[1..*]
    +weights: Number[1..*]
  }
```

Discussion point: How to handle devices that have a home location outside of the country? For devices that are located just outside the border and commute regularly into the country, it is possible to define the 'BorderCrossing' location by the Cells where the device usually enters and leaves the country. For other devices, and specifically foreign devices it would be practical to define a 'HomeCountry' `Anchor`. However, this is not tied to specific Cells. One solution would be to add pseudo Cells for other countries. Another solution would be to add an optional 'country' attribute to the `Anchor`. 

Discussion points: What is the minimal set of types needed for the use cases?


#### `Continuous User Diary`
Using the `Achors` the `Time Segments` are labelled. The optionally a `Time Segment` has a reference to a relevant `Anchor`. For example a `Time Segment` labelled 'AtHome' will have a reference to the 'Home' `Anchor`. As mentioned above, this can be used to determine a more precise location for a device when it is at home.

Note that not all `Time Segments` will be labelled. It is actually likely that more `Time Segments` will be unlabelled. It is also possible during the conversion from `Time Segement` to `Continuous User Diary` that multiple `Time Segments` are combined into one larger `Time Segment`. For example, in case a device first connects to Cell A and B and then to C, this might be divided into two `Time Segments`: one containing A and B and one containing just C. When the Home `Anchor` of the device is a combination of A, B and C both `Time Segments` might be combined into one `Continuous User Diary` labelled 'AtHome'.

```mermaid
classDiagram
  class TimeSegment 
  class ContinuousUserDiary {
    +label: Enum[AtHome, Working, ...]
    +anchor: Anchor[0..*]
  }
  TimeSegment <|-- ContinuousUserDiary
```

#### `Network Topology`
The `Network Topology` contain information for each Cell in the network. The most important information for the pipeline are the CellID and the raster map with the probability of connecting to the Cell given the location. In the simplest case these probabilities are one for all grid cells within the best service area and zero outside. However, better would be to take into account the overlap of the Cells. Each record had a begin and end time indicating for when the information is valid.

```mermaid
classDiagram
  class NetworkTopology {
    +cell_id: CellID
    +start_time: Time
    +end_time: Time
    +location: GeoPoint[WGS84]
    +probability_map: Raster[ProbabilityOfContact]
    +tower_id
    [+emplacement_id]
    [+technology]
    [+type_of_cell]
    [+azimuth]
    [+elevation_beamwidth]
    [+azimuth_beamwidth]
    [+power_of_admission]
    [+electrical_down_tilt]
    [+antenna_height]
  }
```

#### Remarks

Note that the `Event`, `Time Segment`, `Anchor` and `Continuous User Diary` do not contain geographic information. All geographic information is contained in the Cell that are part of the relevent object type. There are a couple of reasons for this. First, the location of a device is not known in more detail than the combination of Cell. Second, the transformation from Cell to geographic location depends in part on the specific use case. For some use cases this transformation is simple (count devices in Rome) while for other use cases a more complex transformation is needed (number of devices taking the train). Third, some of the methods for transforming the Cells to geographic location, such as the ML-EM estimator, need to combine the information from multiple devices at the same time. Therefore it is not possible to generate a geographic location per Device.

