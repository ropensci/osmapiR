column_attrs <- c(
  "id", "created_at", "closed_at", "open", "user", "uid",
  "min_lat", "min_lon", "max_lat", "max_lon", "comments_count", "changes_count"
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

  expect_s3_class(chaset, "data.frame")
  expect_s3_class(chaset_discuss, "data.frame")
  expect_identical(names(chaset)[seq_len(length(column_attrs))], column_attrs)
  expect_identical(names(chaset_discuss)[seq_len(length(column_attrs) + 1)], c(column_attrs, "discussion"))
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

  lapply(chaset, expect_s3_class, "data.frame")
  lapply(chaset, function(x) expect_identical(names(x)[seq_len(length(column_attrs))], column_attrs))
})


## Diff upload: `POST /api/0.6/changeset/#id/upload` ----

test_that("osm_diff_upload_changeset works", {
  # osm_diff_upload_changeset(changeset_id)
})
