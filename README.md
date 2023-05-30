# Pipeline

## General

### Events: Import and clean up high frequency events

Can also be roaming SMS

```mermaid
flowchart LR
  raw_event:::data --> CleanUp --> event:::data --> event_ts[(event_ts)]

classDef data stroke-width:0px
```

|deviceid  |time   |antenna|
|---------:|:------|:------|
|1         |t1     |A      |
|1         |t2     |A      |
|1         |t3     |B      |
|1         |t4     |A      |
|1         |t5     |C      |
|1         |t6     |D      |
|1         |t7     |E      |
|1         |t9     |F      |
|1         |t10    |E      |
|1         |t11    |D      |
|1         |t12    |G      |
|1         |t13    |A      |
|1         |t14    |B      |

### Stays: Turn high frequency data/events into stays


```mermaid
flowchart LR
  event_ts[(event_ts)] --> DeriveStay --> CleanUpStay --> ClassifyStays --> stays:::data --> stay_ts[(stay_ts)]

  clean_cell_plan -.-> DeriveStay
  anchor_ts[(anchor_ts)] --> ClassifyStays

classDef data stroke-width:0px
```

### Anchors

Classify stays and clean up stays into "meaning full" anchors (home/work etc.)

```mermaid
flowchart LR
  stay_ts[(stay_ts)] --> clas["DeriveAnchor"] --> anchor::data --> 
    anchor_ts[(anchor_ts)]

classDef data stroke-width:0px
```


### Device classification
Roaming + Human/machine

```mermaid
flowchart LR
  event_ts[(event_ts)] --> roam["DeriveRoaming"] --> mach["Machine/Human"] --> 
    imsi[(imsi)]

classDef data stroke-width:0px
```

## Other data

### Import cell plan

```mermaid
flowchart LR

cell_plan:::data --> CleanUpCell --> clean_cell_plan_ts[(cell_plan_ts)]

classDef data stroke-width:0px
```

### Determine signal strength

The ideal scenario is that signal strength data are delivered from the MNO 

```mermaid
flowchart LR

mno_signal:::data --> Rasterise --> cell_signal_strength:::data

classDef data stroke-width:0px
```

Alternatively, signal strength can be modeled from the cell plan data, and/or the (n)-Best Server Maps:

```mermaid
flowchart LR

clean_cell_plan:::data --> ModelSignalStrength --> cell_signal_strength:::data

mno_BSM:::data --> ModelSignalStrength

classDef data stroke-width:0px
```

One of the methods that can be used for ModelSignalStrength is the mobloc method (and corresponding R package). Best Server Maps can be used to validate the output (and set the model parameters).


### Model probability of connection

This step is needed to translate the signal strength values to the 'quality' of connection. In the mobloc method, this is called signal dominance.

```mermaid
flowchart LR

cell_signal_strength:::data --> ModelConnection --> cell_spatial_probs:::data

classDef data stroke-width:0px
```



### Import geodata

```mermaid
flowchart LR

geo_raw:::data --> Rasterise --> geo_data:::data

classDef data stroke-width:0px
```


## Use-Cases


### Use Case: Spatial current population

```mermaid
flowchart LR

stay_ts[("stay_ts(t)")] --> AggregateCell --> DistributeSpatially --> Weigh 

cell_spatial_probs:::data --> DistributeSpatially
geo_data("[geo_data]"):::data --> DistributeSpatially

subgraph NSI
Weigh --> spatial_population:::Data
statistical_data:::data --> Weigh
end

classDef data stroke-width:0px
```


### Use Case: Spatial current population by home location

Derive home location
```mermaid
flowchart LR

stay_ts[("stay_ts [t-30,t]")] --> DeriveAtHome --> home_ts[(home_ts)]
anchor_ts["anchor_ts"] --> DeriveAtHome

classDef data stroke-width:0px
```

```mermaid
flowchart LR

stay_ts[("stay_ts(t)")] --> AggregateCellHome --> DistributeSpatially --> Weigh 

home_ts[("home_ts (t)")] --> AggregateCellHome
cell_spatial_probs:::data --> DistributeSpatially
geo_data("[geo_data]"):::data --> DistributeSpatially

subgraph NSI
  Weigh --> spatial_home_dest:::data
  statistical_data:::data --> Weigh
end

classDef data stroke-width:0px
```


### Use Case: spatial estimation of foreign tourist

```mermaid
flowchart LR

event_ts[("event_ts")] --> EnteringLeaving --> foreign_ts[(foreign_ts)]
imsi[(imsi_ts)] --> EnteringLeaving

classDef data stroke-width:0px
```

```mermaid
flowchart LR

stay_ts[("stay_ts(t)")] --> DistributeSpatially --> Weigh 

imsi[("imsi")] --> DistributeSpatially
foreign_ts[("foreign_ts")] --> DistributeSpatially

cell_spatial_probs:::data --> DistributeSpatially
geo_data("[geo_data]"):::data --> DistributeSpatially

subgraph NSI
  Weigh --> foreign_spatial:::data
  statistical_data:::data --> Weigh
end

classDef data stroke-width:0px
```




