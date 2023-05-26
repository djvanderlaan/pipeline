# Pipeline

## General

### Events: Import and clean up high frequency events

Can also be roaming SMS

```mermaid
flowchart LR
  raw_event:::data --> CleanUp --> event:::data --> event_ts[(event_ts)]

classDef data stroke-width:0px
```

### Stays: Turn high frequency data/events into stays


```mermaid
flowchart LR
  event_ts[(event_ts)] --> DeriveStay --> CleanUpStay --> stays:::data --> stay_ts[(stay_ts)]
  clean_cell_plan --> DeriveStay

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

cell_plan:::data --> CleanUpCell --> clean_cell_plan:::data

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

stay_ts[("stay_ts(t)")] --> AggregateCell --> BackProject --> Weigh 

cell_spatial_probs:::data --> BackProject
geo_data("[geo_data]"):::data --> BackProject

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

stay_ts[("stay_ts [t-30,t]")] --> DeriveHome --> home_ts[(home_ts)]

classDef data stroke-width:0px
```

```mermaid
flowchart LR

stay_ts[("stay_ts(t)")] --> AggregateCellHome --> BackProject --> Weigh 

home_ts[("home_ts (t)")] --> AggregateCellHome
cell_spatial_probs:::data --> BackProject
geo_data("[geo_data]"):::data --> BackProject

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

stay_ts[("stay_ts(t)")] --> BackProject --> Weigh 

imsi[("imsi")] --> BackProject
foreign_ts[("foreign_ts")] --> BackProject

cell_spatial_probs:::data --> BackProject
geo_data("[geo_data]"):::data --> BackProject

subgraph NSI
  Weigh --> foreign_spatial:::data
  statistical_data:::data --> Weigh
end

classDef data stroke-width:0px
```




