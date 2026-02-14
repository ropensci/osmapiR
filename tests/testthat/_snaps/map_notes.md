# osm_read_bbox_notes works

    Code
      print(bbox_notes$df)
    Output
               lon        lat      id                               url
      1  4.2665644 39.8847163 3748302 osm.org/api/0.6/notes/3748302.xml
      2  3.9995921 39.9338121 3734481 osm.org/api/0.6/notes/3734481.xml
      3  4.2578000 39.8824000 3733381 osm.org/api/0.6/notes/3733381.xml
      4  3.9880291 39.9312338 3721129 osm.org/api/0.6/notes/3721129.xml
      5  3.9611400 39.9449100 3692115 osm.org/api/0.6/notes/3692115.xml
      6  3.9537600 39.9442500 3692113 osm.org/api/0.6/notes/3692113.xml
      7  3.9520763 39.9431848 3692105 osm.org/api/0.6/notes/3692105.xml
      8  3.9520400 39.9418000 3692101 osm.org/api/0.6/notes/3692101.xml
      9  3.8000843 40.0204555 3632934 osm.org/api/0.6/notes/3632934.xml
      10 4.2870374 39.8807565 3589177 osm.org/api/0.6/notes/3589177.xml
                                       comment_url
      1  osm.org/api/0.6/notes/3748302/comment.xml
      2  osm.org/api/0.6/notes/3734481/comment.xml
      3  osm.org/api/0.6/notes/3733381/comment.xml
      4  osm.org/api/0.6/notes/3721129/comment.xml
      5  osm.org/api/0.6/notes/3692115/comment.xml
      6  osm.org/api/0.6/notes/3692113/comment.xml
      7  osm.org/api/0.6/notes/3692105/comment.xml
      8  osm.org/api/0.6/notes/3692101/comment.xml
      9  osm.org/api/0.6/notes/3632934/comment.xml
      10 osm.org/api/0.6/notes/3589177/comment.xml
                                       close_url        date_created status
      1  osm.org/api/0.6/notes/3748302/close.xml 2023-06-23 22:34:31   open
      2  osm.org/api/0.6/notes/3734481/close.xml 2023-06-14 07:58:30   open
      3  osm.org/api/0.6/notes/3733381/close.xml 2023-06-13 11:10:01   open
      4  osm.org/api/0.6/notes/3721129/close.xml 2023-06-05 06:44:18   open
      5  osm.org/api/0.6/notes/3692115/close.xml 2023-05-16 16:02:25   open
      6  osm.org/api/0.6/notes/3692113/close.xml 2023-05-16 16:01:02   open
      7  osm.org/api/0.6/notes/3692105/close.xml 2023-05-16 15:57:55   open
      8  osm.org/api/0.6/notes/3692101/close.xml 2023-05-16 15:56:45   open
      9  osm.org/api/0.6/notes/3632934/close.xml 2023-04-08 19:55:01   open
      10 osm.org/api/0.6/notes/3589177/close.xml 2023-03-07 21:05:51   open
                                            comments
      1  1 comment from 2023-06-23 by anonymous user
      2    1 comment from 2023-06-14 by Pan Perníček
      3  1 comment from 2023-06-13 by anonymous user
      4    1 comment from 2023-06-05 by Pan Perníček
      5  1 comment from 2023-05-16 by anonymous user
      6  1 comment from 2023-05-16 by anonymous user
      7  1 comment from 2023-05-16 by anonymous user
      8  1 comment from 2023-05-16 by anonymous user
      9  1 comment from 2023-04-08 by anonymous user
      10         1 comment from 2023-03-07 by cranca

---

    Code
      print(bbox_notes$sf)
    Output
      Simple feature collection with 10 features and 7 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: 3.800084 ymin: 39.88076 xmax: 4.287037 ymax: 40.02046
      Geodetic CRS:  WGS 84
              id                               url
      1  3748302 osm.org/api/0.6/notes/3748302.xml
      2  3734481 osm.org/api/0.6/notes/3734481.xml
      3  3733381 osm.org/api/0.6/notes/3733381.xml
      4  3721129 osm.org/api/0.6/notes/3721129.xml
      5  3692115 osm.org/api/0.6/notes/3692115.xml
      6  3692113 osm.org/api/0.6/notes/3692113.xml
      7  3692105 osm.org/api/0.6/notes/3692105.xml
      8  3692101 osm.org/api/0.6/notes/3692101.xml
      9  3632934 osm.org/api/0.6/notes/3632934.xml
      10 3589177 osm.org/api/0.6/notes/3589177.xml
                                       comment_url
      1  osm.org/api/0.6/notes/3748302/comment.xml
      2  osm.org/api/0.6/notes/3734481/comment.xml
      3  osm.org/api/0.6/notes/3733381/comment.xml
      4  osm.org/api/0.6/notes/3721129/comment.xml
      5  osm.org/api/0.6/notes/3692115/comment.xml
      6  osm.org/api/0.6/notes/3692113/comment.xml
      7  osm.org/api/0.6/notes/3692105/comment.xml
      8  osm.org/api/0.6/notes/3692101/comment.xml
      9  osm.org/api/0.6/notes/3632934/comment.xml
      10 osm.org/api/0.6/notes/3589177/comment.xml
                                       close_url        date_created status
      1  osm.org/api/0.6/notes/3748302/close.xml 2023-06-23 22:34:31   open
      2  osm.org/api/0.6/notes/3734481/close.xml 2023-06-14 07:58:30   open
      3  osm.org/api/0.6/notes/3733381/close.xml 2023-06-13 11:10:01   open
      4  osm.org/api/0.6/notes/3721129/close.xml 2023-06-05 06:44:18   open
      5  osm.org/api/0.6/notes/3692115/close.xml 2023-05-16 16:02:25   open
      6  osm.org/api/0.6/notes/3692113/close.xml 2023-05-16 16:01:02   open
      7  osm.org/api/0.6/notes/3692105/close.xml 2023-05-16 15:57:55   open
      8  osm.org/api/0.6/notes/3692101/close.xml 2023-05-16 15:56:45   open
      9  osm.org/api/0.6/notes/3632934/close.xml 2023-04-08 19:55:01   open
      10 osm.org/api/0.6/notes/3589177/close.xml 2023-03-07 21:05:51   open
                                            comments                  geometry
      1  1 comment from 2023-06-23 by anonymous user POINT (4.266564 39.88472)
      2    1 comment from 2023-06-14 by Pan Perníček POINT (3.999592 39.93381)
      3  1 comment from 2023-06-13 by anonymous user    POINT (4.2578 39.8824)
      4    1 comment from 2023-06-05 by Pan Perníček POINT (3.988029 39.93123)
      5  1 comment from 2023-05-16 by anonymous user  POINT (3.96114 39.94491)
      6  1 comment from 2023-05-16 by anonymous user  POINT (3.95376 39.94425)
      7  1 comment from 2023-05-16 by anonymous user POINT (3.952076 39.94318)
      8  1 comment from 2023-05-16 by anonymous user   POINT (3.95204 39.9418)
      9  1 comment from 2023-04-08 by anonymous user POINT (3.800084 40.02046)
      10         1 comment from 2023-03-07 by cranca POINT (4.287037 39.88076)

# .osm_read_note works

    Code
      print(read_note$df)
    Output
              lon        lat      id                               url
      1 1.7214600 42.0332200 2067786 osm.org/api/0.6/notes/2067786.xml
                                      comment_url
      1 osm.org/api/0.6/notes/2067786/comment.xml
                                      close_url        date_created status
      1 osm.org/api/0.6/notes/2067786/close.xml 2020-01-24 18:21:48   open
                                                               comments
      1 2 comments from 2020-01-24 to 2020-02-07 by Juliosebastian, ...

---

    Code
      print(read_note$sf)
    Output
      Simple feature collection with 1 feature and 7 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: 1.72146 ymin: 42.03322 xmax: 1.72146 ymax: 42.03322
      Geodetic CRS:  WGS 84
             id                               url
      1 2067786 osm.org/api/0.6/notes/2067786.xml
                                      comment_url
      1 osm.org/api/0.6/notes/2067786/comment.xml
                                      close_url        date_created status
      1 osm.org/api/0.6/notes/2067786/close.xml 2020-01-24 18:21:48   open
                                                               comments
      1 2 comments from 2020-01-24 to 2020-02-07 by Juliosebastian, ...
                        geometry
      1 POINT (1.72146 42.03322)

---

    Code
      print(read_notes$df)
    Output
              lon        lat      id                               url
      1 1.7214600 42.0332200 2067786 osm.org/api/0.6/notes/2067786.xml
      2 1.7214600 42.0332200 2067786 osm.org/api/0.6/notes/2067786.xml
                                      comment_url
      1 osm.org/api/0.6/notes/2067786/comment.xml
      2 osm.org/api/0.6/notes/2067786/comment.xml
                                      close_url        date_created status
      1 osm.org/api/0.6/notes/2067786/close.xml 2020-01-24 18:21:48   open
      2 osm.org/api/0.6/notes/2067786/close.xml 2020-01-24 18:21:48   open
                                                               comments
      1 2 comments from 2020-01-24 to 2020-02-07 by Juliosebastian, ...
      2 2 comments from 2020-01-24 to 2020-02-07 by Juliosebastian, ...

---

    Code
      print(read_notes$sf)
    Output
      Simple feature collection with 2 features and 7 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: 1.72146 ymin: 42.03322 xmax: 1.72146 ymax: 42.03322
      Geodetic CRS:  WGS 84
             id                               url
      1 2067786 osm.org/api/0.6/notes/2067786.xml
      2 2067786 osm.org/api/0.6/notes/2067786.xml
                                      comment_url
      1 osm.org/api/0.6/notes/2067786/comment.xml
      2 osm.org/api/0.6/notes/2067786/comment.xml
                                      close_url        date_created status
      1 osm.org/api/0.6/notes/2067786/close.xml 2020-01-24 18:21:48   open
      2 osm.org/api/0.6/notes/2067786/close.xml 2020-01-24 18:21:48   open
                                                               comments
      1 2 comments from 2020-01-24 to 2020-02-07 by Juliosebastian, ...
      2 2 comments from 2020-01-24 to 2020-02-07 by Juliosebastian, ...
                        geometry
      1 POINT (1.72146 42.03322)
      2 POINT (1.72146 42.03322)

# osm_search_notes works

    Code
      print(search_notes$df)
    Output
                 lon         lat      id                               url
      1  130.4640945  33.5161369 1186670 osm.org/api/0.6/notes/1186670.xml
      2  130.4770496  33.5044160 1186668 osm.org/api/0.6/notes/1186668.xml
      3  -65.1923037 -26.8516865 1186662 osm.org/api/0.6/notes/1186662.xml
      4  100.5142599  13.7416015 1186602 osm.org/api/0.6/notes/1186602.xml
      5  -58.2735245 -34.8110475 1186568 osm.org/api/0.6/notes/1186568.xml
      6   56.0006851  25.7839897 1186550 osm.org/api/0.6/notes/1186550.xml
      7   49.9251840  40.3757950 1186540 osm.org/api/0.6/notes/1186540.xml
      8  105.2217471  18.4369054 1186533 osm.org/api/0.6/notes/1186533.xml
      9  109.4963331  18.2641137 1186532 osm.org/api/0.6/notes/1186532.xml
      10 135.7485667  35.0033409 1186522 osm.org/api/0.6/notes/1186522.xml
                                       comment_url
      1  osm.org/api/0.6/notes/1186670/comment.xml
      2  osm.org/api/0.6/notes/1186668/comment.xml
      3  osm.org/api/0.6/notes/1186662/comment.xml
      4  osm.org/api/0.6/notes/1186602/comment.xml
      5  osm.org/api/0.6/notes/1186568/comment.xml
      6  osm.org/api/0.6/notes/1186550/comment.xml
      7  osm.org/api/0.6/notes/1186540/comment.xml
      8  osm.org/api/0.6/notes/1186533/comment.xml
      9  osm.org/api/0.6/notes/1186532/comment.xml
      10 osm.org/api/0.6/notes/1186522/comment.xml
                                       close_url        date_created status
      1  osm.org/api/0.6/notes/1186670/close.xml 2017-10-27 13:47:16   open
      2  osm.org/api/0.6/notes/1186668/close.xml 2017-10-27 13:47:15   open
      3  osm.org/api/0.6/notes/1186662/close.xml 2017-10-27 13:32:46   open
      4  osm.org/api/0.6/notes/1186602/close.xml 2017-10-27 12:24:44   open
      5  osm.org/api/0.6/notes/1186568/close.xml 2017-10-27 11:52:51   open
      6  osm.org/api/0.6/notes/1186550/close.xml 2017-10-27 11:15:06   open
      7  osm.org/api/0.6/notes/1186540/close.xml 2017-10-27 11:05:08   open
      8  osm.org/api/0.6/notes/1186533/close.xml 2017-10-27 10:49:15   open
      9  osm.org/api/0.6/notes/1186532/close.xml 2017-10-27 10:48:54   open
      10 osm.org/api/0.6/notes/1186522/close.xml 2017-10-27 10:36:18   open
                                                      comments
      1                  1 comment from 2017-10-27 by 石橋武士
      2                  1 comment from 2017-10-27 by 石橋武士
      3   1 comment from 2017-10-27 by Juan Francisco La Greca
      4                1 comment from 2017-10-27 by Ökokirsche
      5  1 comment from 2017-10-27 by Ruben Dario Celis Viotti
      6         1 comment from 2017-10-27 by Mohammed Alshehhi
      7                1 comment from 2017-10-27 by Oil expert
      8         1 comment from 2017-10-27 by Alessandro Schiti
      9                     1 comment from 2017-10-27 by Tyzeg
      10                1 comment from 2017-10-27 by Stephan99

---

    Code
      print(search_notes$sf)
    Output
      Simple feature collection with 10 features and 7 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -65.1923 ymin: -34.81105 xmax: 135.7486 ymax: 40.37579
      Geodetic CRS:  WGS 84
              id                               url
      1  1186670 osm.org/api/0.6/notes/1186670.xml
      2  1186668 osm.org/api/0.6/notes/1186668.xml
      3  1186662 osm.org/api/0.6/notes/1186662.xml
      4  1186602 osm.org/api/0.6/notes/1186602.xml
      5  1186568 osm.org/api/0.6/notes/1186568.xml
      6  1186550 osm.org/api/0.6/notes/1186550.xml
      7  1186540 osm.org/api/0.6/notes/1186540.xml
      8  1186533 osm.org/api/0.6/notes/1186533.xml
      9  1186532 osm.org/api/0.6/notes/1186532.xml
      10 1186522 osm.org/api/0.6/notes/1186522.xml
                                       comment_url
      1  osm.org/api/0.6/notes/1186670/comment.xml
      2  osm.org/api/0.6/notes/1186668/comment.xml
      3  osm.org/api/0.6/notes/1186662/comment.xml
      4  osm.org/api/0.6/notes/1186602/comment.xml
      5  osm.org/api/0.6/notes/1186568/comment.xml
      6  osm.org/api/0.6/notes/1186550/comment.xml
      7  osm.org/api/0.6/notes/1186540/comment.xml
      8  osm.org/api/0.6/notes/1186533/comment.xml
      9  osm.org/api/0.6/notes/1186532/comment.xml
      10 osm.org/api/0.6/notes/1186522/comment.xml
                                       close_url        date_created status
      1  osm.org/api/0.6/notes/1186670/close.xml 2017-10-27 13:47:16   open
      2  osm.org/api/0.6/notes/1186668/close.xml 2017-10-27 13:47:15   open
      3  osm.org/api/0.6/notes/1186662/close.xml 2017-10-27 13:32:46   open
      4  osm.org/api/0.6/notes/1186602/close.xml 2017-10-27 12:24:44   open
      5  osm.org/api/0.6/notes/1186568/close.xml 2017-10-27 11:52:51   open
      6  osm.org/api/0.6/notes/1186550/close.xml 2017-10-27 11:15:06   open
      7  osm.org/api/0.6/notes/1186540/close.xml 2017-10-27 11:05:08   open
      8  osm.org/api/0.6/notes/1186533/close.xml 2017-10-27 10:49:15   open
      9  osm.org/api/0.6/notes/1186532/close.xml 2017-10-27 10:48:54   open
      10 osm.org/api/0.6/notes/1186522/close.xml 2017-10-27 10:36:18   open
                                                      comments
      1                  1 comment from 2017-10-27 by 石橋武士
      2                  1 comment from 2017-10-27 by 石橋武士
      3   1 comment from 2017-10-27 by Juan Francisco La Greca
      4                1 comment from 2017-10-27 by Ökokirsche
      5  1 comment from 2017-10-27 by Ruben Dario Celis Viotti
      6         1 comment from 2017-10-27 by Mohammed Alshehhi
      7                1 comment from 2017-10-27 by Oil expert
      8         1 comment from 2017-10-27 by Alessandro Schiti
      9                     1 comment from 2017-10-27 by Tyzeg
      10                1 comment from 2017-10-27 by Stephan99
                            geometry
      1    POINT (130.4641 33.51614)
      2     POINT (130.477 33.50442)
      3   POINT (-65.1923 -26.85169)
      4     POINT (100.5143 13.7416)
      5  POINT (-58.27352 -34.81105)
      6    POINT (56.00069 25.78399)
      7    POINT (49.92518 40.37579)
      8    POINT (105.2217 18.43691)
      9    POINT (109.4963 18.26411)
      10   POINT (135.7486 35.00334)

---

    Code
      print(empty_search_notes$df)
    Output
      [1] lon          lat          id           url          comment_url 
      [6] close_url    date_created status       comments    
      <0 rows> (or 0-length row.names)

---

    Code
      print(empty_search_notes$sf)
    Output
      Simple feature collection with 0 features and 7 fields
      Bounding box:  xmin: Inf ymin: Inf xmax: -Inf ymax: -Inf
      Geodetic CRS:  WGS 84
      [1] id           url          comment_url  close_url    date_created
      [6] status       comments     geometry    
      <0 rows> (or 0-length row.names)

