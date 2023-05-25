# Pipeline

## Events: Import and clean up high frequency events

Can also be roaming SMS

```mermaid
flowchart LR
  raw_event:::data --> Clean-up --> event:::data --> event_ts[(event_ts)]

classDef data stroke-width:0px
```
