column_meta_gpx <- c(
  "id", "name", "uid", "user", "visibility", "pending", "timestamp", "lat", "lon", "description", "tags"
)
column_meta_gpx_sf <- c(
  "id", "name", "uid", "user", "visibility", "pending", "timestamp", "description", "tags", "geometry"
)
column_gpx <- c("lat", "lon", "ele", "time")
column_pts_gps <- c("lat", "lon", "time")
column_pts_gps_sf <- c("track_url", "track_name", "track_desc", "geometry")
column_pts_gps_sfpoints <- c("time", "geometry")

class_columns <- list(
  id = "character", name = "character", uid = "character", user = "character", visibility = "character",
  pending = "logical", timestamp = "POSIXct", lat = "character", lon = "character", description = "character",
  tags = "list", ele = "character", time = "POSIXct", geometry = c("sfc_POINT", "sfc"),
  atemp = "character", hr = "character", cad = "character"
)


## Get GPS Points: `GET /api/0.6/trackpoints?bbox=*'left','bottom','right','top'*&page=*'pageNumber'*` ----

test_that("osm_get_points_gps works", {
  pts_gps <- list()
  sf_gps <- list()
  sfp_gps <- list()
  xml_gps <- list()
  with_mock_dir("mock_get_points_gps", {
    pts_gps$private <- osm_get_points_gps(bbox = c(-0.4789191, 38.1662652, -0.4778007, 38.1677898))
    pts_gps$public <- osm_get_points_gps(bbox = c(-0.6430006, 38.1073445, -0.6347179, 38.1112953))
    pts_gps$all_pages <- osm_get_points_gps(bbox = "-0.6683636,38.0610674,-0.6388378,38.1", page_number = -1)

    sf_gps$private <- osm_get_points_gps(bbox = c(-0.4789191, 38.1662652, -0.4778007, 38.1677898), format = "sf")
    sf_gps$public <- osm_get_points_gps(bbox = c(-0.6430006, 38.1073445, -0.6347179, 38.1112953), format = "sf")
    sf_gps$all_pages <- osm_get_points_gps(
      bbox = "-0.6683636,38.0610674,-0.6388378,38.1", page_number = -1, format = "sf"
    )

    sfp_gps$private <- osm_get_points_gps(
      bbox = c(-0.4789191, 38.1662652, -0.4778007, 38.1677898), format = "sf_points"
    )
    sfp_gps$public <- osm_get_points_gps(bbox = c(-0.6430006, 38.1073445, -0.6347179, 38.1112953), format = "sf_points")
    sfp_gps$all_pages <- osm_get_points_gps(
      bbox = "-0.6683636,38.0610674,-0.6388378,38.1", page_number = -1, format = "sf_points"
    )

    xml_gps$private <- osm_get_points_gps(bbox = c(-0.4789191, 38.1662652, -0.4778007, 38.1677898), format = "gpx")
    xml_gps$public <- osm_get_points_gps(bbox = c(-0.6430006, 38.1073445, -0.6347179, 38.1112953), format = "gpx")
    xml_gps$all_pages <- osm_get_points_gps(
      bbox = "-0.6683636,38.0610674,-0.6388378,38.1", page_number = -1, format = "gpx"
    )
  })

  lapply(xml_gps, expect_s3_class, "xml_document")

  lapply(pts_gps, expect_s3_class, class = c("osmapi_gpx", "list"), exact = TRUE)
  lapply(sf_gps, expect_s3_class, class = c("sf", "data.frame"), exact = TRUE)
  lapply(sfp_gps, expect_s3_class, class = c("sf_osmapi_gpx", "osmapi_gpx", "list"), exact = TRUE)

  lapply(pts_gps$private, expect_named, setdiff(column_pts_gps, "time"))
  expect_named(sf_gps$private, column_pts_gps_sf)
  lapply(sfp_gps$private, expect_named, setdiff(column_pts_gps_sfpoints, "time"))

  lapply(pts_gps$public, expect_named, column_pts_gps)
  expect_named(sf_gps$public, column_pts_gps_sf)
  lapply(sfp_gps$public, expect_named, column_pts_gps_sfpoints)

  lapply(c(pts_gps, sf_gps, sfp_gps), lapply, function(x) {
    mapply(function(y, cl) expect_true(inherits(y, cl)), y = x, cl = class_columns[names(x)])
  })

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  lapply(pts_gps$public, function(x) expect_false(unique(strftime(as.POSIXct(x$time), format = "%M:%S") == "00:00")))
  lapply(sfp_gps$public, function(x) expect_false(unique(strftime(as.POSIXct(x$time), format = "%M:%S") == "00:00")))

  # Compare sf, xml & R
  mapply(function(l, x) {
    expect_identical(length(l), nrow(x))
  }, l = pts_gps, x = sf_gps)
  mapply(function(l, x) {
    expect_identical(length(l), length(x))
  }, l = pts_gps, x = sfp_gps)
  mapply(function(l, x) {
    expect_identical(length(l), xml2::xml_length(x))
  }, l = pts_gps, x = xml_gps)

  ## Check attributes
  # lapply(pts_gps, function(x) {
  #   a <- attributes(x)
  #   a[setdiff(names(a), c("names", "row.names", "class"))]
  # })
  mapply(function(l, x) {
    expect_identical(attr(l, "gpx_attributes"), attr(x, "gpx_attributes"))
  }, l = pts_gps, x = sf_gps)
  mapply(function(l, x) {
    expect_identical(attr(l, "gpx_attributes"), attr(x, "gpx_attributes"))
  }, l = pts_gps, x = sfp_gps)

  ## Check track attributes
  # lapply(pts_gps, lapply, function(x) {
  #   a <- attributes(x)
  #   a[setdiff(names(a), c("names", "row.names", "class"))]
  # })

  # sf_gps attributes as columns
  mapply(function(l, x) {
    mapply(function(trk, trk_sf) {
      a <- attributes(trk)
      a <- a[setdiff(names(a), c("names", "row.names", "class"))]
      expect_identical(a, attributes(trk_sf)[names(a)])
    }, trk = l, trk_sf = x)
  }, l = pts_gps, x = sfp_gps)


  # methods
  summary_gpx <- lapply(pts_gps, summary)
  lapply(summary_gpx, expect_s3_class, "data.frame")

  summary_gpx_sfp <- lapply(sfp_gps, summary)
  lapply(summary_gpx_sfp, expect_s3_class, "data.frame")


  ## Empty results

  empty_pts <- list()
  empty_sf <- list()
  empty_sfp <- list()
  empty_xml <- list()
  with_mock_dir("mock_get_points_gps_empty", {
    empty_pts$gps <- osm_get_points_gps(bbox = c(-105, -7, -104.9, -6.9))
    empty_pts$all_pages <- osm_get_points_gps(bbox = c(-105, -7, -104.9, -6.9), page_number = -1)

    empty_sf$gps <- osm_get_points_gps(bbox = c(-105, -7, -104.9, -6.9), format = "sf")
    empty_sf$all_pages <- osm_get_points_gps(bbox = c(-105, -7, -104.9, -6.9), page_number = -1, format = "sf")

    empty_sfp$gps <- osm_get_points_gps(bbox = c(-105, -7, -104.9, -6.9), format = "sf_points")
    empty_sfp$all_pages <- osm_get_points_gps(bbox = c(-105, -7, -104.9, -6.9), page_number = -1, format = "sf_points")

    empty_xml$gps <- osm_get_points_gps(bbox = c(-105, -7, -104.9, -6.9), format = "gpx")
    empty_xml$all_pages <- osm_get_points_gps(bbox = c(-105, -7, -104.9, -6.9), page_number = -1, format = "gpx")
  })

  lapply(empty_pts, expect_s3_class, class = c("osmapi_gpx", "list"), exact = TRUE)
  lapply(empty_sf, expect_s3_class, class = c("sf", "data.frame"), exact = TRUE)
  lapply(empty_sfp, expect_s3_class, class = c("sf_osmapi_gpx", "osmapi_gpx", "list"), exact = TRUE)
  lapply(empty_xml, expect_s3_class, "xml_document")

  lapply(empty_pts, expect_length, n = 0)
  lapply(empty_sf, function(x) expect_identical(nrow(x), 0L))
  lapply(empty_sfp, expect_length, n = 0)
  lapply(empty_xml, function(x) expect_identical(xml2::xml_length(x), 0L))


  ## Check attributes
  # lapply(empty_pts, function(x) {
  #   a <- attributes(x)
  #   a[setdiff(names(a), c("names", "row.names", "class"))]
  # })
  mapply(function(l, x) {
    expect_identical(attr(l, "gpx_attributes"), attr(x, "gpx_attributes"))
  }, l = empty_pts, x = empty_sf)
  mapply(function(l, x) {
    expect_identical(attr(l, "gpx_attributes"), attr(x, "gpx_attributes"))
  }, l = empty_pts, x = empty_sfp)


  # methods
  summary_gpx <- lapply(empty_pts, summary)
  lapply(summary_gpx, expect_s3_class, class = "data.frame")

  summary_gpx_sfp <- lapply(empty_sfp, summary)
  lapply(summary_gpx_sfp, expect_s3_class, class = "data.frame")
})


test_that("edit gpx works", {
  gpx_path <- test_path("sample_files", "sample.gpx")

  with_mock_dir("mock_edit_gpx", {
    ## Create: `POST /api/0.6/gpx/create` ----
    gpx_id <- osm_create_gpx(
      file = gpx_path,
      description = "Test create gpx with osmapiR.",
      tags = c("testing", "osmapiR")
    )

    ## Update: `PUT /api/0.6/gpx/#id` ----
    upd_trace <- osm_update_gpx(
      gpx_id = gpx_id, name = "Upd.gpx", description = "Test update gpx with osmapiR",
      tags = c("testing", "osmapiR", "updated"), visibility = "identifiable"
    )

    ## Delete: `DELETE /api/0.6/gpx/#id` ----
    del_trace <- osm_delete_gpx(gpx_id = gpx_id)
  })

  expect_type(gpx_id, "character")
  expect_match(gpx_id, "^[0-9]+$")
  expect_s3_class(upd_trace, "data.frame")
  expect_null(del_trace)
})


## Download Metadata: `GET /api/0.6/gpx/#id/details` ----

test_that("osm_get_metadata_gpx works", {
  trk_meta <- list()
  sf_trk_meta <- list()
  xml_trk_meta <- list()
  with_mock_dir("mock_get_metadata_gpx", {
    trk_meta$track <- osm_get_gpx_metadata(gpx_id = 3790367)
    trk_meta$tracks <- osm_get_gpx_metadata(gpx_id = c(3790367, 3458743))

    sf_trk_meta$track <- osm_get_gpx_metadata(gpx_id = 3790367, format = "sf")
    sf_trk_meta$tracks <- osm_get_gpx_metadata(gpx_id = c(3790367, 3458743), format = "sf")

    xml_trk_meta$track_xml <- osm_get_gpx_metadata(gpx_id = 3790367, format = "xml")
    xml_trk_meta$tracks_xml <- osm_get_gpx_metadata(gpx_id = c(3790367, 3458743), format = "xml")
  })

  lapply(trk_meta, function(x) expect_s3_class(x, class = "data.frame", exact = TRUE))
  lapply(sf_trk_meta, function(x) expect_s3_class(x, class = c("sf", "data.frame"), exact = TRUE))
  lapply(trk_meta, function(x) expect_named(x, column_meta_gpx))
  lapply(sf_trk_meta, function(x) expect_named(x, column_meta_gpx_sf))

  lapply(trk_meta, function(trk) {
    mapply(function(x, cl) expect_true(inherits(x, cl)), x = trk, cl = class_columns[names(trk)])
  })
  lapply(sf_trk_meta, function(trk) {
    mapply(function(x, cl) expect_true(inherits(x, cl)), x = trk, cl = class_columns[names(trk)])
  })

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  lapply(trk_meta, function(x) {
    expect_false(unique(strftime(as.POSIXct(x$timestamp), format = "%M:%S") == "00:00"))
  })
  lapply(sf_trk_meta, function(x) {
    expect_false(unique(strftime(as.POSIXct(x$timestamp), format = "%M:%S") == "00:00"))
  })


  lapply(xml_trk_meta, expect_s3_class, class = "xml_document")


  # Compare xml & R
  mapply(function(d, x) {
    expect_identical(nrow(d), xml2::xml_length(x))
  }, d = trk_meta, x = xml_trk_meta)

  mapply(function(d, x) {
    expect_identical(nrow(d), nrow(x))
  }, d = trk_meta, x = sf_trk_meta)
})


## Download Data: `GET /api/0.6/gpx/#id/data` ----

#' @param format Format of the output. If missing (default), the response will be the exact file that was uploaded.
#'   If `"R"`, a `data.frame`.
#'   If `"gpx"`, the response will always be a GPX format file.
#'   If `"xml"`, a `"xml"` file in an undocumented format.
test_that("osm_get_data_gpx works", {
  trk_data <- list()
  trk_ext <- list()
  with_mock_dir("mock_get_data_gpx", {
    # gpx_id = 3458743: creator="JOSM GPX export" <metadata> bounds c("minlat", "minlon", "maxlat", "maxlon")
    trk_data$raw <- osm_get_data_gpx(gpx_id = 3458743)
    trk_data$gpx <- osm_get_data_gpx(gpx_id = 3458743, format = "gpx") # identical to xml resp but heavier mock file
    trk_data$xml <- osm_get_data_gpx(gpx_id = 3458743, format = "xml")
    trk_data$df <- osm_get_data_gpx(gpx_id = 3458743, format = "R")
    trk_data$sf_line <- osm_get_data_gpx(gpx_id = 3458743, format = "sf_line")
    trk_data$sf_points <- osm_get_data_gpx(gpx_id = 3458743, format = "sf_points")

    # gpx_id = 3498170: creator="Garmin Connect" <extensions><ns3:TrackPointExtension>...
    trk_ext$df <- osm_get_data_gpx(gpx_id = 3498170, format = "R")
    trk_ext$sf_line <- osm_get_data_gpx(gpx_id = 3498170, format = "sf_line")
    trk_ext$sf_points <- osm_get_data_gpx(gpx_id = 3498170, format = "sf_points")
  })

  lapply(trk_data[c("raw", "gpx", "xml")], expect_s3_class, class = "xml_document")

  expect_s3_class(trk_data$df, class = c("osmapi_gps_track", "data.frame"), exact = TRUE)
  expect_s3_class(trk_data$sf_line, class = c("sf", "data.frame"), exact = TRUE)
  expect_s3_class(trk_data$sf_points, class = c("sf", "data.frame"), exact = TRUE)
  expect_s3_class(trk_ext$df, class = c("osmapi_gps_track", "data.frame"), exact = TRUE)
  expect_s3_class(trk_ext$sf_line, class = c("sf", "data.frame"), exact = TRUE)
  expect_s3_class(trk_ext$sf_points, class = c("sf", "data.frame"), exact = TRUE)

  expect_named(trk_data$df, column_gpx)
  expect_named(trk_data$sf_line, "geometry")
  expect_named(trk_data$sf_points, c("ele", "time", "geometry"))
  expect_named(trk_ext$df, c(column_gpx, "atemp", "hr", "cad"))
  expect_named(trk_ext$sf_line, "geometry") # extended data lost
  expect_named(trk_ext$sf_points, c("ele", "time", "atemp", "hr", "cad", "geometry"))

  mapply(function(x, cl) expect_true(inherits(x, cl)), x = trk_data$df, cl = class_columns[names(trk_data$df)])
  mapply(function(x, cl) expect_true(inherits(x, cl)),
    x = trk_data$sf_line, cl = class_columns[names(trk_data$sf_line)]
  )
  mapply(function(x, cl) expect_true(inherits(x, cl)),
    x = trk_data$sf_points, cl = class_columns[names(trk_data$sf_points)]
  )
  mapply(function(x, cl) expect_true(inherits(x, cl)), x = trk_ext$df, cl = class_columns[names(trk_ext$df)])
  mapply(function(x, cl) expect_true(inherits(x, cl)), x = trk_ext$sf_line, cl = class_columns[names(trk_ext$sf_line)])
  mapply(function(x, cl) expect_true(inherits(x, cl)),
    x = trk_ext$sf_points, cl = class_columns[names(trk_ext$sf_points)]
  )

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  expect_false(all(strftime(as.POSIXct(trk_data$df$time), format = "%M:%S") == "00:00"))

  # Compare sf_line, sf_points, xml & R
  expect_equal(nrow(trk_data$df), nrow(trk_data$sf_line$geometry[[1]]))
  expect_equal(nrow(trk_data$df), nrow(trk_data$sf_points))
  trk <- xml2::xml_child(trk_data$xml, search = 2)
  trkseg <- xml2::xml_child(trk, search = 3)
  expect_equal(nrow(trk_data$df), xml2::xml_length(trkseg))

  expect_equal(nrow(trk_ext$df), nrow(trk_ext$sf_line$geometry[[1]]))
  expect_equal(nrow(trk_ext$df), nrow(trk_ext$sf_points))


  ## Empty gpx
  empty_sf <- sf::st_as_sf(empty_gpx_df())
  expect_s3_class(empty_sf, class = c("sf", "data.frame"), exact = TRUE)
  expect_named(empty_sf, c("ele", "time", "geometry"))
  expect_identical(nrow(empty_sf), 0L)
})


## List: `GET /api/0.6/user/gpx_files` ----

test_that("osm_list_gpxs works", {
  with_mock_dir("mock_list_gpxs", {
    traces <- osm_list_gpxs()
    sf_traces <- osm_list_gpxs(format = "sf")
    xml_traces <- osm_list_gpxs(format = "xml")
  })

  expect_s3_class(traces, class = "data.frame", exact = TRUE)
  expect_s3_class(sf_traces, class = c("sf", "data.frame"), exact = TRUE)
  expect_s3_class(xml_traces, "xml_document")

  expect_named(traces, column_meta_gpx)
  expect_named(sf_traces, column_meta_gpx_sf)

  # Compare xml & R
  expect_equal(nrow(traces), nrow(sf_traces))
  expect_equal(nrow(traces), xml2::xml_length(xml_traces))
})
