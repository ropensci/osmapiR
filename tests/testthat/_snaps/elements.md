# osm_read_object works

    Code
      print(x)
    Output
        type       id visible version changeset           timestamp   user     uid
      1 node 35308286    TRUE      15  63949815 2018-10-28 13:07:37 ManelG 2491053
               lat       lon members
      1 42.5189047 2.4565596    NULL
                                                                                       tags
      1 5 tags: ele=2784.66 | name=Pic du Canigou | name:ca=Pic del Canigó | natural=pea...

---

    Code
      print(x)
    Output
        type       id visible version changeset           timestamp     user      uid
      1  way 13073736    TRUE      21 114656477 2021-12-07 11:27:19 jmaspons 11725140
         lat  lon                                                         members
      1 <NA> <NA> 61 nodes: 6771540804, 6771540805, 6771540806, 6957604952, 67...
                                                                                       tags
      1 12 tags: alt_name:ca=Torres de Quart | building=tower | building:levels=4 | buil...

---

    Code
      print(x)
    Output
            type    id visible version changeset           timestamp  user     uid
      1 relation 40581    TRUE      53 135982205 2023-05-11 15:10:18 l2212 1775455
         lat  lon                                                         members
      1 <NA> <NA> 20 members: node/72994199/admin_centre, way/165579897/outer,...
                                                                                       tags
      1 22 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...

# osm_history_object works

    Code
      print(x)
    Output
         type       id visible version changeset           timestamp     user     uid
      1  node 35308286    TRUE       1    292412 2007-09-02 14:55:33  Skywave   10927
      2  node 35308286    TRUE       2     39997 2007-12-02 19:28:54  Skywave   10927
      3  node 35308286    TRUE       3     39997 2007-12-02 19:29:01  Skywave   10927
      4  node 35308286    TRUE       4    131335 2007-12-06 21:08:56  Skywave   10927
      5  node 35308286    TRUE       5    544716 2008-01-05 17:55:28  Skywave   10927
      6  node 35308286    TRUE       6    433656 2008-08-28 00:14:47  Skywave   10927
      7  node 35308286    TRUE       7     61302 2008-10-04 20:55:22  Skywave   10927
      8  node 35308286    TRUE       8    731089 2009-03-03 20:23:52   Eric S   45284
      9  node 35308286    TRUE       9   4188890 2010-03-21 10:17:52 petrovsk   90394
      10 node 35308286    TRUE      10   5978159 2010-10-07 13:28:57  Skywave   10927
      11 node 35308286    TRUE      11   5980618 2010-10-07 19:16:33  Skywave   10927
      12 node 35308286    TRUE      12   9467521 2011-10-04 08:48:09  WernerP  315015
      13 node 35308286    TRUE      13  13343795 2012-10-03 07:49:42      FMB  316958
      14 node 35308286    TRUE      14  18407951 2013-10-17 18:21:18    janes  428521
      15 node 35308286    TRUE      15  63949815 2018-10-28 13:07:37   ManelG 2491053
                lat       lon members
      1  42.5178841 2.4567366    NULL
      2  42.5116144 2.4580973    NULL
      3  42.5184471 2.4580973    NULL
      4  42.5184471 2.4580973    NULL
      5  42.5184471 2.4580973    NULL
      6  42.5184481 2.4580929    NULL
      7  42.5187840 2.4567709    NULL
      8  42.5187840 2.4567709    NULL
      9  42.5189368 2.4566062    NULL
      10 42.5189176 2.4565525    NULL
      11 42.5189047 2.4565596    NULL
      12 42.5189047 2.4565596    NULL
      13 42.5189047 2.4565596    NULL
      14 42.5189047 2.4565596    NULL
      15 42.5189047 2.4565596    NULL
                                                                                        tags
      1  5 tags: altitude=2784,66 | created_by=Potlatch alpha | ele=2784,66 | name=Pic du...
      2  5 tags: altitude=2784,66 | created_by=Potlatch 0.5d | ele=2784,66 | name=Pic du ...
      3  5 tags: altitude=2784,66 | created_by=Potlatch 0.5d | ele=2784,66 | name=Pic du ...
      4  4 tags: created_by=Potlatch 0.5d | ele=2784,66 | name=Pic du Canigou | natural=p...
      5  5 tags: created_by=Potlatch 0.5d | ele=2784,66 | name=Pic du Canigou | name:ca=P...
      6  6 tags: created_by=Potlatch 0.10b | ele=2784,66 | elevation=2784,66 meters | nam...
      7  6 tags: created_by=Potlatch 0.10c | ele=2784,66 | elevation=2784,66 meters | nam...
      8  4 tags: ele=2784,66 | name=Pic du Canigou | name:ca=Puig del Canigó | natural=pe...
      9  4 tags: ele=2784,66 | name=Pic du Canigou | name:ca=Puig del Canigó | natural=pe...
      10 4 tags: ele=2784,66 | name=Pic du Canigou | name:ca=Puig del Canigó | natural=pe...
      11 4 tags: ele=2784,66 | name=Pic du Canigou | name:ca=Puig del Canigó | natural=pe...
      12 4 tags: ele=2784.66 | name=Pic du Canigou | name:ca=Puig del Canigó | natural=pe...
      13 4 tags: ele=2784.66 | name=Pic du Canigou | name:ca=Pica del Canigó | natural=pe...
      14 4 tags: ele=2784.66 | name=Pic du Canigou | name:ca=Pic del Canigó | natural=pea...
      15 5 tags: ele=2784.66 | name=Pic du Canigou | name:ca=Pic del Canigó | natural=pea...

---

    Code
      print(x)
    Output
         type       id visible version changeset           timestamp
      1   way 13073736    TRUE       1    545236 2007-11-17 22:30:37
      2   way 13073736    TRUE       2    270381 2007-12-12 11:13:02
      3   way 13073736    TRUE       3   9724157 2011-11-02 17:55:59
      4   way 13073736    TRUE       4  12745372 2012-08-15 23:09:48
      5   way 13073736    TRUE       5  16749437 2013-06-29 10:06:43
      6   way 13073736    TRUE       6  24765034 2014-08-15 11:27:50
      7   way 13073736    TRUE       7  35855685 2015-12-09 22:11:41
      8   way 13073736    TRUE       8  44486884 2016-12-18 10:12:22
      9   way 13073736    TRUE       9  49340277 2017-06-07 15:51:46
      10  way 13073736    TRUE      10  55126121 2018-01-03 11:23:29
      11  way 13073736    TRUE      11  63379426 2018-10-10 12:39:54
      12  way 13073736    TRUE      12  74075591 2019-09-04 09:57:46
      13  way 13073736    TRUE      13  74385011 2019-09-12 09:40:46
      14  way 13073736    TRUE      14  75680406 2019-10-14 17:15:24
      15  way 13073736    TRUE      15  76002470 2019-10-21 14:21:08
      16  way 13073736    TRUE      16  76811325 2019-11-08 13:10:11
      17  way 13073736    TRUE      17  77447443 2019-11-22 22:35:38
      18  way 13073736    TRUE      18  86534163 2020-06-11 21:02:34
      19  way 13073736    TRUE      19  92154431 2020-10-08 07:42:45
      20  way 13073736    TRUE      20  92482152 2020-10-14 15:49:32
      21  way 13073736    TRUE      21 114656477 2021-12-07 11:27:19
                       user      uid  lat  lon
      1         ivansanchez     5265 <NA> <NA>
      2                jgui     8016 <NA> <NA>
      3               morsi   139580 <NA> <NA>
      4             rubensd   472193 <NA> <NA>
      5          pere prlpz  1513644 <NA> <NA>
      6              qientx  2258523 <NA> <NA>
      7            gorogoro  2937174 <NA> <NA>
      8       Леонид Библис  4979200 <NA> <NA>
      9       Marion_Moseby  5379200 <NA> <NA>
      10           av223119   190711 <NA> <NA>
      11      Baxe Nafarroa  6672338 <NA> <NA>
      12     homocomputeris  3777620 <NA> <NA>
      13            rubensd   472193 <NA> <NA>
      14      CapitanColoto  8940402 <NA> <NA>
      15      CapitanColoto  8940402 <NA> <NA>
      16 editemapes_imports 10063912 <NA> <NA>
      17      Georg_M_Weber 10241965 <NA> <NA>
      18          MikelCalo 11126976 <NA> <NA>
      19       Emilio Gomez     2904 <NA> <NA>
      20           jmaspons 11725140 <NA> <NA>
      21           jmaspons 11725140 <NA> <NA>
                                                                 members
      1  17 nodes: 120303676, 120303671, 120303597, 120303605, 120303...
      2  17 nodes: 120303676, 120303671, 120303597, 120303605, 120303...
      3  17 nodes: 120303676, 120303671, 120303597, 120303605, 120303...
      4  17 nodes: 120303676, 120303671, 120303597, 120303605, 120303...
      5  17 nodes: 120303676, 120303671, 120303597, 120303605, 120303...
      6  19 nodes: 120303676, 120303671, 120303597, 3017814863, 30178...
      7  19 nodes: 120303676, 120303671, 120303597, 3017814863, 30178...
      8  19 nodes: 120303676, 120303671, 120303597, 3017814863, 30178...
      9  20 nodes: 120303676, 120303671, 120303597, 3017814863, 30178...
      10 20 nodes: 120303676, 120303671, 120303597, 3017814863, 30178...
      11 20 nodes: 120303676, 120303671, 120303597, 3017814863, 30178...
      12 34 nodes: 120303676, 120303671, 120303597, 4902243082, 12030...
      13 34 nodes: 120303676, 120303671, 120303597, 6790061967, 12030...
      14 34 nodes: 120303676, 120303671, 120303597, 6790061967, 12030...
      15 34 nodes: 120303676, 120303671, 120303597, 6790061967, 12030...
      16 59 nodes: 6771540804, 6771540805, 6771540806, 120303605, 695...
      17 60 nodes: 6771540804, 6771540805, 6771540806, 6957604952, 67...
      18 61 nodes: 6771540804, 6771540805, 6771540806, 6957604952, 67...
      19 61 nodes: 6771540804, 6771540805, 6771540806, 6957604952, 67...
      20 61 nodes: 6771540804, 6771540805, 6771540806, 6957604952, 67...
      21 61 nodes: 6771540804, 6771540805, 6771540806, 6957604952, 67...
                                                                                        tags
      1  4 tags: created_by=Potlatch alpha | historic=castle | name=Torres de Quart | tou...
      2                                   2 tags: building=tower | created_by=Potlatch alpha
      3                       3 tags: building=tower | historic=tower | name=Torres de Quart
      4  4 tags: building=tower | historic=tower | name=Torres de Quart | tourism=attract...
      5  5 tags: building=tower | historic=tower | name=Torres de Quart | tourism=attract...
      6  5 tags: building=tower | historic=tower | name=Torres de Quart | tourism=attract...
      7  7 tags: building=tower | building:material=stone | height=34 | historic=tower | ...
      8  8 tags: building=tower | building:material=stone | height=34 | historic=tower | ...
      9  8 tags: building=tower | building:material=stone | height=34 | historic=tower | ...
      10 9 tags: building=tower | building:material=stone | height=34 | historic=tower | ...
      11 8 tags: building=tower | building:material=stone | height=34 | historic=city_gat...
      12 11 tags: alt_name:ca=Torres de Quart | building=tower | building:material=stone ...
      13 11 tags: alt_name:ca=Torres de Quart | building=tower | building:material=stone ...
      14 10 tags: alt_name:ca=Torres de Quart | building=tower | building:material=stone ...
      15 8 tags: alt_name:ca=Torres de Quart | building=tower | building:material=stone |...
      16 9 tags: alt_name:ca=Torres de Quart | building=tower | building:levels=4 | build...
      17 9 tags: alt_name:ca=Torres de Quart | building=tower | building:levels=4 | build...
      18 9 tags: alt_name:ca=Torres de Quart | building=tower | building:levels=4 | build...
      19 10 tags: alt_name:ca=Torres de Quart | building=tower | building:levels=4 | buil...
      20 11 tags: alt_name:ca=Torres de Quart | building=tower | building:levels=4 | buil...
      21 12 tags: alt_name:ca=Torres de Quart | building=tower | building:levels=4 | buil...

---

    Code
      print(x)
    Output
             type    id visible version changeset           timestamp
      1  relation 40581    TRUE       1    568221 2008-10-25 05:35:48
      2  relation 40581    TRUE       2  11714681 2012-05-27 12:05:32
      3  relation 40581    TRUE       3  11746232 2012-05-30 08:57:05
      4  relation 40581    TRUE       4  11837646 2012-06-08 18:01:23
      5  relation 40581    TRUE       5  11839138 2012-06-08 20:25:11
      6  relation 40581    TRUE       6  11838130 2012-06-08 20:51:42
      7  relation 40581    TRUE       7  11980761 2012-06-22 16:39:50
      8  relation 40581    TRUE       8  18369633 2013-10-15 14:16:51
      9  relation 40581    TRUE       9  18654817 2013-11-01 17:02:49
      10 relation 40581    TRUE      10  19864829 2014-01-07 15:19:27
      11 relation 40581    TRUE      11  19893801 2014-01-09 03:42:07
      12 relation 40581    TRUE      12  19904315 2014-01-09 17:49:09
      13 relation 40581    TRUE      13  19909641 2014-01-09 23:03:35
      14 relation 40581    TRUE      14  20324867 2014-02-01 21:58:59
      15 relation 40581    TRUE      15  20783674 2014-02-26 03:52:17
      16 relation 40581    TRUE      16  20783699 2014-02-26 03:56:58
      17 relation 40581    TRUE      17  25024005 2014-08-26 10:32:56
      18 relation 40581    TRUE      18  31684773 2015-06-03 07:36:51
      19 relation 40581    TRUE      19  40885359 2016-07-20 01:19:33
      20 relation 40581    TRUE      20  41147692 2016-07-31 15:16:38
      21 relation 40581    TRUE      21  41156298 2016-08-01 00:24:38
      22 relation 40581    TRUE      22  41162305 2016-08-01 09:03:50
      23 relation 40581    TRUE      23  41206301 2016-08-03 03:36:05
      24 relation 40581    TRUE      24  41212009 2016-08-03 11:16:49
      25 relation 40581    TRUE      25  41214566 2016-08-03 13:21:37
      26 relation 40581    TRUE      26  41214925 2016-08-03 13:40:57
      27 relation 40581    TRUE      27  41215848 2016-08-03 14:26:01
      28 relation 40581    TRUE      28  41216353 2016-08-03 14:50:48
      29 relation 40581    TRUE      29  41217947 2016-08-03 16:12:29
      30 relation 40581    TRUE      30  41221606 2016-08-03 18:54:32
      31 relation 40581    TRUE      31  41223121 2016-08-03 19:58:40
      32 relation 40581    TRUE      32  41223747 2016-08-03 20:26:15
      33 relation 40581    TRUE      33  41852822 2016-09-01 16:28:22
      34 relation 40581    TRUE      34  41869838 2016-09-02 14:05:24
      35 relation 40581    TRUE      35  41889305 2016-09-03 13:57:10
      36 relation 40581    TRUE      36  41891270 2016-09-03 15:50:28
      37 relation 40581    TRUE      37  43712169 2016-11-16 21:48:53
      38 relation 40581    TRUE      38  43742170 2016-11-17 20:03:24
      39 relation 40581    TRUE      39  43750924 2016-11-18 01:09:29
      40 relation 40581    TRUE      40  43854877 2016-11-21 19:18:40
      41 relation 40581    TRUE      41  43856068 2016-11-21 20:25:39
      42 relation 40581    TRUE      42  44927268 2017-01-05 15:17:57
      43 relation 40581    TRUE      43  51567307 2017-08-30 08:28:01
      44 relation 40581    TRUE      44  51609472 2017-08-31 10:50:49
      45 relation 40581    TRUE      45  66542092 2019-01-22 15:54:20
      46 relation 40581    TRUE      46  66543985 2019-01-22 17:01:40
      47 relation 40581    TRUE      47 107730109 2021-07-10 00:32:19
      48 relation 40581    TRUE      48 111244602 2021-09-15 13:05:46
      49 relation 40581    TRUE      49 115229896 2021-12-22 00:20:00
      50 relation 40581    TRUE      50 115501973 2021-12-29 06:50:31
      51 relation 40581    TRUE      51 118611187 2022-03-17 21:13:14
      52 relation 40581    TRUE      52 124236416 2022-07-29 15:11:43
      53 relation 40581    TRUE      53 135982205 2023-05-11 15:10:18
                       user      uid  lat  lon
      1              simone      137 <NA> <NA>
      2               lerks   188477 <NA> <NA>
      3               lerks   188477 <NA> <NA>
      4             sabas88   454589 <NA> <NA>
      5               lerks   188477 <NA> <NA>
      6               lerks   188477 <NA> <NA>
      7             sabas88   454589 <NA> <NA>
      8               l2212  1775455 <NA> <NA>
      9               l2212  1775455 <NA> <NA>
      10           Paoletto   170997 <NA> <NA>
      11              l2212  1775455 <NA> <NA>
      12           Paoletto   170997 <NA> <NA>
      13              l2212  1775455 <NA> <NA>
      14       mcheckimport   893327 <NA> <NA>
      15              l2212  1775455 <NA> <NA>
      16              l2212  1775455 <NA> <NA>
      17           jmontane    28773 <NA> <NA>
      18             simone      137 <NA> <NA>
      19              fayor   743479 <NA> <NA>
      20              l2212  1775455 <NA> <NA>
      21              fayor   743479 <NA> <NA>
      22              l2212  1775455 <NA> <NA>
      23              fayor   743479 <NA> <NA>
      24              l2212  1775455 <NA> <NA>
      25              fayor   743479 <NA> <NA>
      26              l2212  1775455 <NA> <NA>
      27              fayor   743479 <NA> <NA>
      28              l2212  1775455 <NA> <NA>
      29              fayor   743479 <NA> <NA>
      30              l2212  1775455 <NA> <NA>
      31              fayor   743479 <NA> <NA>
      32              l2212  1775455 <NA> <NA>
      33              fayor   743479 <NA> <NA>
      34              l2212  1775455 <NA> <NA>
      35              fayor   743479 <NA> <NA>
      36 SomeoneElse_Revert  1778799 <NA> <NA>
      37           GBicozzo  4853063 <NA> <NA>
      38 SomeoneElse_Revert  1778799 <NA> <NA>
      39            nyuriks   339581 <NA> <NA>
      40           GBicozzo  4853063 <NA> <NA>
      41 SomeoneElse_Revert  1778799 <NA> <NA>
      42             dan980  1240942 <NA> <NA>
      43           osm_fede  5631066 <NA> <NA>
      44        Garmin-User   177389 <NA> <NA>
      45            s141739    25132 <NA> <NA>
      46        Garmin-User   177389 <NA> <NA>
      47              Olyon  1443767 <NA> <NA>
      48           nilogian   673435 <NA> <NA>
      49             Yamílo 11332999 <NA> <NA>
      50          user_5359     5359 <NA> <NA>
      51     Gianfranco2014  1928626 <NA> <NA>
      52           ftrebien   401472 <NA> <NA>
      53              l2212  1775455 <NA> <NA>
                                                                 members
      1  7 members: way/27966652/, way/27966705/, way/27966846/, way/...
      2  7 members: way/27966652/outer, way/27966705/outer, way/27966...
      3  7 members: way/27966652/outer, way/27966705/outer, way/27966...
      4  14 members: way/27966652/outer, way/27966705/outer, way/2796...
      5  13 members: way/27966652/outer, way/27966846/outer, way/2796...
      6  13 members: way/27966846/outer, way/27966652/outer, way/1666...
      7  13 members: way/166623039/outer, way/165579897/outer, way/11...
      8  13 members: way/166623039/outer, way/165579897/outer, way/11...
      9  13 members: way/166623039/outer, way/165579897/outer, way/11...
      10 13 members: way/166623039/outer, way/165579897/outer, way/11...
      11 13 members: way/166623039/outer, way/165579897/outer, way/11...
      12 13 members: way/166623039/outer, way/165579897/outer, way/11...
      13 13 members: way/166623039/outer, way/165579897/outer, way/11...
      14 14 members: way/166623039/outer, way/165579897/outer, way/11...
      15 14 members: way/166623039/outer, way/165579897/outer, way/11...
      16 14 members: way/166623039/outer, way/165579897/outer, way/11...
      17 14 members: way/166623039/outer, way/165579897/outer, way/11...
      18 14 members: way/166623039/outer, way/165579897/outer, way/11...
      19 14 members: way/166623039/outer, way/168606149/outer, way/16...
      20 14 members: way/166623039/outer, way/165579897/outer, way/11...
      21 14 members: way/166623039/outer, way/168606149/outer, way/16...
      22 14 members: way/166623039/outer, way/168606149/outer, way/16...
      23 14 members: way/166623039/outer, way/168606149/outer, way/16...
      24 14 members: way/166623039/outer, way/168606149/outer, way/16...
      25 14 members: way/166623039/outer, way/168606149/outer, way/16...
      26 14 members: way/166623039/outer, way/168606149/outer, way/16...
      27 14 members: way/166623039/outer, way/168606149/outer, way/16...
      28 14 members: way/166623039/outer, way/168606149/outer, way/16...
      29 14 members: way/166623039/outer, way/168606149/outer, way/16...
      30 14 members: way/166623039/outer, way/168606149/outer, way/16...
      31 14 members: way/166623039/outer, way/168606149/outer, way/16...
      32 14 members: way/166623039/outer, way/168606149/outer, way/16...
      33 14 members: way/166623039/outer, way/168606149/outer, way/16...
      34 14 members: way/166623039/outer, way/168606149/outer, way/16...
      35 14 members: way/166623039/outer, way/168606149/outer, way/16...
      36 14 members: way/166623039/outer, way/168606149/outer, way/16...
      37 14 members: way/166623039/outer, way/168606149/outer, way/16...
      38 14 members: way/166623039/outer, way/168606149/outer, way/16...
      39 14 members: way/166623039/outer, way/168606149/outer, way/16...
      40 14 members: way/166623039/outer, way/168606149/outer, way/16...
      41 14 members: way/166623039/outer, way/168606149/outer, way/16...
      42 15 members: way/166623039/outer, way/168606149/outer, way/16...
      43 15 members: way/166623039/outer, way/168606149/outer, way/16...
      44 15 members: way/166623039/outer, way/168606149/outer, way/16...
      45 15 members: way/166623039/outer, way/168606149/outer, way/16...
      46 15 members: way/166623039/outer, way/168606149/outer, way/16...
      47 16 members: way/165579897/outer, way/963065356/outer, way/16...
      48 18 members: node/72994199/admin_centre, way/165579897/outer,...
      49 18 members: node/72994199/admin_centre, way/165579897/outer,...
      50 18 members: node/72994199/admin_centre, way/165579897/outer,...
      51 18 members: node/72994199/admin_centre, way/165579897/outer,...
      52 20 members: node/72994199/admin_centre, way/165579897/outer,...
      53 20 members: node/72994199/admin_centre, way/165579897/outer,...
                                                                                        tags
      1  6 tags: admin_level=8 | boundary=administrative | created_by=ShapeToOSM - Laser ...
      2  5 tags: admin_level=8 | boundary=administrative | name=Alghero | source=Based on...
      3  7 tags: admin_level=8 | boundary=administrative | name=Alghero | ref:catasto=A19...
      4  7 tags: admin_level=8 | boundary=administrative | name=Alghero | ref:catasto=A19...
      5  7 tags: admin_level=8 | boundary=administrative | name=Alghero | ref:catasto=A19...
      6  7 tags: admin_level=8 | boundary=administrative | name=Alghero | ref:catasto=A19...
      7  7 tags: admin_level=8 | boundary=administrative | name=Alghero | ref:catasto=A19...
      8  10 tags: admin_level=8 | boundary=administrative | name=L'Alguer-Alghero | name:...
      9  11 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      10 12 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      11 11 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      12 12 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      13 11 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      14 11 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      15 13 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      16 15 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      17 15 tags: admin_level=8 | boundary=administrative | name=l'Alguer/Alghero | name:...
      18 13 tags: admin_level=8 | boundary=administrative | name=l'Alguer/Alghero | name:...
      19 13 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      20 13 tags: admin_level=8 | boundary=administrative | name=l'Alguer/Alghero | name:...
      21 13 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      22 14 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      23 13 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      24 14 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      25 13 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      26 14 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      27 13 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      28 14 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      29 13 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      30 14 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      31 13 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      32 14 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      33 14 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      34 14 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      35 14 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      36 14 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      37 14 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      38 14 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      39 15 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      40 15 tags: admin_level=8 | boundary=administrative | name=Alghero | name:ca=L'Algu...
      41 15 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      42 15 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      43 13 tags: admin_level=8 | name=L'Alguer/Alghero | name:ca=L'Alguer | name:co=L'Al...
      44 15 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...
      45 15 tags: admin_level=8 | name=Alghero - L'Alguer | name:ca=L'Alguer | name:co=L'...
      46 15 tags: admin_level=8 | boundary=administrative | name=Alghero - L'Alguer | nam...
      47 15 tags: admin_level=8 | boundary=administrative | name=Alghero - L'Alguer | nam...
      48 15 tags: admin_level=8 | boundary=administrative | name=Alghero - L'Alguer | nam...
      49 24 tags: admin_level=8 | boundary=administrative | name=Alghero - L'Alguer | nam...
      50 21 tags: admin_level=8 | boundary=administrative | name=Alghero - L'Alguer | nam...
      51 22 tags: admin_level=8 | boundary=administrative | name=Alghero - L'Alguer | nam...
      52 22 tags: admin_level=8 | boundary=administrative | name=Alghero - L'Alguer | nam...
      53 22 tags: admin_level=8 | boundary=administrative | name=L'Alguer/Alghero | name:...

# osm_version_object works

    Code
      print(x)
    Output
        type       id visible version changeset           timestamp    user   uid
      1 node 35308286    TRUE       1    292412 2007-09-02 14:55:33 Skywave 10927
               lat       lon members
      1 42.5178841 2.4567366    NULL
                                                                                       tags
      1 5 tags: altitude=2784,66 | created_by=Potlatch alpha | ele=2784,66 | name=Pic du...

---

    Code
      print(x)
    Output
        type       id visible version changeset           timestamp user  uid  lat
      1  way 13073736    TRUE       2    270381 2007-12-12 11:13:02 jgui 8016 <NA>
         lon                                                         members
      1 <NA> 17 nodes: 120303676, 120303671, 120303597, 120303605, 120303...
                                                      tags
      1 2 tags: building=tower | created_by=Potlatch alpha

---

    Code
      print(x)
    Output
            type    id visible version changeset           timestamp  user    uid
      1 relation 40581    TRUE       3  11746232 2012-05-30 08:57:05 lerks 188477
         lat  lon                                                         members
      1 <NA> <NA> 7 members: way/27966652/outer, way/27966705/outer, way/27966...
                                                                                       tags
      1 7 tags: admin_level=8 | boundary=administrative | name=Alghero | ref:catasto=A19...

# osm_fetch_objects works

    Code
      print(x)
    Output
        type         id visible version changeset           timestamp     user
      1 node   35308286    TRUE      15  63949815 2018-10-28 13:07:37   ManelG
      2 node 1935675367    TRUE      13 113921323 2021-11-17 23:47:45 Jordi MF
            uid        lat        lon members
      1 2491053 42.5189047  2.4565596    NULL
      2 8278438 38.8326220 -0.4063146    NULL
                                                                                       tags
      1 5 tags: ele=2784.66 | name=Pic du Canigou | name:ca=Pic del Canigó | natural=pea...
      2                            3 tags: ele=1105 | name=Alt de Benicadell | natural=peak

---

    Code
      print(x)
    Output
        type        id visible version changeset           timestamp     user
      1  way  13073736    TRUE      21 114656477 2021-12-07 11:27:19 jmaspons
      2  way 235744929    TRUE       7 115317958 2021-12-24 03:46:41 jmaspons
             uid  lat  lon
      1 11725140 <NA> <NA>
      2 11725140 <NA> <NA>
                                                                members
      1 61 nodes: 6771540804, 6771540805, 6771540806, 6957604952, 67...
      2 5 nodes: 2438033107, 2438033109, 2992282983, 2992282984, 243...
                                                                                       tags
      1 12 tags: alt_name:ca=Torres de Quart | building=tower | building:levels=4 | buil...
      2 9 tags: architect=Carme Fiol | barrier=wall | historic=memorial | inscription=Al...

---

    Code
      print(x)
    Output
        osm_type    osm_id visible version changeset           timestamp     user
      1      way  13073736    TRUE      21 114656477 2021-12-07 11:27:19 jmaspons
      2      way 235744929    TRUE       7 115317958 2021-12-24 03:46:41 jmaspons
             uid  lat  lon
      1 11725140 <NA> <NA>
      2 11725140 <NA> <NA>
                                                                members
      1 61 nodes: 6771540804, 6771540805, 6771540806, 6957604952, 67...
      2 5 nodes: 2438033107, 2438033109, 2992282983, 2992282984, 243...
            alt_name:ca  architect barrier building building:levels building:material
      1 Torres de Quart       <NA>    <NA>    tower               4             stone
      2            <NA> Carme Fiol    wall     <NA>            <NA>              <NA>
        height  historic
      1     34 city_gate
      2   <NA>  memorial
                                                                                                       inscription
      1                                                                                                       <NA>
      2 Al fossar de les moreres no s'hi enterra cap traïdor;fins perdent nostres banderes serà l'urna de l'honor.
                         name               name:ca        name:es      name:ru
      1       Torres de Quart       Torres de Quart Porta de Quart Башни Куарта
      2 Fossar de les Moreres Fossar de les Moreres           <NA>         <NA>
        start_date wikidata                wikipedia
      1       <NA> Q2343754        ca:Porta de Quart
      2       1989 Q2749521 ca:Fossar de les Moreres

---

    Code
      print(x)
    Output
            type     id visible version changeset           timestamp       user
      1 relation  40581    TRUE       3  11746232 2012-05-30 08:57:05      lerks
      2 relation 341530    TRUE       1   3257189 2009-11-30 16:28:23 balrog-kun
           uid  lat  lon
      1 188477 <NA> <NA>
      2  20587 <NA> <NA>
                                                                members
      1 7 members: way/27966652/outer, way/27966705/outer, way/27966...
      2 16 members: way/45335182/, way/45335184/, way/45335186/, way...
                                                                                       tags
      1 7 tags: admin_level=8 | boundary=administrative | name=Alghero | ref:catasto=A19...
      2 12 tags: admin_level=8 | boundary=administrative | idee:name=Fraga | ine:municip...

# osm_relations_object works

    Code
      print(x)
    Output
            type      id visible version changeset           timestamp
      1 relation  347424    TRUE      15 135030675 2023-04-17 19:56:44
      2 relation 1692442    TRUE       8 102509369 2021-04-07 23:06:52
                     user     uid  lat  lon
      1 Hugoren Martinako 3392826 <NA> <NA>
      2          arte2002  662113 <NA> <NA>
                                                                members
      1 10 members: way/45365865/outer, way/45330518/outer, way/4537...
      2 34 members: way/45372121/outer, way/45365895/outer, way/4536...
                                                                                       tags
      1 15 tags: admin_level=8 | boundary=administrative | idee:name=Alcoi | ine:municip...
      2 13 tags: admin_level=7 | alt_name=Alcoià | alt_name:es=Hoya de Alcoy | boundary=...

---

    Code
      print(x)
    Output
            type      id visible version changeset           timestamp     user
      1 relation 5524720    TRUE      35 135819835 2023-05-07 16:51:26 jmaspons
             uid  lat  lon
      1 11725140 <NA> <NA>
                                                                members
      1 166 members: way/1054059258/, way/372003030/, way/43054345/,...
                                                                                       tags
      1 9 tags: distance=62.65 | name=GR 179 Sender dels Maquis | network=nwn | operator...

---

    Code
      print(x)
    Output
            type       id visible version changeset           timestamp     user
      1 relation   349012    TRUE     104 133498794 2023-03-10 00:12:38 arte2002
      2 relation 11739086    TRUE      98 134555232 2023-04-05 22:06:24 Jordi MF
            uid  lat  lon
      1  662113 <NA> <NA>
      2 8278438 <NA> <NA>
                                                                members
      1 388 members: node/21323935/admin_centre, way/86411973/outer,...
      2 1028 members: node/34105607/admin_centre, node/8000963555/la...
                                                                                       tags
      1 35 tags: admin_level=6 | alt_name:gl=Alacante | border_type=province | boundary=...
      2 54 tags: alt_name=País Valencià | alt_name:ca=País Valencià | boundary=political...

# osm_ways_node works

    Code
      print(ways_node)
    Output
        type        id visible version changeset           timestamp          user
      1  way 215647946    TRUE       2  15632492 2013-04-06 21:14:46        Pinpin
      2  way 242517580    TRUE       4 120428934 2022-05-01 17:06:19 RedfishTheCat
      3  way 656589709    TRUE       2 113253385 2021-11-01 20:20:52      jmaspons
             uid  lat  lon
      1     1685 <NA> <NA>
      2 10564232 <NA> <NA>
      3 11725140 <NA> <NA>
                                                                members
      1 7 nodes: 940255814, 940255832, 940255835, 940255464, 3530828...
      2 203 nodes: 35308286, 1853967143, 302096532, 302096535, 52262...
      3 26 nodes: 877753155, 877753159, 877753191, 877753195, 877753...
                                                                                       tags
      1 3 tags: admin_level=8 | boundary=administrative | source=cadastre-dgi-fr source ...
      2 5 tags: highway=path | sac_scale=mountain_hiking | surface=gravel | trail_visibi...
      3                       3 tags: highway=path | sac_scale=alpine_hiking | surface=rock

# osm_full_object works

    Code
      print(x)
    Output
         type         id visible version changeset           timestamp
      1  node 4856486143    TRUE       2  86534163 2020-06-11 21:02:34
      2  node 4902243087    TRUE       3  76811325 2019-11-08 13:10:11
      3  node 4902243088    TRUE       3  76811325 2019-11-08 13:10:11
      4  node 6771540792    TRUE       2  77447443 2019-11-22 22:35:38
      5  node 6771540793    TRUE       2  77447443 2019-11-22 22:35:38
      6  node 6771540804    TRUE       2  76811325 2019-11-08 13:10:11
      7  node 6771540805    TRUE       2  76811325 2019-11-08 13:10:11
      8  node 6771540806    TRUE       2  76811325 2019-11-08 13:10:11
      9  node 6771540812    TRUE       2  76811325 2019-11-08 13:10:11
      10 node 6790061967    TRUE       2  76811325 2019-11-08 13:10:11
      11 node 6957604940    TRUE       1  76811325 2019-11-08 13:10:11
      12 node 6957604941    TRUE       1  76811325 2019-11-08 13:10:11
      13 node 6957604951    TRUE       1  76811325 2019-11-08 13:10:11
      14 node 6957604952    TRUE       2  77447443 2019-11-22 22:35:38
      15 node 6957604954    TRUE       1  76811325 2019-11-08 13:10:11
      16 node 6957604955    TRUE       1  76811325 2019-11-08 13:10:11
      17 node 6957604959    TRUE       1  76811325 2019-11-08 13:10:11
      18 node 6957604960    TRUE       1  76811325 2019-11-08 13:10:11
      19 node 6957604961    TRUE       1  76811325 2019-11-08 13:10:11
      20 node 6957604962    TRUE       1  76811325 2019-11-08 13:10:11
      21 node 6957604963    TRUE       1  76811325 2019-11-08 13:10:11
      22 node 6957604964    TRUE       1  76811325 2019-11-08 13:10:11
      23 node 6957604965    TRUE       1  76811325 2019-11-08 13:10:11
      24 node 6957604966    TRUE       1  76811325 2019-11-08 13:10:11
      25 node 6957604967    TRUE       1  76811325 2019-11-08 13:10:11
      26 node 6957604968    TRUE       1  76811325 2019-11-08 13:10:11
      27 node 6957604969    TRUE       1  76811325 2019-11-08 13:10:11
      28 node 6957604972    TRUE       1  76811325 2019-11-08 13:10:11
      29 node 6957604973    TRUE       1  76811325 2019-11-08 13:10:11
      30 node 6957604974    TRUE       1  76811325 2019-11-08 13:10:11
      31 node 6957604975    TRUE       1  76811325 2019-11-08 13:10:11
      32 node 6957604977    TRUE       1  76811325 2019-11-08 13:10:11
      33 node 6957604979    TRUE       1  76811325 2019-11-08 13:10:11
      34 node 6957604980    TRUE       1  76811325 2019-11-08 13:10:11
      35 node 6957604981    TRUE       1  76811325 2019-11-08 13:10:11
      36 node 6957604982    TRUE       1  76811325 2019-11-08 13:10:11
      37 node 6957604983    TRUE       1  76811325 2019-11-08 13:10:11
      38 node 6957604984    TRUE       1  76811325 2019-11-08 13:10:11
      39 node 6957611385    TRUE       1  76811325 2019-11-08 13:10:11
      40 node 6957611387    TRUE       1  76811325 2019-11-08 13:10:11
      41 node 6957611388    TRUE       1  76811325 2019-11-08 13:10:11
      42 node 6957611389    TRUE       1  76811325 2019-11-08 13:10:11
      43 node 6957611391    TRUE       1  76811325 2019-11-08 13:10:11
      44 node 6957611392    TRUE       1  76811325 2019-11-08 13:10:11
      45 node 6957611397    TRUE       1  76811325 2019-11-08 13:10:11
      46 node 6957611399    TRUE       1  76811325 2019-11-08 13:10:11
      47 node 6957611401    TRUE       1  76811325 2019-11-08 13:10:11
      48 node 6957611402    TRUE       1  76811325 2019-11-08 13:10:11
      49 node 6957611404    TRUE       1  76811325 2019-11-08 13:10:11
      50 node 6957611405    TRUE       1  76811325 2019-11-08 13:10:11
      51 node 6957611406    TRUE       1  76811325 2019-11-08 13:10:11
      52 node 6957611407    TRUE       1  76811325 2019-11-08 13:10:11
      53 node 6957611408    TRUE       1  76811325 2019-11-08 13:10:11
      54 node 6957611410    TRUE       1  76811325 2019-11-08 13:10:11
      55 node 6957611412    TRUE       1  76811325 2019-11-08 13:10:11
      56 node 6957611414    TRUE       1  76811325 2019-11-08 13:10:11
      57 node 6957611416    TRUE       1  76811325 2019-11-08 13:10:11
      58 node 6957611417    TRUE       1  76811325 2019-11-08 13:10:11
      59 node 6957611418    TRUE       1  76811325 2019-11-08 13:10:11
      60 node 6957611421    TRUE       1  76811325 2019-11-08 13:10:11
      61  way   13073736    TRUE      21 114656477 2021-12-07 11:27:19
                       user      uid        lat        lon
      1           MikelCalo 11126976 39.4760324 -0.3838247
      2  editemapes_imports 10063912 39.4762336 -0.3837994
      3  editemapes_imports 10063912 39.4762362 -0.3838279
      4       Georg_M_Weber 10241965 39.4757710 -0.3837962
      5       Georg_M_Weber 10241965 39.4757529 -0.3839320
      6  editemapes_imports 10063912 39.4759211 -0.3839627
      7  editemapes_imports 10063912 39.4759415 -0.3839663
      8  editemapes_imports 10063912 39.4759429 -0.3839482
      9  editemapes_imports 10063912 39.4759107 -0.3839952
      10 editemapes_imports 10063912 39.4759295 -0.3838642
      11 editemapes_imports 10063912 39.4756556 -0.3838435
      12 editemapes_imports 10063912 39.4758753 -0.3838351
      13 editemapes_imports 10063912 39.4755912 -0.3838750
      14      Georg_M_Weber 10241965 39.4759225 -0.3839451
      15 editemapes_imports 10063912 39.4758125 -0.3838357
      16 editemapes_imports 10063912 39.4755967 -0.3838455
      17 editemapes_imports 10063912 39.4755836 -0.3839789
      18 editemapes_imports 10063912 39.4757046 -0.3839958
      19 editemapes_imports 10063912 39.4756574 -0.3840390
      20 editemapes_imports 10063912 39.4758791 -0.3840280
      21 editemapes_imports 10063912 39.4757087 -0.3839836
      22 editemapes_imports 10063912 39.4758031 -0.3839996
      23 editemapes_imports 10063912 39.4756803 -0.3840288
      24 editemapes_imports 10063912 39.4756202 -0.3840332
      25 editemapes_imports 10063912 39.4757196 -0.3838412
      26 editemapes_imports 10063912 39.4759713 -0.3838621
      27 editemapes_imports 10063912 39.4759036 -0.3840060
      28 editemapes_imports 10063912 39.4759330 -0.3838343
      29 editemapes_imports 10063912 39.4758114 -0.3840119
      30 editemapes_imports 10063912 39.4756003 -0.3840164
      31 editemapes_imports 10063912 39.4755807 -0.3839573
      32 editemapes_imports 10063912 39.4756984 -0.3840076
      33 editemapes_imports 10063912 39.4756322 -0.3840382
      34 editemapes_imports 10063912 39.4757118 -0.3839693
      35 editemapes_imports 10063912 39.4756695 -0.3840350
      36 editemapes_imports 10063912 39.4757140 -0.3839557
      37 editemapes_imports 10063912 39.4756899 -0.3840195
      38 editemapes_imports 10063912 39.4759704 -0.3838325
      39 editemapes_imports 10063912 39.4756442 -0.3840402
      40 editemapes_imports 10063912 39.4757906 -0.3839351
      41 editemapes_imports 10063912 39.4756105 -0.3840266
      42 editemapes_imports 10063912 39.4758740 -0.3840303
      43 editemapes_imports 10063912 39.4755913 -0.3840016
      44 editemapes_imports 10063912 39.4759266 -0.3838346
      45 editemapes_imports 10063912 39.4757154 -0.3839416
      46 editemapes_imports 10063912 39.4757157 -0.3839290
      47 editemapes_imports 10063912 39.4758241 -0.3840238
      48 editemapes_imports 10063912 39.4757905 -0.3839518
      49 editemapes_imports 10063912 39.4757286 -0.3837929
      50 editemapes_imports 10063912 39.4758927 -0.3840178
      51 editemapes_imports 10063912 39.4757954 -0.3839814
      52 editemapes_imports 10063912 39.4755879 -0.3838926
      53 editemapes_imports 10063912 39.4758357 -0.3840299
      54 editemapes_imports 10063912 39.4758510 -0.3840329
      55 editemapes_imports 10063912 39.4757897 -0.3839350
      56 editemapes_imports 10063912 39.4757920 -0.3839677
      57 editemapes_imports 10063912 39.4759168 -0.3839802
      58 editemapes_imports 10063912 39.4757672 -0.3839332
      59 editemapes_imports 10063912 39.4758625 -0.3840327
      60 editemapes_imports 10063912 39.4758168 -0.3837998
      61           jmaspons 11725140       <NA>       <NA>
                                                                 members
      1                                                             NULL
      2                                                             NULL
      3                                                             NULL
      4                                                             NULL
      5                                                             NULL
      6                                                             NULL
      7                                                             NULL
      8                                                             NULL
      9                                                             NULL
      10                                                            NULL
      11                                                            NULL
      12                                                            NULL
      13                                                            NULL
      14                                                            NULL
      15                                                            NULL
      16                                                            NULL
      17                                                            NULL
      18                                                            NULL
      19                                                            NULL
      20                                                            NULL
      21                                                            NULL
      22                                                            NULL
      23                                                            NULL
      24                                                            NULL
      25                                                            NULL
      26                                                            NULL
      27                                                            NULL
      28                                                            NULL
      29                                                            NULL
      30                                                            NULL
      31                                                            NULL
      32                                                            NULL
      33                                                            NULL
      34                                                            NULL
      35                                                            NULL
      36                                                            NULL
      37                                                            NULL
      38                                                            NULL
      39                                                            NULL
      40                                                            NULL
      41                                                            NULL
      42                                                            NULL
      43                                                            NULL
      44                                                            NULL
      45                                                            NULL
      46                                                            NULL
      47                                                            NULL
      48                                                            NULL
      49                                                            NULL
      50                                                            NULL
      51                                                            NULL
      52                                                            NULL
      53                                                            NULL
      54                                                            NULL
      55                                                            NULL
      56                                                            NULL
      57                                                            NULL
      58                                                            NULL
      59                                                            NULL
      60                                                            NULL
      61 61 nodes: 6771540804, 6771540805, 6771540806, 6957604952, 67...
                                                                                        tags
      1                                                                              No tags
      2                                                                              No tags
      3                                                                              No tags
      4                                                                              No tags
      5                                                                              No tags
      6                                                                              No tags
      7                                                                              No tags
      8                                                                              No tags
      9                                                                              No tags
      10                                                                             No tags
      11                                                                 1 tag: entrance=yes
      12                                                                 1 tag: entrance=yes
      13                                                                             No tags
      14                                                                             No tags
      15                                                                             No tags
      16                                                                             No tags
      17                                                                             No tags
      18                                                                             No tags
      19                                                                             No tags
      20                                                                             No tags
      21                                                                             No tags
      22                                                                             No tags
      23                                                                             No tags
      24                                                                             No tags
      25                                                                             No tags
      26                                                                             No tags
      27                                                                             No tags
      28                                                                             No tags
      29                                                                             No tags
      30                                                                             No tags
      31                                                                             No tags
      32                                                                             No tags
      33                                                                             No tags
      34                                                                             No tags
      35                                                                             No tags
      36                                                                             No tags
      37                                                                             No tags
      38                                                                             No tags
      39                                                                             No tags
      40                                                                             No tags
      41                                                                             No tags
      42                                                                             No tags
      43                                                                             No tags
      44                                                                             No tags
      45                                                                             No tags
      46                                                                             No tags
      47                                                                             No tags
      48                                                                             No tags
      49                                                                             No tags
      50                                                                             No tags
      51                                                                             No tags
      52                                                                             No tags
      53                                                                             No tags
      54                                                                             No tags
      55                                                                             No tags
      56                                                                             No tags
      57                                                                             No tags
      58 4 tags: addr:housenumber=90 | addr:postcode=46001 | addr:street=Carrer de Guille...
      59                                                                             No tags
      60                                                                             No tags
      61 12 tags: alt_name:ca=Torres de Quart | building=tower | building:levels=4 | buil...

---

    Code
      print(x)
    Output
             type         id visible version changeset           timestamp     user
      1      node 1987589881    TRUE       1  13666675 2012-10-28 20:10:51   EliziR
      2      node 1987589883    TRUE       1  13666675 2012-10-28 20:10:51   EliziR
      3      node 1987589884    TRUE       1  13666675 2012-10-28 20:10:51   EliziR
      4      node 1987589885    TRUE       1  13666675 2012-10-28 20:10:51   EliziR
      5      node 1987589889    TRUE       1  13666675 2012-10-28 20:10:51   EliziR
      6      node 1987589892    TRUE       1  13666675 2012-10-28 20:10:51   EliziR
      7      node 1987589893    TRUE       1  13666675 2012-10-28 20:10:51   EliziR
      8      node 1987589897    TRUE       1  13666675 2012-10-28 20:10:52   EliziR
      9      node 1987589898    TRUE       1  13666675 2012-10-28 20:10:52   EliziR
      10     node 1987589905    TRUE       1  13666675 2012-10-28 20:10:52   EliziR
      11     node 1987589916    TRUE       1  13666675 2012-10-28 20:10:53   EliziR
      12     node 1987589921    TRUE       1  13666675 2012-10-28 20:10:53   EliziR
      13     node 1987589933    TRUE       1  13666675 2012-10-28 20:10:53   EliziR
      14     node 1987589935    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      15     node 1987589936    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      16     node 1987589937    TRUE       1  13666675 2012-10-28 20:10:53   EliziR
      17     node 1987589939    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      18     node 1987589943    TRUE       1  13666675 2012-10-28 20:10:54   EliziR
      19     node 1987589944    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      20     node 1987589947    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      21     node 1987589948    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      22     node 1987589951    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      23     node 1987589952    TRUE       1  13666675 2012-10-28 20:10:54   EliziR
      24     node 1987589954    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      25     node 1987589955    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      26     node 1987589957    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      27     node 1987589959    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      28     node 1987589963    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      29     node 1987589964    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      30     node 1987589969    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      31     node 1987589970    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      32     node 1987589971    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      33     node 1987589973    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      34     node 1987589974    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      35     node 1987589975    TRUE       2  37406198 2016-02-24 07:36:48   EliziR
      36     node 1987589979    TRUE       1  13666675 2012-10-28 20:10:55   EliziR
      37     node 4023138933    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      38     node 4023138934    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      39     node 4023138935    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      40     node 4023138936    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      41     node 4023138937    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      42     node 4023138938    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      43     node 4023138939    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      44     node 4023138940    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      45     node 4023138941    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      46     node 4023138942    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      47     node 4023138943    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      48     node 4023138944    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      49     node 4023138945    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      50     node 4023138946    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      51     node 4023138947    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      52     node 4023138948    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      53     node 4023138949    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      54     node 4023138950    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      55     node 4023138951    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      56     node 4023138952    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      57     node 4023138953    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      58     node 4023138954    TRUE       1  37406198 2016-02-24 07:36:47   EliziR
      59     node 9042634094    TRUE       1 110374887 2021-08-28 10:35:49     Xevi
      60     node 9042634095    TRUE       1 110374887 2021-08-28 10:35:49     Xevi
      61     node 9042634109    TRUE       1 110374887 2021-08-28 10:35:49     Xevi
      62      way  188131984    TRUE       4 110374887 2021-08-28 10:35:49     Xevi
      63      way  399588560    TRUE       3 129976247 2022-12-11 21:22:32 jmaspons
      64 relation    6002785    TRUE       6 115301929 2021-12-23 15:52:41 jmaspons
              uid        lat       lon
      1    605366 42.3229954 3.1666430
      2    605366 42.3230133 3.1667173
      3    605366 42.3230151 3.1665900
      4    605366 42.3230247 3.1666301
      5    605366 42.3231233 3.1664855
      6    605366 42.3231325 3.1663394
      7    605366 42.3231357 3.1665367
      8    605366 42.3231635 3.1664677
      9    605366 42.3231718 3.1666472
      10   605366 42.3232138 3.1668208
      11   605366 42.3233439 3.1661016
      12   605366 42.3233850 3.1662278
      13   605366 42.3234704 3.1660394
      14   605366 42.3234977 3.1666206
      15   605366 42.3235105 3.1666418
      16   605366 42.3235115 3.1666892
      17   605366 42.3235273 3.1666569
      18   605366 42.3235423 3.1662378
      19   605366 42.3235467 3.1666646
      20   605366 42.3235669 3.1666642
      21   605366 42.3235861 3.1666558
      22   605366 42.3236026 3.1666400
      23   605366 42.3236056 3.1661989
      24   605366 42.3236149 3.1666184
      25   605366 42.3236182 3.1665392
      26   605366 42.3236220 3.1665928
      27   605366 42.3236231 3.1665656
      28   605366 42.3236310 3.1665463
      29   605366 42.3236449 3.1665461
      30   605366 42.3236576 3.1665386
      31   605366 42.3236551 3.1664593
      32   605366 42.3236671 3.1665250
      33   605366 42.3236720 3.1665074
      34   605366 42.3236655 3.1664718
      35   605366 42.3236714 3.1664887
      36   605366 42.3236933 3.1664322
      37   605366 42.3232726 3.1664407
      38   605366 42.3233105 3.1666218
      39   605366 42.3233486 3.1664116
      40   605366 42.3233865 3.1665927
      41   605366 42.3235035 3.1666319
      42   605366 42.3235185 3.1666502
      43   605366 42.3235368 3.1666617
      44   605366 42.3235568 3.1666654
      45   605366 42.3235767 3.1666609
      46   605366 42.3235947 3.1666487
      47   605366 42.3236093 3.1666298
      48   605366 42.3236191 3.1666060
      49   605366 42.3236214 3.1665521
      50   605366 42.3236233 3.1665793
      51   605366 42.3236244 3.1665436
      52   605366 42.3236380 3.1665471
      53   605366 42.3236515 3.1665432
      54   605366 42.3236608 3.1664648
      55   605366 42.3236629 3.1665324
      56   605366 42.3236691 3.1664798
      57   605366 42.3236702 3.1665165
      58   605366 42.3236724 3.1664980
      59   100124 42.3232736 3.1662770
      60   100124 42.3231531 3.1664245
      61   100124 42.3234134 3.1660674
      62   100124       <NA>      <NA>
      63 11725140       <NA>      <NA>
      64 11725140       <NA>      <NA>
                                                                 members
      1                                                             NULL
      2                                                             NULL
      3                                                             NULL
      4                                                             NULL
      5                                                             NULL
      6                                                             NULL
      7                                                             NULL
      8                                                             NULL
      9                                                             NULL
      10                                                            NULL
      11                                                            NULL
      12                                                            NULL
      13                                                            NULL
      14                                                            NULL
      15                                                            NULL
      16                                                            NULL
      17                                                            NULL
      18                                                            NULL
      19                                                            NULL
      20                                                            NULL
      21                                                            NULL
      22                                                            NULL
      23                                                            NULL
      24                                                            NULL
      25                                                            NULL
      26                                                            NULL
      27                                                            NULL
      28                                                            NULL
      29                                                            NULL
      30                                                            NULL
      31                                                            NULL
      32                                                            NULL
      33                                                            NULL
      34                                                            NULL
      35                                                            NULL
      36                                                            NULL
      37                                                            NULL
      38                                                            NULL
      39                                                            NULL
      40                                                            NULL
      41                                                            NULL
      42                                                            NULL
      43                                                            NULL
      44                                                            NULL
      45                                                            NULL
      46                                                            NULL
      47                                                            NULL
      48                                                            NULL
      49                                                            NULL
      50                                                            NULL
      51                                                            NULL
      52                                                            NULL
      53                                                            NULL
      54                                                            NULL
      55                                                            NULL
      56                                                            NULL
      57                                                            NULL
      58                                                            NULL
      59                                                            NULL
      60                                                            NULL
      61                                                            NULL
      62 58 nodes: 1987589955, 4023138947, 1987589963, 4023138948, 19...
      63 5 nodes: 4023138936, 4023138934, 4023138933, 4023138935, 402...
      64             2 members: way/188131984/outer, way/399588560/inner
                                                                                        tags
      1                                                                              No tags
      2                                                                              No tags
      3                                                                              No tags
      4                                                                              No tags
      5                                                                              No tags
      6                                                                              No tags
      7                                                                              No tags
      8                                                                              No tags
      9                                                                              No tags
      10                                                                             No tags
      11                                                                             No tags
      12                                                                             No tags
      13                                                                             No tags
      14                                                                             No tags
      15                                                                             No tags
      16                                                                             No tags
      17                                                                             No tags
      18                                                                             No tags
      19                                                                             No tags
      20                                                                             No tags
      21                                                                             No tags
      22                                                                             No tags
      23                                                                             No tags
      24                                                                             No tags
      25                                                                             No tags
      26                                                                             No tags
      27                                                                             No tags
      28                                                                             No tags
      29                                                                             No tags
      30                                                                             No tags
      31                                                                             No tags
      32                                                                             No tags
      33                                                                             No tags
      34                                                                             No tags
      35                                                                             No tags
      36                                                                             No tags
      37                                                                             No tags
      38                                                                             No tags
      39                                                                             No tags
      40                                                                             No tags
      41                                                                             No tags
      42                                                                             No tags
      43                                                                             No tags
      44                                                                             No tags
      45                                                                             No tags
      46                                                                             No tags
      47                                                                             No tags
      48                                                                             No tags
      49                                                                             No tags
      50                                                                             No tags
      51                                                                             No tags
      52                                                                             No tags
      53                                                                             No tags
      54                                                                             No tags
      55                                                                             No tags
      56                                                                             No tags
      57                                                                             No tags
      58                                                                             No tags
      59                                                                 1 tag: entrance=yes
      60                                                                 1 tag: entrance=yes
      61                                                                1 tag: entrance=main
      62                                                                             No tags
      63                           3 tags: leisure=garden | name=Claustre | name:ca=Claustre
      64 12 tags: amenity=place_of_worship | building=yes | denomination=catholic | histo...

