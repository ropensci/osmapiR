# osm_bbox_objects works

    Code
      print(bbox_objects, max = 100)
    Output
        type         id visible version changeset           timestamp       user
      1 node 1086791219    TRUE       2  28904440 2015-02-17 09:43:37     EliziR
      2 node 1086906702    TRUE       2  10884933 2012-03-05 21:49:06     EliziR
      3 node 1087707418    TRUE       1   6889330 2011-01-07 04:25:19 antecessor
      4 node 1087772898    TRUE       1   6889330 2011-01-07 05:11:39 antecessor
      5 node 1088962088    TRUE       2  10884933 2012-03-05 21:49:08     EliziR
      6 node 1089032997    TRUE       2  10884933 2012-03-05 21:49:08     EliziR
      7 node 1090232160    TRUE       1   6900107 2011-01-08 04:58:50 antecessor
      8 node 1091749098    TRUE       2  10884933 2012-03-05 21:49:10     EliziR
           uid        lat       lon members    tags
      1 605366 41.8343475 1.8380789    NULL No tags
      2 605366 41.8346086 1.8381028    NULL No tags
      3  87939 41.8337241 1.8375993    NULL No tags
      4  87939 41.8341401 1.8380538    NULL No tags
      5 605366 41.8345475 1.8360498    NULL No tags
      6 605366 41.8340566 1.8366058    NULL No tags
      7  87939 41.8335690 1.8374740    NULL No tags
      8 605366 41.8347877 1.8359973    NULL No tags
       [ reached 'max' / getOption("max.print") -- omitted 225 rows ]

---

    Code
      print(empty_bbox_objects)
    Output
       [1] type      id        visible   version   changeset timestamp user     
       [8] uid       lat       lon       members   tags     
      <0 rows> (or 0-length row.names)

