column_attrs <- c(
  "id", "created_at", "closed_at", "open", "user", "uid",
  "min_lat", "min_lon", "max_lat", "max_lon", "comments_count", "changes_count", "discussion", "tags"
)
column_discuss <- c("date", "uid", "user", "comment_text")

class_columns <- list(
  id = "character", created_at = "POSIXct", closed_at = "POSIXct", open = "logical", user = "character",
  uid = "character", min_lat = "character", min_lon = "character", max_lat = "character", max_lon = "character",
  comments_count = "integer", changes_count = "integer", discussion = "list", tags = "list"
)

class_columns_discussion <- list(
  date = "POSIXct", uid = "character", user = "character", comment_text = "character"
)

## Create: `PUT /api/0.6/changeset/create` ----

test_that("osm_create_changeset works", {
  # osm_create_changeset()
})


## Read: `GET /api/0.6/changeset/#id*?include_discussion='true'*` ----

test_that("osm_read_changeset works", {
  with_mock_dir("mock_read_changeset", {
    chaset <- osm_read_changeset(changeset_id = 137595351)
    chaset_discuss <- osm_read_changeset(changeset_id = 137595351, include_discussion = TRUE)
  })

  expect_s3_class(chaset, c("osmapi_changesets", "data.frame"))
  expect_s3_class(chaset_discuss, c("osmapi_changesets", "data.frame"))
  expect_identical(names(chaset), setdiff(column_attrs, "discussion"))
  expect_identical(names(chaset_discuss), c(column_attrs))
  lapply(chaset_discuss$discussion, function(x) {
    expect_s3_class(x, c("changeset_comments", "data.frame"))
    expect_named(x, column_discuss)

    mapply(function(y, cl) expect_true(inherits(y, cl)), y = x, cl = class_columns_discussion[names(x)])

    # Check that time is extracted, otherwise it's 00:00:00 in local time
    expect_false(all(strftime(as.POSIXct(x$date), format = "%M:%S") == "00:00"))
  })

  mapply(function(x, cl) expect_true(inherits(x, cl)), x = chaset, cl = class_columns[names(chaset)])
  mapply(function(x, cl) expect_true(inherits(x, cl)), x = chaset_discuss, cl = class_columns[names(chaset_discuss)])

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  lapply(chaset[, c("created_at", "closed_at")], function(x) expect_false(strftime(as.POSIXct(x), format = "%M:%S") == "00:00"))
  lapply(chaset_discuss[, c("created_at", "closed_at")], function(x) expect_false(strftime(as.POSIXct(x), format = "%M:%S") == "00:00"))

  # methods
  expect_s3_class(print(chaset), c("osmapi_changesets", "data.frame"))
  expect_s3_class(print(chaset_discuss), c("osmapi_changesets", "data.frame"))
})


## Update: `PUT /api/0.6/changeset/#id` ----

test_that("osm_update_changeset works", {
  # osm_update_changeset(changeset_id)
})


## Close: `PUT /api/0.6/changeset/#id/close` ----

test_that("osm_close_changeset works", {
  # osm_close_changeset(changeset_id)
})


## Download: `GET /api/0.6/changeset/#id/download` ----

test_that("osm_download_changeset works", {
  with_mock_dir("mock_download_changeset", {
    chaset <- osm_download_changeset(changeset_id = 137003062)
  })
  # osmChange format
})


## Query: `GET /api/0.6/changesets` ----

test_that("osm_query_changesets works", {
  chaset <- list()
  with_mock_dir("mock_query_changesets", {
    chaset$ids <- osm_query_changesets(changeset_ids = c(137627129, 137625624))
    chaset$time <- osm_query_changesets(
      bbox = c(-1.241112, 38.0294955, 8.4203171, 42.9186456),
      user = "Mementomoristultus",
      time = "2023-06-22T02:23:23Z",
      time_2 = "2023-06-22T00:38:20Z"
    )
    chaset$closed <- osm_query_changesets(
      bbox = c("-9.3015367,41.8073642,-6.7339533,43.790422"),
      user = "Mementomoristultus",
      closed = TRUE
    )
  })

  lapply(chaset, expect_s3_class, c("osmapi_changesets", "data.frame"))
  lapply(chaset, function(x) expect_identical(names(x), setdiff(column_attrs, "discussion")))
  lapply(chaset, function(x) {
    lapply(x$discussion, function(y) {
      expect_s3_class(y, c("changeset_comments", "data.frame"))
      expect_named(y, column_discuss)
    })
  })

  # methods
  lapply(print(chaset), expect_s3_class, c("osmapi_changesets", "data.frame"))


  ## Empty results

  with_mock_dir("mock_query_changesets_empty", {
    empty_chaset <- osm_query_changesets(bbox = c(-180, 0, -179.9, 0.1), user = "jmaspons")
  })

  expect_s3_class(empty_chaset, c("osmapi_changesets", "data.frame"))
  expect_identical(names(empty_chaset), setdiff(column_attrs, "discussion"))
  expect_identical(nrow(empty_chaset), 0L)

  mapply(
    function(x, cl) expect_true(inherits(x, cl)),
    x = empty_chaset,
    cl = class_columns[names(empty_chaset)]
  )

  # methods
  expect_s3_class(print(empty_chaset), c("osmapi_changesets", "data.frame"))
})


## Diff upload: `POST /api/0.6/changeset/#id/upload` ----

test_that("osm_diff_upload_changeset works", {
  # osm_diff_upload_changeset(changeset_id)
})
