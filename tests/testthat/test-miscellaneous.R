## Available API versions: `GET /api/versions` ----

test_that("osm_api_versions works", {
  with_mock_dir("mock_api_versions", {
    api_versions <- osm_api_versions()
  })

  expect_type(api_versions, "character")
  expect_identical(api_versions, "0.6")
})


## Capabilities: `GET /api/capabilities` ----

test_that("osm_capabilities works", {
  with_mock_dir("mock_capabilities", {
    capabilities <- osm_capabilities()
  })

  expect_type(capabilities, "list")
})


## Retrieving map data by bounding box: `GET /api/0.6/map` ----

test_that("osm_bbox_objects works", {
  with_mock_dir("mock_bbox_objects", {
    bbox_objects <- osm_bbox_objects(bbox = c(1.8366775, 41.8336843, 1.8379971, 41.8344537))
  })

  expect_s3_class(bbox_objects, c("osmapi_objects", "data.frame"))
  lapply(bbox_objects$members, function(x) {
    expect_true(is.null(x) | inherits(x, "way_members") | inherits(x, "relation_members"))
  })

  obj_cols <- c(
    "type", "id", "visible", "version", "changeset", "timestamp", "user", "uid", "lat", "lon", "members", "tags"
  )
  expect_identical(names(bbox_objects), obj_cols)
  expect_named(attr(bbox_objects, "bbox"), c("minlat", "minlon", "maxlat", "maxlon"))

  class_columns <- list(
    type = "character", id = "character", visible = "logical", version = "integer", changeset = "character",
    timestamp = "POSIXct", user = "character", uid = "character", lat = "character", lon = "character",
    members = "list", tags = "list"
  )
  mapply(function(x, cl) expect_true(inherits(x, cl)), x = bbox_objects, cl = class_columns[names(bbox_objects)])

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  expect_false(unique(strftime(as.POSIXct(bbox_objects$time), format = "%M:%S") == "00:00"))


  # methods
  expect_snapshot(print(bbox_objects))


  ## Empty results

  with_mock_dir("mock_bbox_objects_empty", {
    empty_bbox_objects <- osm_bbox_objects(bbox = c(-180, 0, -179.9, 0.1))
  })

  expect_s3_class(empty_bbox_objects, c("osmapi_objects", "data.frame"), exact = TRUE)
  expect_identical(names(empty_bbox_objects), obj_cols)
  expect_named(attr(empty_bbox_objects, "bbox"), c("minlat", "minlon", "maxlat", "maxlon"))
  expect_identical(nrow(empty_bbox_objects), 0L)

  mapply(
    function(x, cl) expect_true(inherits(x, cl)),
    x = empty_bbox_objects,
    cl = class_columns[names(empty_bbox_objects)]
  )


  # methods
  expect_snapshot(print(empty_bbox_objects))
})


## Retrieving permissions: `GET /api/0.6/permissions` ----

test_that("osm_permissions works", {
  with_mock_dir("mock_permissions", {
    perms <- osm_permissions()
  })

  expect_type(perms, "character")
})
