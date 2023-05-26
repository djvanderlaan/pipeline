# Pipeline

## General

### Events: Import and clean up high frequency events

Can also be roaming SMS

```mermaid
flowchart LR
  raw_event:::data --> Clean-up --> event:::data --> event_ts[(event_ts)]

classDef data stroke-width:0px
```

### Stays: Turn high frequency data/events into stays


```mermaid
flowchart LR
  event_ts[(event_ts)] --> Derive_stay --> CleanUp_stay --> stays:::data --> stay_ts[(stay_ts)]
  clean_cell_plan --> Derive_stay

classDef data stroke-width:0px
```

### Anchors

Classify stays and clean up stays into "meaning full" anchors (home/work etc.)

```mermaid
flowchart LR
  stay_ts[(stay_ts)] --> clas["Classify stays [t-30,t] Derive Anchor"] --> anchor::data --> 
    anchor_ts[(anchor_ts)]

classDef data stroke-width:0px
```


### Device classification
Roaming + Human/machine

```mermaid
flowchart LR
  event_ts[(event_ts)] --> roam["Derive Roaming/Country"] --> mach["Machine/Human"] --> 
    imsi[(imsi)]

classDef data stroke-width:0px
```

## Other data

### Import cell plan

```mermaid
flowchart LR

cell_plan:::data --> CleanUp_cell --> clean_cell_plan:::data --> Mobloc --> cell_spatial_probs:::data

classDef data stroke-width:0px
```
An alternative for the last step would be to use data from the MNO such as best service maps to derive the `cell_spatial_probs`
```mermaid
flowchart LR

mno_signal:::data --> Rasterise --> cell_spatial_probs:::data

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

stay_ts[("stay_ts(t)")] --> Aggregate_cell --> Back_project --> Weigh --> spatial_population:::Data

cell_spatial_probs:::data --> Back_project
geo_data("[geo_data]"):::data --> Back_project

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

stay_ts[("stay_ts [t-30,t]")] --> Derive_home --> home_ts[(home_ts)]

classDef data stroke-width:0px
```

```mermaid
flowchart LR

stay_ts[("stay_ts(t)")] --> Aggregate_cell_home --> Back_project --> Weigh --> spatial_home_dest:::data

home_ts[("home_ts (t)")] --> Aggregate_cell_home

cell_spatial_probs:::data --> Back_project
geo_data("[geo_data]"):::data --> Back_project
statistical_data:::data --> Weigh

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

stay_ts[("stay_ts(t)")] --> Back_project --> Weigh --> foreign_spatial:::data

imsi[("imsi")] --> Back_project
foreign_ts[("foreign_ts")] --> Back_project

cell_spatial_probs:::data --> Back_project
geo_data("[geo_data]"):::data --> Back_project
statistical_data:::data --> Weigh

classDef data stroke-width:0px
```




