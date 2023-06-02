
The main process creates a number of components that will be used by the various use cases. The goal is to have information needed by multiple use cases in the main process in order to have consistency between the use cases. Note that the main process is here only defined in general terms. There are a lot of specific methodological and technical details relevant when implementing and relevant to get correct statistical output. Also, for some of the steps auxiliary information, such the locations of the cell towers, is needed. This is also left out of this general description of the process.  The goal is to have a division of the process into a small number of general parts that can be further detailed and to have agreement on the general process. 

The main process consists of the following objects:

### event

- The information as obtained from the mobile network operator. 
- The main pieces of information are `time` (time at which the event occurred) and `cell` (the id of the antenna where the event occurred). 

### move_stay

- Derived from `event`. 
- Continuous periods that contain (optionally) multiple events. 
- Have a start-time and end-time
- Contain the `event`s (these are not lost in the stay). 
- Holes are allowed. There can be periods for a given device without any `move_stay`. 
- Small gaps between events are removed. What is considered to be a small gap and a large gap is to be decided. 
- There are 3 types of `move_stay`: 'move' (device is moving), 'stay' (at one location for a longer time), 'unknown/other'. 

Deriving the `move_stay` from the `event`s can be done with a lot of assumptions and modelling and with little. In the simplest case only subsequent event at the same cell are combined into one `move_stay` and it is not attempted to label the `move_stay` into 'move' or 'stay' (all of the are labelled as 'unknown/other'). For some use cases this may be enough and if these are the only relevant use cases, this is fine. However, in general one will want to put more effort into deriving proper `move_stay`. This will be a balance between adding as much information as possible into the data and putting too many (possible incorrect) assumptions into the data. 

### anchor

- Derived from `move_stay`
- Meaningful locations or areas for a device. 
- Are defined by the `cell` involved. 
- Are labelled. For example 'home' will be an important `anchor` for many use cases. 
- Have a begin and end-time. 

### continous_user_diary

- Derived from `move_stay` using information from the `anchor`.
- Assign meaning to `move_stay`.
- For example label some `move_stay` as 'at home', 'at work', 'travelling by train'. 
- Not all `move_stay` will be labelled. 
- It is possible that one `move_stay` will have multiple labels. 




### Overview of the main process

``` mermaid
flowchart TD

event --> x((" ")) --> move_stay --> y((" ")) --> continuous_user_diary
move_stay --> z((" ")) --> anchor --> y
```


