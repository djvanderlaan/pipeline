# Pipeline

## Events: Import and clean up high frequency events

Can also be roaming SMS

```mermaid
flowchart LR
  raw_event:::data --> Clean-up --> event:::data --> event_ts[(event_ts)]

classDef data stroke-width:0px
```

## Stays: Turn high frequency data/events into stays


```mermaid
flowchart LR
  event_ts[(event_ts)] --> Derive-stay --> Clean-up stay --> stays:::data --> stay_ts[(stay_ts)]
  clean_cell_plan --> Derive-stay

classDef data stroke-width:0px
```
