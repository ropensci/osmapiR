# osm_read_changeset works

    Code
      print(chaset)
    Output
               id          created_at           closed_at  open      user      uid
      1 137595351 2023-06-21 09:09:18 2023-06-21 09:09:18 FALSE Quercinus 19641470
           min_lat   min_lon    max_lat   max_lon comments_count changes_count
      1 42.6799619 2.6580564 42.6936802 2.7125775              4             1
                                                                                       tags
      1 8 tags: changesets_count=1 | comment=Correcció d'acord amb la toponímia oficial ...

---

    Code
      print(chaset_discuss)
    Output
               id          created_at           closed_at  open      user      uid
      1 137595351 2023-06-21 09:09:18 2023-06-21 09:09:18 FALSE Quercinus 19641470
           min_lat   min_lon    max_lat   max_lon comments_count changes_count
      1 42.6799619 2.6580564 42.6936802 2.7125775              4             1
                                                          discussion
      1 4 comments from 2023-06-26 to 2023-07-03 by rainerU, Quer...
                                                                                       tags
      1 8 tags: changesets_count=1 | comment=Correcció d'acord amb la toponímia oficial ...

# osm_download_changeset works

    Code
      print(osmchange)
    Output
         action_type type          id visible version changeset           timestamp
      1       create node 10959104783    TRUE       1 137003062 2023-06-06 08:18:47
      2       create node 10959104784    TRUE       1 137003062 2023-06-06 08:18:47
      3       create node 10959104785    TRUE       1 137003062 2023-06-06 08:18:47
      4       create node 10959104786    TRUE       1 137003062 2023-06-06 08:18:47
      5       create node 10959104787    TRUE       1 137003062 2023-06-06 08:18:47
      6       create node 10959104788    TRUE       1 137003062 2023-06-06 08:18:47
      7       create  way  1179939727    TRUE       1 137003062 2023-06-06 08:18:47
      8       create  way  1179939728    TRUE       1 137003062 2023-06-06 08:18:47
      9       modify node   472315639    TRUE       3 137003062 2023-06-06 08:18:47
      10      modify  way   144018965    TRUE       6 137003062 2023-06-06 08:18:47
      11      modify  way   772922459    TRUE       8 137003062 2023-06-06 08:18:47
      12      modify  way    39428288    TRUE      11 137003062 2023-06-06 08:18:47
      13      modify  way   144017967    TRUE      11 137003062 2023-06-06 08:18:47
             user     uid        lat        lon
      1  MariaDCC 7951616 39.9312656 -0.0611038
      2  MariaDCC 7951616 39.9275936 -0.0633938
      3  MariaDCC 7951616 39.9186918 -0.0668522
      4  MariaDCC 7951616 39.9186426 -0.0669390
      5  MariaDCC 7951616 39.9143313 -0.0585758
      6  MariaDCC 7951616 39.9275524 -0.0556357
      7  MariaDCC 7951616       <NA>       <NA>
      8  MariaDCC 7951616       <NA>       <NA>
      9  MariaDCC 7951616 39.9144031 -0.0632470
      10 MariaDCC 7951616       <NA>       <NA>
      11 MariaDCC 7951616       <NA>       <NA>
      12 MariaDCC 7951616       <NA>       <NA>
      13 MariaDCC 7951616       <NA>       <NA>
                                                                 members
      1                                                             NULL
      2                                                             NULL
      3                                                             NULL
      4                                                             NULL
      5                                                             NULL
      6                                                             NULL
      7  5 nodes: 10959104783, 1579678230, 8701431676, 8701431680, 10...
      8  101 nodes: 1579678230, 1579678224, 8701431674, 1579678222, 1...
      9                                                             NULL
      10                    3 nodes: 1575984666, 10959104783, 1575984667
      11 20 nodes: 472315862, 472315695, 8705264405, 472315697, 47231...
      12 71 nodes: 6207335786, 6207335788, 6207335787, 472315576, 472...
      13 97 nodes: 1579678210, 1579678208, 1579678203, 8701431694, 15...
                                                                                        tags
      1                                                                              No tags
      2                                                                              No tags
      3                                                                              No tags
      4                                                                              No tags
      5                                                                              No tags
      6                                                                              No tags
      7                                                               1 tag: landuse=orchard
      8                                                               1 tag: landuse=orchard
      9                                                                              No tags
      10 6 tags: bridge=yes | highway=cycleway | layer=1 | lit=no | ref=CR-18 | surface=a...
      11 6 tags: highway=unclassified | lane_markings=no | name=Camí de La Cantera de Vor...
      12 4 tags: highway=unclassified | name=Camí dels Carnissers | name:ca=Camí dels Car...
      13                         3 tags: highway=unclassified | noname=yes | surface=asphalt

# osm_query_changesets works

    Code
      print(x)
    Output
               id          created_at           closed_at  open               user
      1 137625624 2023-06-22 00:38:20 2023-06-22 00:38:20 FALSE Mementomoristultus
      2 137627129 2023-06-22 02:23:23 2023-06-22 02:23:24 FALSE Mementomoristultus
             uid    min_lat    min_lon    max_lat    max_lon comments_count
      1 19648429 42.2050642 -7.7351732 42.2050642 -7.7351732              0
      2 19648429 39.8308943  4.1564704 40.0215358  4.3280260              0
        changes_count
      1             1
      2             2
                                                                                       tags
      1 6 tags: changesets_count=53 | comment=A ver, subnormal, en español es JUNUQUERA ...
      2 6 tags: changesets_count=154 | comment=--- | created_by=iD 2.25.2 | host=https:/...

---

    Code
      print(x)
    Output
               id          created_at           closed_at  open      user      uid
      1 151819967 2024-05-25 16:49:04 2024-05-25 16:49:04 FALSE  jmaspons 11725140
      2 137595351 2023-06-21 09:09:18 2023-06-21 09:09:18 FALSE Quercinus 19641470
           min_lat   min_lon    max_lat   max_lon comments_count changes_count
      1       <NA>      <NA>       <NA>      <NA>              0             0
      2 42.6799619 2.6580564 42.6936802 2.7125775              4             1
                                                                                       tags
      1 4 tags: comment=Afegeixo `name:ca` a objectes que apareixen a https://www.openst...
      2 8 tags: changesets_count=1 | comment=Correcció d'acord amb la toponímia oficial ...

---

    Code
      print(x)
    Output
               id          created_at           closed_at  open               user
      1 137627138 2023-06-22 02:24:02 2023-06-22 02:24:02 FALSE Mementomoristultus
      2 137627132 2023-06-22 02:23:42 2023-06-22 02:23:42 FALSE Mementomoristultus
      3 137627129 2023-06-22 02:23:23 2023-06-22 02:23:24 FALSE Mementomoristultus
             uid    min_lat   min_lon    max_lat   max_lon comments_count
      1 19648429 39.8900207 4.2663878 39.8900310 4.2663905              0
      2 19648429 39.8894901 4.2661856 39.8894922 4.2662071              0
      3 19648429 39.8308943 4.1564704 40.0215358 4.3280260              0
        changes_count
      1             1
      2             1
      3             2
                                                                                       tags
      1 6 tags: changesets_count=156 | comment=--- | created_by=iD 2.25.2 | host=https:/...
      2 6 tags: changesets_count=155 | comment=--- | created_by=iD 2.25.2 | host=https:/...
      3 6 tags: changesets_count=154 | comment=--- | created_by=iD 2.25.2 | host=https:/...

---

    Code
      print(x)
    Output
                id          created_at           closed_at  open               user
      1  137626978 2023-06-22 02:10:24 2023-06-22 02:10:24 FALSE Mementomoristultus
      2  137626972 2023-06-22 02:09:43 2023-06-22 02:09:44 FALSE Mementomoristultus
      3  137626970 2023-06-22 02:09:28 2023-06-22 02:09:28 FALSE Mementomoristultus
      4  137626862 2023-06-22 02:01:25 2023-06-22 02:01:26 FALSE Mementomoristultus
      5  137626853 2023-06-22 02:00:48 2023-06-22 02:00:48 FALSE Mementomoristultus
      6  137626849 2023-06-22 02:00:24 2023-06-22 02:00:24 FALSE Mementomoristultus
      7  137626836 2023-06-22 01:59:16 2023-06-22 01:59:16 FALSE Mementomoristultus
      8  137626833 2023-06-22 01:58:51 2023-06-22 01:58:51 FALSE Mementomoristultus
      9  137626827 2023-06-22 01:58:12 2023-06-22 01:58:12 FALSE Mementomoristultus
      10 137626819 2023-06-22 01:57:49 2023-06-22 01:57:49 FALSE Mementomoristultus
              uid    min_lat    min_lon    max_lat    max_lon comments_count
      1  19648429 42.4327433 -6.9782486 42.4328559 -6.9780026              0
      2  19648429 42.4327498 -6.9765097 42.4328834 -6.9763031              0
      3  19648429 42.4328903 -6.9756364 42.4330040 -6.9754741              0
      4  19648429 43.4488066 -7.8527610 43.4501613 -7.8507456              0
      5  19648429 43.4499647 -7.8526224 43.4500774 -7.8525214              0
      6  19648429 43.4498605 -7.8527232 43.4509926 -7.8497643              0
      7  19648429 43.4509478 -7.8490408 43.4511815 -7.8487310              0
      8  19648429 43.4503112 -7.8491926 43.4506422 -7.8486152              0
      9  19648429 43.4515806 -7.8518012 43.4518359 -7.8513226              0
      10 19648429 43.4517061 -7.8521361 43.4518324 -7.8519759              0
         changes_count
      1              5
      2              5
      3              5
      4              2
      5              1
      6              7
      7              1
      8              2
      9              1
      10             5
                                                                                        tags
      1  6 tags: changesets_count=150 | comment=18945 | created_by=iD 2.25.2 | host=https...
      2  6 tags: changesets_count=149 | comment=18945 | created_by=iD 2.25.2 | host=https...
      3  6 tags: changesets_count=148 | comment=18945 | created_by=iD 2.25.2 | host=https...
      4  6 tags: changesets_count=144 | comment=11 | created_by=iD 2.25.2 | host=https://...
      5  6 tags: changesets_count=143 | comment=13 | created_by=iD 2.25.2 | host=https://...
      6  6 tags: changesets_count=142 | comment=13 | created_by=iD 2.25.2 | host=https://...
      7  6 tags: changesets_count=141 | comment=13 | created_by=iD 2.25.2 | host=https://...
      8  6 tags: changesets_count=140 | comment=11 | created_by=iD 2.25.2 | host=https://...
      9  7 tags: changesets_count=139 | comment=12 | created_by=iD 2.25.2 | host=https://...
      10 6 tags: changesets_count=138 | comment=13 | created_by=iD 2.25.2 | host=https://...

---

    Code
      print(x)
    Output
                id          created_at           closed_at  open               user
      1  137626978 2023-06-22 02:10:24 2023-06-22 02:10:24 FALSE Mementomoristultus
      2  137626972 2023-06-22 02:09:43 2023-06-22 02:09:44 FALSE Mementomoristultus
      3  137626970 2023-06-22 02:09:28 2023-06-22 02:09:28 FALSE Mementomoristultus
      4  137626862 2023-06-22 02:01:25 2023-06-22 02:01:26 FALSE Mementomoristultus
      5  137626853 2023-06-22 02:00:48 2023-06-22 02:00:48 FALSE Mementomoristultus
      6  137626849 2023-06-22 02:00:24 2023-06-22 02:00:24 FALSE Mementomoristultus
      7  137626836 2023-06-22 01:59:16 2023-06-22 01:59:16 FALSE Mementomoristultus
      8  137626833 2023-06-22 01:58:51 2023-06-22 01:58:51 FALSE Mementomoristultus
      9  137626827 2023-06-22 01:58:12 2023-06-22 01:58:12 FALSE Mementomoristultus
      10 137626819 2023-06-22 01:57:49 2023-06-22 01:57:49 FALSE Mementomoristultus
      11 137626813 2023-06-22 01:57:20 2023-06-22 01:57:20 FALSE Mementomoristultus
      12 137626807 2023-06-22 01:56:41 2023-06-22 01:56:42 FALSE Mementomoristultus
      13 137626802 2023-06-22 01:56:13 2023-06-22 01:56:14 FALSE Mementomoristultus
      14 137626794 2023-06-22 01:55:22 2023-06-22 01:55:22 FALSE Mementomoristultus
      15 137626788 2023-06-22 01:54:57 2023-06-22 01:54:57 FALSE Mementomoristultus
      16 137626782 2023-06-22 01:54:22 2023-06-22 01:54:22 FALSE Mementomoristultus
      17 137626769 2023-06-22 01:53:38 2023-06-22 01:53:38 FALSE Mementomoristultus
      18 137626762 2023-06-22 01:53:12 2023-06-22 01:53:13 FALSE Mementomoristultus
      19 137626755 2023-06-22 01:52:35 2023-06-22 01:52:36 FALSE Mementomoristultus
      20 137626750 2023-06-22 01:52:18 2023-06-22 01:52:18 FALSE Mementomoristultus
      21 137626743 2023-06-22 01:51:52 2023-06-22 01:51:52 FALSE Mementomoristultus
      22 137626736 2023-06-22 01:51:21 2023-06-22 01:51:22 FALSE Mementomoristultus
      23 137626718 2023-06-22 01:50:19 2023-06-22 01:50:19 FALSE Mementomoristultus
      24 137626713 2023-06-22 01:50:00 2023-06-22 01:50:00 FALSE Mementomoristultus
      25 137626710 2023-06-22 01:49:40 2023-06-22 01:49:40 FALSE Mementomoristultus
      26 137626704 2023-06-22 01:49:20 2023-06-22 01:49:20 FALSE Mementomoristultus
      27 137626693 2023-06-22 01:48:30 2023-06-22 01:48:31 FALSE Mementomoristultus
      28 137626667 2023-06-22 01:46:44 2023-06-22 01:46:45 FALSE Mementomoristultus
      29 137626664 2023-06-22 01:46:23 2023-06-22 01:46:23 FALSE Mementomoristultus
      30 137626659 2023-06-22 01:45:54 2023-06-22 01:45:54 FALSE Mementomoristultus
      31 137626644 2023-06-22 01:44:32 2023-06-22 01:44:32 FALSE Mementomoristultus
      32 137626632 2023-06-22 01:43:19 2023-06-22 01:43:19 FALSE Mementomoristultus
      33 137626618 2023-06-22 01:42:32 2023-06-22 01:42:32 FALSE Mementomoristultus
      34 137626593 2023-06-22 01:40:31 2023-06-22 01:40:32 FALSE Mementomoristultus
      35 137626567 2023-06-22 01:39:13 2023-06-22 01:39:14 FALSE Mementomoristultus
      36 137626527 2023-06-22 01:36:47 2023-06-22 01:36:47 FALSE Mementomoristultus
      37 137626508 2023-06-22 01:35:27 2023-06-22 01:35:27 FALSE Mementomoristultus
      38 137626497 2023-06-22 01:35:00 2023-06-22 01:35:01 FALSE Mementomoristultus
      39 137626489 2023-06-22 01:34:25 2023-06-22 01:34:25 FALSE Mementomoristultus
      40 137626470 2023-06-22 01:33:33 2023-06-22 01:33:34 FALSE Mementomoristultus
      41 137626459 2023-06-22 01:33:09 2023-06-22 01:33:09 FALSE Mementomoristultus
      42 137626449 2023-06-22 01:32:34 2023-06-22 01:32:35 FALSE Mementomoristultus
      43 137626404 2023-06-22 01:30:05 2023-06-22 01:30:05 FALSE Mementomoristultus
      44 137626387 2023-06-22 01:28:59 2023-06-22 01:28:59 FALSE Mementomoristultus
      45 137626383 2023-06-22 01:28:43 2023-06-22 01:28:44 FALSE Mementomoristultus
      46 137626365 2023-06-22 01:27:28 2023-06-22 01:27:29 FALSE Mementomoristultus
      47 137626344 2023-06-22 01:26:20 2023-06-22 01:26:21 FALSE Mementomoristultus
      48 137626336 2023-06-22 01:25:53 2023-06-22 01:25:54 FALSE Mementomoristultus
      49 137626330 2023-06-22 01:25:16 2023-06-22 01:25:16 FALSE Mementomoristultus
      50 137626323 2023-06-22 01:24:34 2023-06-22 01:24:35 FALSE Mementomoristultus
              uid    min_lat    min_lon    max_lat    max_lon comments_count
      1  19648429 42.4327433 -6.9782486 42.4328559 -6.9780026              0
      2  19648429 42.4327498 -6.9765097 42.4328834 -6.9763031              0
      3  19648429 42.4328903 -6.9756364 42.4330040 -6.9754741              0
      4  19648429 43.4488066 -7.8527610 43.4501613 -7.8507456              0
      5  19648429 43.4499647 -7.8526224 43.4500774 -7.8525214              0
      6  19648429 43.4498605 -7.8527232 43.4509926 -7.8497643              0
      7  19648429 43.4509478 -7.8490408 43.4511815 -7.8487310              0
      8  19648429 43.4503112 -7.8491926 43.4506422 -7.8486152              0
      9  19648429 43.4515806 -7.8518012 43.4518359 -7.8513226              0
      10 19648429 43.4517061 -7.8521361 43.4518324 -7.8519759              0
      11 19648429 43.4522220 -7.8526636 43.4525296 -7.8519676              0
      12 19648429 43.4517360 -7.8530077 43.4523902 -7.8521619              0
      13 19648429 43.4520269 -7.8533595 43.4523774 -7.8525364              0
      14 19648429 43.4511797 -7.8532552 43.4515458 -7.8529505              0
      15 19648429 43.4513242 -7.8541611 43.4519930 -7.8538848              0
      16 19648429 43.4516472 -7.8541538 43.4517629 -7.8539604              0
      17 19648429 43.4522560 -7.8541540 43.4527330 -7.8537188              0
      18 19648429 43.4521268 -7.8541540 43.4527162 -7.8527612              0
      19 19648429 43.4526068 -7.8534273 43.4527321 -7.8532516              0
      20 19648429 43.4527765 -7.8531986 43.4529264 -7.8530484              0
      21 19648429 43.4535627 -7.8540733 43.4542773 -7.8533637              0
      22 19648429 43.4536685 -7.8537461 43.4541080 -7.8533637              0
      23 19648429 43.4553224 -7.8532966 43.4560506 -7.8527512              0
      24 19648429 43.4552444 -7.8527283 43.4559984 -7.8521881              0
      25 19648429 43.4550015 -7.8517976 43.4551113 -7.8516693              0
      26 19648429 43.4546616 -7.8518618 43.4551113 -7.8515089              0
      27 19648429 43.4550767 -7.8517039 43.4558127 -7.8502176              0
      28 19648429 43.4507498 -7.8526686 43.4507576 -7.8526659              0
      29 19648429 43.4508942 -7.8531805 43.4511123 -7.8527787              0
      30 19648429 43.4509098 -7.8531698 43.4511123 -7.8527787              0
      31 19648429 43.4463618 -7.8549352 43.4466924 -7.8544243              0
      32 19648429 43.4476405 -7.8528130 43.4510094 -7.8431001              0
      33 19648429 43.3702548 -8.0135855 43.5705121 -7.7441559              1
      34 19648429 43.2978359 -7.6831051 43.2982351 -7.6826753              0
      35 19648429 43.2975390 -7.6837125 43.2983786 -7.6823740              0
      36 19648429 43.2969182 -7.6808522 43.2972142 -7.6803010              0
      37 19648429 43.2945706 -7.6834252 43.2969974 -7.6808524              0
      38 19648429 43.2949139 -7.6815947 43.2964523 -7.6786533              0
      39 19648429 43.2960746 -7.6777508 43.2961005 -7.6773423              0
      40 19648429 43.2959736 -7.6779547 43.2962932 -7.6767778              0
      41 19648429 43.2932307 -7.6797783 43.2968361 -7.6651626              0
      42 19648429 43.2965293 -7.6781078 43.2968480 -7.6768001              0
      43 19648429 42.4365591 -8.0811560 42.4379437 -8.0787144              0
      44 19648429 42.4377503 -8.1221443 42.5539628 -8.0792497              0
      45 19648429 42.4378920 -8.0797572 42.4388115 -8.0785782              0
      46 19648429 42.4384228 -8.0814797 42.4392050 -8.0799395              0
      47 19648429 42.4318442 -8.0737985 42.4319985 -8.0735708              0
      48 19648429 42.4305063 -8.0748481 42.4328356 -8.0731101              0
      49 19648429 42.4305063 -8.0748516 42.4328356 -8.0731101              0
      50 19648429 42.4308621 -8.0757847 42.4321425 -8.0739688              0
         changes_count
      1              5
      2              5
      3              5
      4              2
      5              1
      6              7
      7              1
      8              2
      9              1
      10             5
      11             5
      12             2
      13             2
      14             1
      15             1
      16             3
      17             4
      18             2
      19             1
      20             1
      21            25
      22             1
      23             1
      24             1
      25             3
      26             2
      27             1
      28             1
      29             4
      30             1
      31             1
      32             1
      33             1
      34            18
      35             5
      36             1
      37             1
      38             4
      39             2
      40             5
      41             5
      42             6
      43             4
      44             3
      45            29
      46             5
      47             5
      48             5
      49             3
      50             6
                                                                                        tags
      1  6 tags: changesets_count=150 | comment=18945 | created_by=iD 2.25.2 | host=https...
      2  6 tags: changesets_count=149 | comment=18945 | created_by=iD 2.25.2 | host=https...
      3  6 tags: changesets_count=148 | comment=18945 | created_by=iD 2.25.2 | host=https...
      4  6 tags: changesets_count=144 | comment=11 | created_by=iD 2.25.2 | host=https://...
      5  6 tags: changesets_count=143 | comment=13 | created_by=iD 2.25.2 | host=https://...
      6  6 tags: changesets_count=142 | comment=13 | created_by=iD 2.25.2 | host=https://...
      7  6 tags: changesets_count=141 | comment=13 | created_by=iD 2.25.2 | host=https://...
      8  6 tags: changesets_count=140 | comment=11 | created_by=iD 2.25.2 | host=https://...
      9  7 tags: changesets_count=139 | comment=12 | created_by=iD 2.25.2 | host=https://...
      10 6 tags: changesets_count=138 | comment=13 | created_by=iD 2.25.2 | host=https://...
      11 6 tags: changesets_count=137 | comment=12 | created_by=iD 2.25.2 | host=https://...
      12 6 tags: changesets_count=136 | comment=12 | created_by=iD 2.25.2 | host=https://...
      13 6 tags: changesets_count=135 | comment=12 | created_by=iD 2.25.2 | host=https://...
      14 6 tags: changesets_count=134 | comment=12 | created_by=iD 2.25.2 | host=https://...
      15 6 tags: changesets_count=133 | comment=12 | created_by=iD 2.25.2 | host=https://...
      16 6 tags: changesets_count=132 | comment=12 | created_by=iD 2.25.2 | host=https://...
      17 6 tags: changesets_count=131 | comment=48 | created_by=iD 2.25.2 | host=https://...
      18 6 tags: changesets_count=130 | comment=45 | created_by=iD 2.25.2 | host=https://...
      19 6 tags: changesets_count=129 | comment=45 | created_by=iD 2.25.2 | host=https://...
      20 6 tags: changesets_count=128 | comment=46 | created_by=iD 2.25.2 | host=https://...
      21 6 tags: changesets_count=127 | comment=45 | created_by=iD 2.25.2 | host=https://...
      22 7 tags: changesets_count=126 | comment=45 | created_by=iD 2.25.2 | host=https://...
      23 6 tags: changesets_count=125 | comment=45 | created_by=iD 2.25.2 | host=https://...
      24 6 tags: changesets_count=124 | comment=67 | created_by=iD 2.25.2 | host=https://...
      25 6 tags: changesets_count=123 | comment=56 | created_by=iD 2.25.2 | host=https://...
      26 7 tags: changesets_count=122 | comment=47 | created_by=iD 2.25.2 | host=https://...
      27 6 tags: changesets_count=121 | comment=48 | created_by=iD 2.25.2 | host=https://...
      28 6 tags: changesets_count=120 | comment=56 | created_by=iD 2.25.2 | host=https://...
      29 6 tags: changesets_count=119 | comment=74 | created_by=iD 2.25.2 | host=https://...
      30 6 tags: changesets_count=118 | comment=14 | created_by=iD 2.25.2 | host=https://...
      31 6 tags: changesets_count=117 | comment=18 | created_by=iD 2.25.2 | host=https://...
      32 6 tags: changesets_count=116 | comment=27 | created_by=iD 2.25.2 | host=https://...
      33 6 tags: changesets_count=115 | comment=21 | created_by=iD 2.25.2 | host=https://...
      34 6 tags: changesets_count=114 | comment=22 | created_by=iD 2.25.2 | host=https://...
      35 6 tags: changesets_count=113 | comment=23 | created_by=iD 2.25.2 | host=https://...
      36 6 tags: changesets_count=112 | comment=24 | created_by=iD 2.25.2 | host=https://...
      37 6 tags: changesets_count=111 | comment=26 | created_by=iD 2.25.2 | host=https://...
      38 6 tags: changesets_count=110 | comment=26 | created_by=iD 2.25.2 | host=https://...
      39 6 tags: changesets_count=109 | comment=27 | created_by=iD 2.25.2 | host=https://...
      40 6 tags: changesets_count=108 | comment=79 | created_by=iD 2.25.2 | host=https://...
      41 7 tags: changesets_count=107 | comment=78 | created_by=iD 2.25.2 | host=https://...
      42 6 tags: changesets_count=106 | comment=87 | created_by=iD 2.25.2 | host=https://...
      43 6 tags: changesets_count=105 | comment=87 | created_by=iD 2.25.2 | host=https://...
      44 6 tags: changesets_count=104 | comment=80 | created_by=iD 2.25.2 | host=https://...
      45 6 tags: changesets_count=103 | comment=49 | created_by=iD 2.25.2 | host=https://...
      46 6 tags: changesets_count=102 | comment=42 | created_by=iD 2.25.2 | host=https://...
      47 6 tags: changesets_count=101 | comment=40 | created_by=iD 2.25.2 | host=https://...
      48 6 tags: changesets_count=100 | comment=39 | created_by=iD 2.25.2 | host=https://...
      49 6 tags: changesets_count=99 | comment=38 | created_by=iD 2.25.2 | host=https://w...
      50 6 tags: changesets_count=98 | comment=35 | created_by=iD 2.25.2 | host=https://w...

---

    Code
      print(empty_chaset)
    Output
       [1] id             created_at     closed_at      open           user          
       [6] uid            min_lat        min_lon        max_lat        max_lon       
      [11] comments_count changes_count  tags          
      <0 rows> (or 0-length row.names)

