---
title: Overview pipeline - version 0.1
author: Edwin de Jonge and Jan van der Laan
date: 2023-06-14
---




## Overview of the general pipeline

The schema below shows an overview of the general pipeline. The cylinder shaped objects are the different object types. The rectangles are the processes transforming the object types. Note that in practice a transformation between two object types can consist of multiple subtransformations. The goal of this schema is to give the outline of the process. The darker green data types are the general components that can be used by the different use-cases. 

```mermaid

flowchart TD

classDef data fill:#033d59,stroke-width:1px, color:#333333;
classDef process fill:#f3a000,stroke-width:1px,color:#333333;
classDef db fill:#c8f3c3,stroke:#333333,color:#333333;
classDef db_rest fill:#98c363,stroke:#333333,color:#333333;

RawEvent[("Raw MNO Event")]:::db
Event[("Event")]:::db
anchor_db[("Anchor")]:::db_rest
cud_db[("Continuous User Diary")]:::db_rest
TimeSegment[("Time Segment")]:::db

derive_achor["Derive Anchor"]:::process
make_cont["Make Continuous"]:::process
label["Label Time Segment"]:::process
clean_up["Import and Clean Events"]:::process

subgraph proces_events["Process Events"]
  RawEvent --> clean_up --> Event
  Event --> make_cont --> TimeSegment
end

TimeSegment --> derive_achor
subgraph Anchor["Determine Anchors"]
  derive_achor --> anchor_db
end

anchor_db --> label
TimeSegment --> label
subgraph cud["Continous User Diary"]
  label --> cud_db
end

subgraph preprocessnetwork["Prepare Network Topology"]
  RawNetwork[("Raw MNO Network Topology")]:::db
  Network[("Network Topology")]:::db_rest
  clean_network["Import and Preprocess Topology"]:::process

  Network -.-> make_cont
  RawNetwork --> clean_network --> Network
end
```

### Main concepts in the general pipeline

`Event`
: The main information (after preprocessing) obtained from the MNO. Contains discrete events. The main information in the events are the Device, Cell (this can also be a GPS coordinate) and Time. 

`Time Segment`
: Combines several `Events` of a Device into continuous time segments. In principle time segments are continuous (there are no gaps between the `Time Segments`). However, it is possible that for certain longer time periodes without events no `Time Segment` is defined. 
: Contains the seperate `Events`. Therefore, no information present in the `Events` is lost. 
: Can contain `Events` that took place at different Cell.

`Anchor`
: A combination of Cell that is meaningfull for a Device. An `Anchor` is, therefore, labelled.
: For example, the home location of a Device can be defined using a number of Cells (possibly weighted).
: A device can have multiple `Anchors` (e.g. 'Home', 'Work')
: Has a begin time and end time for which the `Anchor` is valid.

`Continuous User Diary`
: In the `Continuous User Diary` some of the `Time Segments` are labelled. 
: For example, some of the `Time Segments` could be labelled as 'At Home'. 

`Network topology`
: Contains information for each Cell in the network.
: Contains for each Cell a raster map with the probability of connecting to the Cell given the location.
: Each record had a begin and end time indicating when the information is valid.

Note that the `Event`, `Time Segment`, `Anchor` and `Continuous User Diary` do not contain geographic information. All geographic information is contained in the Cell that are part of the relevent object type. There are a couple of reasons for this. First, the location of a device is not known in more detail than the combination of Cell. Second, the transformation from Cell to geographic location depends in part on the specific use case. For some use cases this transformation is simple (count devices in Rome) while for other use cases a more complex transformation is needed (number of devices taking the train). Third, some of the methods for transforming the Cells to geographic location, such as the ML-EM estimator, need to combine the information from multiple devices at the same time. Therefore it is not possible to generate a geographic location per Device.

## Use Case: Present population in space and time


```mermaid
flowchart TD

classDef data fill:#033d59,stroke-width:1px, color:#333333;
classDef process fill:#f3a000,stroke-width:1px,color:#333333;
classDef db fill:#c8f3c3,stroke:#333333,color:#333333;
classDef db_rest fill:#98c363,stroke:#333333,color:#333333;

anchor_db[("Anchor")]:::db_rest
cud_db[("Continuous User Diary")]:::db_rest
Network[("Network Topology")]:::db_rest
DeviceDist[("Present Device\nDistribution")]:::db
Census[("Census Data")]:::db

aggregate["Aggregate"]:::process
cells_to_region["Cells to\n Spatial Raster"]:::process
weight["Statistical Weighting"]:::process


RegionCud[("Present Population")]:::db

anchor_db --> aggregate
cud_db --> aggregate
Network ---> cells_to_region
aggregate --> cells_to_region
cells_to_region --> DeviceDist

DeviceDist --> weight
subgraph atnsi["@NSI"]
  Census --> weight
  weight --> RegionCud
end

```
