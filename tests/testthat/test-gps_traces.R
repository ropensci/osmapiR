column_meta_gpx <- c("id", "name", "user", "visibility", "pending", "timestamp", "lat", "lon", "description", "tags")
# column_gpx <- TODO: gpx_xml2DF


## Get GPS Points: `GET /api/0.6/trackpoints?bbox=*'left','bottom','right','top'*&page=*'pageNumber'*` ----

test_that("osm_get_points_gps works", {
  with_mock_dir("mock_get_points_gps", {
    # pts_gps <- osm_get_points_gps(bbox = c(-0.4789191, 38.1662652, -0.4778007, 38.1677898))
  })

  # expect_s3_class(pts_gps, "data.frame")
  # expect_named(pts_gps, column_gpx)
})


## Create: `POST /api/0.6/gpx/create` ----

test_that("osm_create_gpx works", {
  with_mock_dir("mock_create_gpx", {
    # osm_create_gpx()
  })
})


## Update: `PUT /api/0.6/gpx/#id` ----

test_that("osm_update_gpx works", {
  with_mock_dir("mock_update_gpx", {
    # osm_update_gpx(gpx_id)
  })
})


## Delete: `DELETE /api/0.6/gpx/#id` ----

test_that("osm_delete_gpx works", {
  with_mock_dir("mock_delete_gpx", {
    # osm_delete_gpx(gpx_id)
  })
})


## Download Metadata: `GET /api/0.6/gpx/#id/details` ----

test_that("osm_get_metadata_gpx works", {
  with_mock_dir("mock_get_metadata_gpx", {
    trk_meta <- osm_get_metadata_gpx(gpx_id = 3790367)
  })

  expect_s3_class(trk_meta, "data.frame")
  expect_named(trk_meta, column_meta_gpx)
})


## Download Data: `GET /api/0.6/gpx/#id/data` ----

#' @param format If missing (default), the response will be the exact file that was uploaded.
#'   If `gpx`, the response will always be a GPX format file.
#'   If `xml`, a `XML` file in an undocumented format.
test_that("osm_get_data_gpx works", {
  trk_data <- list()
  with_mock_dir("mock_get_data_gpx", {
    # # trk_data$raw <- osm_get_data_gpx(gpx_id = 3458743) # TODO: HTTP 400 Bad Request. without format
    # trk_data$gpx <- osm_get_data_gpx(gpx_id = 3458743, format = "gpx")
    # trk_data$xml <- osm_get_data_gpx(gpx_id = 3458743, format = "xml")
  })

  # lapply(trk_data, expect_s3_class, "data.frame")
  # lapply(trk_data, expect_named, column_gpx)
})


## List: `GET /api/0.6/user/gpx_files` ----

test_that("osm_list_gpxs works", {
  with_mock_dir("mock_list_gpxs", {
    traces <- osm_list_gpxs()
  })

  expect_s3_class(traces, "data.frame")
  expect_named(traces, column_meta_gpx)
})
