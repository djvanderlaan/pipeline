## Questions:

Concepts:
- Stay, continous user diary, anchor

Suggestion:

Stay (better name?)
- precursor to Continuous User Diary
- not continuous
- encodes stay at 1 cell_id 
- begin/end time
- input for Anchor and Continuous User Diary

Continuous User Diary
- encodes continuous user presence
- stay/move/unknown
- location? Suggestion: cell_id
- what to do with missing/tourist/new phones etc.?
- labeling with anchor probably is Use Case specific

Anchor:
- list of cell_ids
- needs a longer period of stays/events to analyze patterns
- would benefit from frequencies/stays fractions of the period

```mermaid

flowchart TD

classDef data fill:#033d59,stroke-width:1px, color:#333333;
classDef process fill:#f3a000,stroke-width:1px,color:#333333;
classDef db fill:#c8f3c3,stroke:#333333,color:#333333;
classDef db_rest fill:#98c363,stroke:#333333,color:#333333;

RawEvent[("Raw MNO Event")]:::db
Event[("MNO Event")]:::db
anchor_db[("Anchor")]:::db_rest
cud_db[("Continuous User Diary")]:::db_rest
TimeSegment[("Time Segment")]:::db

derive_achor["Derive Anchor"]:::process
make_cont["Make Continous"]:::process
label["Label Stay"]:::process
clean_up["Clean Events"]:::process

RawEvent --> clean_up --> Event
Event --> make_cont --> TimeSegment

TimeSegment --> derive_achor
subgraph Anchor["Determine Anchors"]
  derive_achor --> anchor_db
end

anchor_db --> label
TimeSegment --> label
subgraph cud["Continous User Diary"]
  label --> cud_db
end

cells_to_region["Cell To Region"]:::process
cud_db --> cells_to_region

RawNetwork[("Raw MNO Network")]:::db
Network[("Network")]:::db_rest
clean_network["Clean"]:::process

Network -.-> make_cont
RawNetwork --> clean_network --> Network
```

# Example Use Case


```mermaid
flowchart TD

classDef data fill:#033d59,stroke-width:1px, color:#333333;
classDef process fill:#f3a000,stroke-width:1px,color:#333333;
classDef db fill:#c8f3c3,stroke:#333333,color:#333333;
classDef db_rest fill:#98c363,stroke:#333333,color:#333333;

anchor_db[("Anchor")]:::db_rest
cud_db[("Continuous User Diary")]:::db_rest
Network[("Network")]:::db_rest


RegionCud[("Regional \n User Diary")]:::db

cud_db --> cells_to_region
Network ---> cells_to_region
cells_to_region --> RegionCud
```
