column_objects <- c(
  "type", "id", "visible", "version", "changeset", "timestamp", "user", "uid", "lat", "lon", "members", "tags"
)

class_columns <- list(
  type = "character", id = "character", visible = "logical", version = "integer", changeset = "character",
  timestamp = "POSIXct", user = "character", uid = "character", lat = "character", lon = "character",
  members = "list", tags = "list"
)


## osm_get_objects ----

test_that("osm_read_object works", {
  ## Test errors

  expect_error(
    osm_get_objects(osm_type = "relation", osm_id = 1, version = 1, full_objects = TRUE),
    "Getting full objects with specific version is not supported."
  )
  expect_error(
    osm_get_objects(osm_type = c("node", "relation"), osm_id = 1:3),
    "`osm_id` length must be a multiple of `osm_type` length."
  )
  expect_error(
    osm_get_objects(osm_type = c("node", "relation"), osm_id = 1),
    "`osm_id` length must be a multiple of `osm_type` length."
  )
  expect_error(
    osm_get_objects(osm_type = "relation", osm_id = 1:3, version = 1:2),
    "`osm_id` length must be a multiple of `version` length."
  )
  expect_error(
    osm_get_objects(osm_type = "relation", osm_id = 1:2, version = 1:3),
    "`osm_id` length must be a multiple of `version` length."
  )

  with_mock_dir("mock_get_objects", {
    expect_warning(
      objs <- osm_get_objects(
        osm_type = c("way", "way", "relation"), osm_id = c(235744929, 235744929, 6002785),
        full_objects = TRUE, tags_in_columns = TRUE
      ),
      "Duplicated elements discarded."
    )
  })
})


## Read: `GET /api/0.6/[node|way|relation]/#id` ----

test_that("osm_read_object works", {
  read <- list()
  with_mock_dir("mock_read_object", {
    read$node <- osm_get_objects(osm_type = "node", osm_id = 35308286)
    read$way <- osm_get_objects(osm_type = "way", osm_id = 13073736L)
    read$rel <- osm_get_objects(osm_type = "relation", osm_id = "40581")
  })

  lapply(read, expect_s3_class, c("osmapi_objects", "data.frame"))
  lapply(read, function(x) {
    lapply(x$members, function(y) {
      expect_true(is.null(y) | inherits(y, "way_members") | inherits(y, "relation_members"))
    })
  })

  expect_identical(names(read$node), column_objects)
  lapply(read[c("way", "rel")], function(x) expect_identical(names(x), column_objects))

  lapply(read, function(x) {
    mapply(function(y, cl) expect_true(inherits(y, cl)), y = x, cl = class_columns[names(x)])
  })

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  lapply(read, function(x) expect_false(strftime(as.POSIXct(x$timestamp), format = "%M:%S") == "00:00"))

  # methods
  lapply(read, function(x) expect_snapshot(print(x)))
})


test_that("edit OSM object works", {
  x <- data.frame(
    type = c("node", "node", "way", "relation"),
    changeset = NA,
    lat = c(89, 89.001, NA, NA), lon = c(0, 0, NA, NA)
  )

  x$members <- list(
    NULL, NULL, c("", ""), data.frame(type = c("node", "node", "way"), ref = c("", "", ""), role = c("", "", ""))
  )

  x$tags <- list(
    data.frame(), data.frame(), data.frame(key = "name", value = "My way"), data.frame(key = "name", value = "Rel")
  )


  with_mock_dir("mock_edit_objects", {
    expect_message(
      changeset_id <- osm_create_changeset(
        comment = "Test object creation",
        created_by = "osmapiR", # avoid changes in calls when updating version
        source = "Imagination",
        hashtags = "#testing;#osmapiR",
        verbose = TRUE
      ),
      "New changeset with id = "
    )


    ## Create: `PUT /api/0.6/[node|way|relation]/create` ----

    create_id <- character(nrow(x))
    for (i in seq_len(nrow(x))) {
      if (x$type[i] == "way") {
        x$members[[i]] <- create_id[1:(i - 1)]
      }
      if (x$type[i] == "relation") {
        x$members[[i]] <- data.frame(type = x$type[1:(i - 1)], ref = create_id[1:(i - 1)], role = c(NA, NA, NA))
      }

      create_id[i] <- osm_create_object(x[i, ], changeset_id = changeset_id)
    }


    ## Update: `PUT /api/0.6/[node|way|relation]/#id` ----

    x$lon[1:2] <- 1
    x$tags[[3]]$value <- "Our way"
    x$tags[[4]]$value <- "Relation"
    x$visible <- TRUE
    x$id <- create_id
    x$version <- 1L

    update_version <- character(nrow(x))
    for (i in seq_len(nrow(x))) {
      update_version[i] <- osm_update_object(x[i, ], changeset_id = changeset_id)
    }


    ## Delete: `DELETE /api/0.6/[node|way|relation]/#id` ----

    x$version <- 2
    delete_version <- character(nrow(x))
    for (i in rev(seq_len(nrow(x)))) {
      delete_version[i] <- osm_delete_object(x[i, ], changeset_id = changeset_id)
    }

    osm_close_changeset(changeset_id)
  })

  expect_match(create_id, "[0-9]+")
  lapply(update_version, expect_identical, "2")
  lapply(delete_version, expect_identical, "3")


  ## Test errors

  expect_error(
    osm_create_object(x = "doesnt_exist", changeset_id = changeset_id),
    "`x` is interpreted as a path to an xml file, but it can't be found "
  )
  expect_error(osm_create_object(x = data.frame(), changeset_id = changeset_id), "`x` lacks ")
  expect_error(
    osm_create_object(x = list(), changeset_id = changeset_id),
    "`x` must be a path to a xml file, a `xml_document` "
  )

  expect_error(
    osm_update_object(x = "doesnt_exist", changeset_id = changeset_id),
    "`x` is interpreted as a path to an xml file, but it can't be found "
  )
  expect_error(osm_update_object(x = data.frame(), changeset_id = changeset_id), "`x` lacks ")
  expect_error(
    osm_update_object(x = list(), changeset_id = changeset_id),
    "`x` must be a path to a xml file, a `xml_document` "
  )

  expect_error(
    osm_delete_object(x = "doesnt_exist", changeset_id = changeset_id),
    "`x` is interpreted as a path to an xml file, but it can't be found "
  )
  expect_error(osm_delete_object(x = data.frame(), changeset_id = changeset_id), "`x` lacks ")
  expect_error(
    osm_delete_object(x = list(), changeset_id = changeset_id),
    "`x` must be a path to a xml file, a `xml_document` "
  )
})


## History: `GET /api/0.6/[node|way|relation]/#id/history` ----

test_that("osm_history_object works", {
  history <- list()
  with_mock_dir("mock_history_object", {
    history$node <- osm_history_object(osm_type = "node", osm_id = 35308286)
    history$way <- osm_history_object(osm_type = "way", osm_id = 13073736L)
    history$rel <- osm_history_object(osm_type = "relation", osm_id = "40581")
  })

  lapply(history, expect_s3_class, c("osmapi_objects", "data.frame"))
  lapply(history, function(x) {
    lapply(x$members, function(y) {
      expect_true(is.null(y) | inherits(y, "way_members") | inherits(y, "relation_members"))
    })
  })
  expect_identical(names(history$node)[seq_len(length(column_objects))], column_objects)
  lapply(history[c("way", "rel")], function(x) {
    expect_identical(names(x)[seq_len(length(column_objects))], column_objects)
  })

  # methods
  lapply(history, function(x) expect_snapshot(print(x)))
})


## Version: `GET /api/0.6/[node|way|relation]/#id/#version` ----

test_that("osm_version_object works", {
  version <- list()
  with_mock_dir("mock_version_object", {
    version$node <- osm_get_objects(osm_type = "node", osm_id = 35308286, version = 1)
    version$way <- osm_get_objects(osm_type = "way", osm_id = 13073736L, version = 2)
    version$rel <- osm_get_objects(osm_type = "relation", osm_id = "40581", version = 3)
  })

  lapply(version, expect_s3_class, c("osmapi_objects", "data.frame"))
  lapply(version, function(x) {
    lapply(x$members, function(y) {
      expect_true(is.null(y) | inherits(y, "way_members") | inherits(y, "relation_members"))
    })
  })
  expect_identical(names(version$node)[seq_len(length(column_objects))], column_objects)
  lapply(version[c("way", "rel")], function(x) {
    expect_identical(names(x)[seq_len(length(column_objects))], column_objects)
  })

  # methods
  lapply(version, function(x) expect_snapshot(print(x)))
})


## Multi fetch: `GET /api/0.6/[nodes|ways|relations]?#parameters` ----

test_that("osm_fetch_objects works", {
  fetch <- list()
  fetch_xml <- list()
  with_mock_dir("mock_fetch_objects", {
    fetch$node <- osm_get_objects(osm_type = "node", osm_id = c(35308286, 1935675367))
    fetch$way <- osm_get_objects(osm_type = "way", osm_id = c(13073736L, 235744929L))
    fetch$way_wide_tags <- osm_get_objects(osm_type = "way", osm_id = c(13073736L, 235744929L), tags_in_columns = TRUE)
    # Specific versions
    fetch$rel <- osm_get_objects(osm_type = "relation", osm_id = c("40581", "341530"), version = c(3, 1))

    fetch_xml$node <- osm_get_objects(osm_type = "node", osm_id = c(35308286, 1935675367), format = "xml")
    fetch_xml$way <- osm_get_objects(osm_type = "way", osm_id = c(13073736L, 235744929L), format = "xml")
    # Specific versions
    fetch_xml$rel <- osm_get_objects(
      osm_type = "relation", osm_id = c("40581", "341530"), version = c(3, 1), format = "xml"
    )
  })

  lapply(fetch, expect_s3_class, c("osmapi_objects", "data.frame"))
  lapply(fetch, function(x) {
    lapply(x$members, function(y) {
      expect_true(is.null(y) | inherits(y, "way_members") | inherits(y, "relation_members"))
    })
  })
  expect_identical(names(fetch$node)[seq_len(length(column_objects))], column_objects)
  lapply(fetch[c("way", "rel")], function(x) {
    expect_identical(names(x)[seq_len(length(column_objects))], column_objects)
  })

  lapply(fetch_xml, expect_s3_class, "xml_document")


  ### test transformation df <-> xml ----

  mapply(function(df, xml) {
    expect_identical(xml2::xml_children(object_DF2xml(df)), xml2::xml_children(xml))
    expect_identical(object_xml2DF(xml), df)
  }, df = fetch[names(fetch_xml)], xml = fetch_xml)


  ### Test long URL in batches to avoid ERROR: HTTP 414 URI Too Long ----

  # osm_ids <- unique(sort(toponimsCat::municipis$id))
  # seq_ids <- list(osm_ids[1])
  # k <- 1
  # for (i in seq_len(length(osm_ids))[-1]) {
  #   if (osm_ids[i] - osm_ids[i - 1] > 1) {
  #     k <- k + 1
  #     seq_ids[[k]] <- osm_ids[i]
  #   } else if (osm_ids[i + 1] - osm_ids[i] > 1) {
  #     seq_ids[[k]] <- c(seq_ids[[k]], osm_ids[i])
  #   }
  # }
  # cmd <- paste0("osm_ids <- c(", paste(sapply(seq_ids, function(x) paste(x, collapse = ":")), collapse = ", "), ")")
  # all.equal(osm_ids, eval(parse(text = cmd)))
  # cat(cmd)

  osm_ids <- c( ## Municipis PPCC
    18000, 18311, 18316, 18318, 18326, 18328, 18349:18352, 18354, 18362:18363, 18375, 18391, 18409, 18416:18417, 18419,
    18428, 18475:18479, 18482, 18484, 18496, 20224, 20339, 22531, 22588, 23234, 23237, 23266, 23303, 23308, 23315,
    23324, 23340, 23759, 23763, 23790, 23795, 23804, 23814, 23823, 23895, 24457:24459, 24858, 24940, 25873, 27529,
    34167, 40581, 51547, 53365, 54461, 54467, 54469, 54471, 74277, 74281, 74284, 74308:74310, 74988, 74993, 80067,
    81599, 123160, 269776, 270405, 271192, 271356, 271429, 271495, 271536, 271664, 271713, 272157, 273497:273498,
    274180, 339488:339490, 339492:339493, 339495, 339498:339503, 339506:339511, 339513:339515, 339534, 339536:339537,
    339568, 339572:339574, 339577, 339584, 339613:339622, 339664, 339809:339811, 339815:339821, 339823:339824, 339847,
    339849:339852, 339854:339855, 339858, 339862, 339873:339880, 339887, 339928, 339930, 339963:339972, 340014, 340016,
    340030, 340174:340179, 340193:340204, 340206:340211, 340216:340217, 340257, 340259, 340261, 340307, 340319,
    340328:340331, 340341:340351, 340373:340375, 340377, 340379:340382, 340390, 340413, 340438:340439, 340441:340442,
    340445:340448, 340454, 340476, 340485, 340487:340488, 340492, 340498, 340500:340502, 340506:340507, 340518,
    340526:340528, 340530:340553, 340555, 340561:340562, 340661, 340689, 340694, 340696:340697, 340700, 340791, 340826,
    340828, 340843, 340848:340856, 340858:340859, 340865:340872, 340908, 340920, 340928, 340930:340933, 340935, 340975,
    341046:341047, 341049:341051, 341053, 341056, 341135, 341140:341142, 341144:341148, 341193, 341195, 341224,
    341230:341236, 341240:341241, 341308:341311, 341314:341315, 341318:341321, 341323, 341330, 341355, 341395:341397,
    341410, 341413, 341416:341418, 341444:341450, 341473, 341476, 341484:341486, 341497, 341530, 341537, 341540, 341559,
    341695:341702, 341709, 341711, 341730, 341733, 341745, 341762, 341774:341775, 341787, 341789, 341791, 341802:341809,
    341814:341815, 341826:341829, 341831:341834, 341837, 341841, 341843, 341845:341846, 341848, 341850:341852,
    341894:341901, 341903:341904, 341981, 341996:341999, 342001:342007, 342064:342073, 342133:342134, 342136:342143,
    342152:342153, 342164, 342166:342171, 342210, 342212, 342214:342217, 342250:342258, 342333:342345, 342347:342349,
    342355:342364, 342416, 342418:342419, 342422:342423, 342427, 342447, 342454, 342456, 342470, 342477:342478,
    342491:342499, 342502, 342505:342507, 342517:342526, 342544, 342552, 342590, 342597:342603, 342605, 342670:342671,
    342673:342675, 342677:342678, 342680:342681, 342688:342696, 342698, 342712, 342726:342734, 342737, 342742, 342784,
    342788:342789, 342792, 342826, 342829:342830, 342833:342839, 342890:342891, 342903, 342910, 342912, 342914:342922,
    342934, 342939, 342959:342961, 342985:342993, 343010:343014, 343017:343018, 343020:343023, 343059, 343063, 343117,
    343119, 343121, 343123:343126, 343185:343190, 343215:343222, 343235:343236, 343242, 343305:343320, 343322:343324,
    343328:343329, 343332, 343334:343335, 343347:343352, 343396:343398, 343400:343401, 343406:343410, 343436, 343441,
    343444:343445, 343447:343449, 343470:343471, 343500, 343505:343506, 343511, 343534:343542, 343586, 343589,
    343629:343640, 343642, 343644:343645, 343647:343648, 343659, 343668:343672, 343710:343719, 343729, 343818,
    343834:343842, 343893:343894, 343936:343937, 343939:343945, 343953:343962, 343964:343967, 343970:343971,
    344060:344069, 344117:344118, 344126:344135, 344174, 344198:344206, 344255, 344257:344262, 344264, 344266:344273,
    344294:344301, 344372:344381, 344392, 344394, 344403:344406, 344419, 344437, 344515:344523, 344537, 344563, 344581,
    344583, 344585, 344591, 344610:344617, 344624:344634, 344648, 344674, 344730:344731, 344742, 344744:344745, 344825,
    344856, 344858, 344861:344862, 344864, 344867, 344873, 344885, 344887, 344919:344925, 344927:344929, 344932:344935,
    344940:344948, 344950, 344953, 344956, 344964, 344966, 345011, 345022, 345031, 345033:345041, 345064, 345154,
    345165, 345172:345173, 345185, 345204:345208, 345210:345214, 345216:345217, 345219:345225, 345244:345246, 345248,
    345267:345269, 345272, 345282, 345284:345292, 345327, 345329, 345361, 345368, 345396:345398, 345400:345402,
    345405:345406, 345415, 345423, 345430, 345448, 345466:345467, 345484:345486, 345489:345498, 345513:345515,
    345517:345519, 345521:345522, 345526, 345549, 345553:345554, 345583, 345587, 345594:345595, 345598:345599,
    345601:345603, 345694:345696, 345698:345699, 345701:345702, 345704, 345708:345709, 345761, 345764, 345773,
    345806:345807, 345816, 345823, 345855, 345920:345923, 345937, 345941:345946, 345952, 345972, 345996:345997,
    345999:346000, 346003:346005, 346025:346028, 346030:346032, 346037, 346042, 346046, 346050, 346070:346076, 346099,
    346101, 346110:346113, 346131, 346228:346237, 346241, 346254, 346265, 346321, 346327:346328, 346333:346334,
    346336:346337, 346345:346349, 346361, 346363:346365, 346367, 346371:346374, 346383, 346387, 346389, 346437:346446,
    346485, 346487:346488, 346540:346541, 346543:346552, 346555:346558, 346560:346561, 346608:346617, 346643,
    346680:346688, 346690, 346698, 346710:346711, 346717, 346719, 346721:346731, 346734, 346746, 346758:346759, 346793,
    346802:346803, 346844:346845, 346847:346852, 346854:346871, 346883, 346900:346901, 346941:346944, 346981:346983,
    346985:346989, 346992:346993, 346995:347001, 347018, 347020, 347180, 347188, 347244, 347246:347251, 347253,
    347348:347357, 347361:347362, 347364, 347416, 347418:347424, 347468:347470, 347477:347480, 347510:347518, 347535,
    347537:347538, 347540:347541, 347543:347553, 347608:347611, 347614, 347616:347625, 347634:347645, 347656:347657,
    347678:347679, 347682, 347684:347686, 347764:347773, 347785, 347791, 347826, 347836, 347860:347862, 347864:347867,
    347869:347880, 347882, 347884:347885, 347889:347896, 347898, 347911, 347946, 347949:347958, 348026, 348044:348046,
    348048:348051, 348053:348059, 348103, 348113, 348131:348150, 348154, 348158, 348160, 348399, 348402, 348405, 348409,
    348412, 348822:348833, 348882, 348886:348895, 348910, 348943:348952, 348970:348971, 348973, 356747, 392022, 392027,
    392033, 392223, 392304, 392308, 401880, 409332, 409377, 409749, 1069580, 1209766, 1235861, 1382208, 1430537,
    1664392:1664395, 1664419:1664420, 1798944:1798945, 1809101:1809102, 1809104, 1809108, 1809111, 1809113, 1809115,
    1809117, 1809121, 1820709, 1821272, 1918699, 1918726, 1918771, 1918812, 1918955, 1919150, 1919385, 1919494, 1920120,
    1920644, 1920758, 1952519, 1966208, 2084436, 2181768, 2548784, 2593113, 2621923, 2768132:2768134, 2804753:2804759,
    2814309, 2814313, 2814562, 2814982, 2815058, 2815362, 2815369, 2816871, 2817026, 2820388, 2820610, 2820751, 2820851,
    2827098, 2827311, 2828302, 2828560, 2829664, 2853657, 2853759, 2853831, 2853900, 2854010, 2854137, 2858704, 2858743,
    2858774, 2862615, 2862650, 2862710, 2862762, 2863980, 2864868, 2865282, 2868083, 2875269, 2875472, 2897486, 2897517,
    2897645, 2912280, 2912304, 2912344, 2912375, 2912388, 2913416, 2913446, 2913461, 2913485, 2913659, 2913745, 2913805,
    2913808, 2913877, 2918640, 2918769, 2918951, 2918996, 2919019, 2919091, 2919179, 2924113, 2924251, 2924277, 2924304,
    2924446, 2926262:2926263, 5245866, 11755232
  )
  osm_ids <- as.character(osm_ids)

  expect_message(set_osmapi_connection(), "Logged out from ") # TODO: why it fails without changing the server?
  # Tests work when running interactively but fail in R CMD check:
  #
  #   Error in `stop_request(req)`: An unexpected request was made:
  #   GET https://master.apis.dev.openstreetmap.org/api/0.6/relations?relations=...
  #
  #   Expected mock file: osm.org/api/0.6/relations-13eee2.*

  fetch_many <- list()
  fetch_many_xml <- list()
  with_mock_dir("mock_fetch_many_objects", {
    fetch_many$rel <- osm_get_objects(osm_type = "relation", osm_id = osm_ids)
    fetch_many$rel_wide_tags <- osm_get_objects(osm_type = "relation", osm_id = osm_ids, tags_in_columns = TRUE)
    # Specific versions
    fetch_many$rel_version <- osm_get_objects(
      osm_type = "relation", osm_id = osm_ids, version = rep(1, length(osm_ids))
    )

    fetch_many_xml$rel <- osm_get_objects(osm_type = "relation", osm_id = osm_ids, format = "xml")
    # Specific versions
    fetch_many_xml$rel_version <- osm_get_objects(
      osm_type = "relation", osm_id = osm_ids, version = rep(1, length(osm_ids)), format = "xml"
    )
  })

  lapply(fetch_many, function(x) {
    id <- x[[intersect(names(x), c("id", "osm_id"))]]
    expect_identical(id, osm_ids)
    expect_false(any(duplicated(id)))
  })
  lapply(fetch_many_xml, function(x) {
    id <- xml2::xml_attr(xml2::xml_children(x), attr = "id")
    expect_identical(id, osm_ids)
    expect_false(any(duplicated(id)))
  })
  expect_message(set_osmapi_connection("testing"), "Logged out from") # TODO

  # methods
  lapply(fetch, function(x) expect_snapshot(print(x)))
})


## Relations for element: `GET /api/0.6/[node|way|relation]/#id/relations` ----

test_that("osm_relations_object works", {
  rels <- list()
  with_mock_dir("mock_relations_object", {
    rels$node <- osm_relations_object(osm_type = "node", osm_id = 1470837704)
    rels$way <- osm_relations_object(osm_type = "way", osm_id = 372011578)
    rels$rel <- osm_relations_object(osm_type = "relation", osm_id = 342792)
  })

  lapply(rels, expect_s3_class, c("osmapi_objects", "data.frame"))
  lapply(rels, function(x) {
    lapply(x$members, function(y) {
      expect_true(is.null(y) | inherits(y, "way_members") | inherits(y, "relation_members"))
    })
  })
  lapply(rels, function(x) expect_identical(names(x)[seq_len(length(column_objects))], column_objects))

  # methods
  lapply(rels, function(x) expect_snapshot(print(x)))
})


## Ways for node: `GET /api/0.6/node/#id/ways` ----

test_that("osm_ways_node works", {
  with_mock_dir("mock_ways_node", {
    ways_node <- osm_ways_node(node_id = 35308286)
  })

  expect_s3_class(ways_node, c("osmapi_objects", "data.frame"))
  lapply(ways_node$members, function(x) {
    expect_true(is.null(x) | inherits(x, "way_members") | inherits(x, "relation_members"))
  })
  expect_identical(names(ways_node)[seq_len(length(column_objects))], column_objects)

  # methods
  expect_snapshot(print(ways_node))
})


## Full: `GET /api/0.6/[way|relation]/#id/full` ----

test_that("osm_full_object works", {
  full <- list()
  with_mock_dir("mock_full_object", {
    full$way <- osm_get_objects(osm_type = "way", osm_id = 13073736, full_objects = TRUE)
    full$rel <- osm_get_objects(osm_type = "relation", osm_id = "6002785", full_objects = TRUE)
    full_xml <- osm_get_objects(
      osm_type = c("relation", "way", "way", "node"),
      osm_id = c(6002785, 13073736, 235744929, 35308286),
      full_objects = TRUE, format = "xml"
    )
  })

  lapply(full, expect_s3_class, c("osmapi_objects", "data.frame"))
  lapply(full, function(x) {
    lapply(x$members, function(y) {
      expect_true(is.null(y) | inherits(y, "way_members") | inherits(y, "relation_members"))
    })
  })
  lapply(full, function(x) expect_identical(names(x)[seq_len(length(column_objects))], column_objects))

  # methods
  lapply(full, function(x) expect_snapshot(print(x)))


  ## xml
  expect_s3_class(full_xml, "xml_document")


  ## json
  with_mock_dir("mock_full_object_json", {
    full_json <- osm_get_objects(
      osm_type = c("relation", "way", "way", "node"),
      osm_id = c(6002785, 13073736, 235744929, 35308286),
      full_objects = TRUE, format = "json"
    )
  })
  expect_type(full_json, "list")
  expect_named(full_json, c("version", "generator", "copyright", "attribution", "license", "elements"))
  lapply(full_json$elements, function(x) {
    expect_contains(names(x), c("type", "id", "timestamp", "version", "changeset", "user", "uid"))
  })
})


## Redaction: `POST /api/0.6/[node|way|relation]/#id/#version/redact?redaction=#redaction_id` ----

test_that("osm_redaction_object works", {
  x <- data.frame(type = "node", lat = 0, lon = 0, name = "Test redaction.")
  obj <- osmapi_objects(x, tag_columns = "name")

  with_mock_dir("mock_redact_object", {
    expect_message(
      changeset_id <- osm_create_changeset(
        comment = "Test object redaction",
        created_by = "osmapiR", # avoid changes in calls when updating version
        hashtags = "#testing;#osmapiR",
        verbose = TRUE
      ),
      "New changeset with id = "
    )

    node_id <- osm_create_object(x = obj, changeset_id = changeset_id)
    node_osm <- osm_get_objects(osm_type = "node", osm_id = node_id)
    deleted_version <- osm_delete_object(x = node_osm, changeset_id = changeset_id)
    redaction <- osm_redaction_object(osm_type = node_osm$type, osm_id = node_osm$id, version = 1, redaction_id = 1)
    unredaction <- osm_redaction_object(osm_type = node_osm$type, osm_id = node_osm$id, version = 1)

    osm_close_changeset(changeset_id = changeset_id)
  })

  expect_null(redaction)
  expect_null(unredaction)
})
