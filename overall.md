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

rawevent:data("Raw Mno Event")
event:data("MNO Event")
stay("Stay")
event:db[("Events")]
anchor_db[("Anchor")]
cud_db[("Continuous User Diary")]

derive_stay["Derive Stay"]
make_cont["Make Continous"]
label["Label stay"]

rawevent:data --> CleanUp["Clean Events"] --> event:data
event:data --> event:db
event:db --> derive_stay --> stay

stay --> derive_achor["Derive Anchor"] --> anchor_db
anchor_db --> label

subgraph cud["Continous User Diary"]
stay --> make_cont --> label
label --> cud_db
end 
```

