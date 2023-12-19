column_objects <- c(
  "type", "id", "visible", "version", "changeset", "timestamp", "user", "uid", "lat", "lon", "members", "tags"
)

class_columns <- list(
  type = "character", id = "character", visible = "logical", version = "integer", changeset = "character",
  timestamp = "POSIXct", user = "character", uid = "character", lat = "character", lon = "character",
  members = "list", tags = "list"
)


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
  lapply(print(read), expect_s3_class, c("osmapi_objects", "data.frame"))
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
    changeset_id <- osm_create_changeset(
      comment = "Test object creation",
      created_by = "osmapiR", # avoid changes in calls when updating version
      source = "Imagination",
      hashtags = "#testing;#osmapiR",
      verbose = TRUE
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

    # osm_close_changeset(changeset_id)
    # TODO: Error in `resp_body_raw()`: ! Can not retrieve empty body. Fixed in httptest2 > 0.1.0
    # https://github.com/nealrichardson/httptest2/pull/28
  })

  expect_match(create_id, "[0-9]+")
  lapply(update_version, expect_identical, "2")
  lapply(delete_version, expect_identical, "3")
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
  lapply(print(history), expect_s3_class, c("osmapi_objects", "data.frame"))
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
  lapply(print(version), expect_s3_class, c("osmapi_objects", "data.frame"))
})


## Multi fetch: `GET /api/0.6/[nodes|ways|relations]?#parameters` ----

test_that("osm_fetch_objects works", {
  fetch <- list()
  fetch_xml <- list()
  with_mock_dir("mock_fetch_objects", {
    fetch$node <- osm_get_objects(osm_type = "node", osm_id = c(35308286, 1935675367))
    fetch$way <- osm_get_objects(osm_type = "way", osm_id = c(13073736L, 235744929L))
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
  }, df = fetch, xml = fetch_xml)


  # methods
  lapply(print(fetch), expect_s3_class, c("osmapi_objects", "data.frame"))
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
  lapply(print(rels), expect_s3_class, c("osmapi_objects", "data.frame"))
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
  expect_s3_class(print(ways_node), c("osmapi_objects", "data.frame"))
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
  lapply(print(full), expect_s3_class, c("osmapi_objects", "data.frame"))


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
  # osm_redaction_object(osm_type = c("node", "way", "relation"), osm_id, version, redaction_id)
})
