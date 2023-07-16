column_attrs <- c("type", "id", "visible", "version", "changeset", "timestamp", "user", "uid", "members")
column_attrs_node <- c("type", "id", "visible", "version", "changeset", "timestamp", "user", "uid", "lat", "lon", "members")


## Create: `PUT /api/0.6/[node|way|relation]/create` ----

test_that("osm_create_object works", {
  # osm_create_object(osm_type = c("node", "way", "relation"), ...)
})


## Read: `GET /api/0.6/[node|way|relation]/#id` ----

test_that("osm_read_object works", {
  read <- list()
  with_mock_dir("mock_read_object", {
    read$node <- osm_read_object(osm_type = "node", osm_id = 35308286)
    read$way <- osm_read_object(osm_type = "way", osm_id = 13073736L)
    read$rel <- osm_read_object(osm_type = "relation", osm_id = "40581")
  })

  lapply(read, expect_s3_class, c("osmapi_objects", "data.frame"))
  lapply(read, function(x) {
    lapply(x$members, function(y) {
      expect_true(is.null(y) | inherits(y, "way_members") | inherits(y, "relation_members"))
    })
  })
  expect_identical(names(read$node)[seq_len(length(column_attrs_node))], column_attrs_node)
  lapply(read[c("way", "rel")], function(x) expect_identical(names(x)[seq_len(length(column_attrs))], column_attrs))

  # methods
  lapply(print(read), expect_s3_class, c("osmapi_objects", "data.frame"))
})


## Update: `PUT /api/0.6/[node|way|relation]/#id` ----

test_that("osm_update_object works", {
  # osm_update_object(osm_type = c("node", "way", "relation"), osm_id)
})


## Delete: `DELETE /api/0.6/[node|way|relation]/#id` ----

test_that("osm_delete_object works", {
  # osm_delete_object(osm_type = c("node", "way", "relation"), osm_id)
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
  expect_identical(names(history$node)[seq_len(length(column_attrs_node))], column_attrs_node)
  lapply(history[c("way", "rel")], function(x) expect_identical(names(x)[seq_len(length(column_attrs))], column_attrs))

  # methods
  lapply(print(history), expect_s3_class, c("osmapi_objects", "data.frame"))
})


## Version: `GET /api/0.6/[node|way|relation]/#id/#version` ----

test_that("osm_version_object works", {
  version <- list()
  with_mock_dir("mock_version_object", {
    version$node <- osm_version_object(osm_type = "node", osm_id = 35308286, version = 1)
    version$way <- osm_version_object(osm_type = "way", osm_id = 13073736L, version = 2)
    version$rel <- osm_version_object(osm_type = "relation", osm_id = "40581", version = 3)
  })

  lapply(version, expect_s3_class, c("osmapi_objects", "data.frame"))
  lapply(version, function(x) {
    lapply(x$members, function(y) {
      expect_true(is.null(y) | inherits(y, "way_members") | inherits(y, "relation_members"))
    })
  })
  expect_identical(names(version$node)[seq_len(length(column_attrs_node))], column_attrs_node)
  lapply(version[c("way", "rel")], function(x) expect_identical(names(x)[seq_len(length(column_attrs))], column_attrs))

  # methods
  lapply(print(version), expect_s3_class, c("osmapi_objects", "data.frame"))
})


## Multi fetch: `GET /api/0.6/[nodes|ways|relations]?#parameters` ----

test_that("osm_fetch_objects works", {
  fetch <- list()
  with_mock_dir("mock_fetch_objects", {
    fetch$node <- osm_fetch_objects(osm_type = "nodes", osm_ids = c(35308286, 1935675367))
    fetch$way <- osm_fetch_objects(osm_type = "ways", osm_ids = c(13073736L, 235744929L))
    # Specific versions
    fetch$rel <- osm_fetch_objects(osm_type = "relations", osm_ids = c("40581", "341530"), versions = c(3, 1))
  })

  lapply(fetch, expect_s3_class, c("osmapi_objects", "data.frame"))
  lapply(fetch, function(x) {
    lapply(x$members, function(y) {
      expect_true(is.null(y) | inherits(y, "way_members") | inherits(y, "relation_members"))
    })
  })
  expect_identical(names(fetch$node)[seq_len(length(column_attrs_node))], column_attrs_node)
  lapply(fetch[c("way", "rel")], function(x) expect_identical(names(x)[seq_len(length(column_attrs))], column_attrs))

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
  lapply(rels, function(x) expect_identical(names(x)[seq_len(length(column_attrs))], column_attrs))

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
  expect_identical(names(ways_node)[seq_len(length(column_attrs))], column_attrs)

  # methods
  expect_s3_class(print(ways_node), c("osmapi_objects", "data.frame"))
})


## Full: `GET /api/0.6/[way|relation]/#id/full` ----

test_that("osm_full_object works", {
  full <- list()
  with_mock_dir("mock_full_object", {
    full$way <- osm_full_object(osm_type = "way", osm_id = 13073736)
    full$rel <- osm_full_object(osm_type = "relation", osm_id = "6002785")
  })
  # Warning messages:
  # 1: In (function (..., deparse.level = 1)  :
  #   number of columns of result is not a multiple of vector length (arg 61)

  lapply(full, expect_s3_class, c("osmapi_objects", "data.frame"))
  lapply(full, function(x) {
    lapply(x$members, function(y) {
      expect_true(is.null(y) | inherits(y, "way_members") | inherits(y, "relation_members"))
    })
  })
  lapply(full, function(x) expect_identical(names(x)[seq_len(length(column_attrs_node))], column_attrs_node))

  # methods
  lapply(print(full), expect_s3_class, c("osmapi_objects", "data.frame"))
})


## Redaction: `POST /api/0.6/[node|way|relation]/#id/#version/redact?redaction=#redaction_id` ----

test_that("osm_redaction_object works", {
  # osm_redaction_object(osm_type = c("node", "way", "relation"), osm_id, version, redaction_id)
})
