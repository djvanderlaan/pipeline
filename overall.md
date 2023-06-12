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
classDef db fill:#98c363,stroke:#333333,color:#333333;

RawEvent[("Raw Mno Event")]:::db
Event[("MNO Event")]:::db

Stay[("Stay")]:::db

anchor_db[("Anchor")]:::db
cud_db[("Continuous User Diary")]:::db

derive_stay["Derive Stay"]:::process
derive_achor["Derive Anchor"]:::process
make_cont["Make Continous"]:::process
label["Label stay"]:::process


clean_up["Clean events"]:::process

RawEvent --> clean_up --> Event
Event --> derive_stay --> Stay
Stay --> derive_achor

subgraph Anchor
derive_achor --> anchor_db
end

anchor_db --> label

Stay --> make_cont
subgraph cud["Continous User Diary"]
make_cont --> label
label --> cud_db
end

cells_to_region["Cell To Region"]:::process
cud_db --> cells_to_region

RawNetwork[("Raw Network")]:::db
Network[("Network")]:::db 
clean_network["Clean"]:::process

RegionCud[("Regional \n User Diary")]:::db

RawNetwork --> clean_network --> Network
Network ---> cells_to_region
cells_to_region --> RegionCud

```

