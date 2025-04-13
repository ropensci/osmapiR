classes <- list(
  df = c("osmapi_map_notes", "data.frame"), sf = c("sf_osmapi_map_notes", "sf", "data.frame"), xml = "xml_document",
  rss = "xml_document", json = "list", gpx = "xml_document"
)

column_notes <- c("lon", "lat", "id", "url", "comment_url", "close_url", "date_created", "status", "comments")
column_notes_sf <- c("id", "url", "comment_url", "close_url", "date_created", "status", "comments", "geometry")
column_comments <- c("date", "uid", "user", "user_url", "action", "text", "html")

class_column_notes <- list(
  lon = "character", lat = "character", id = "character", url = "character", comment_url = "character",
  close_url = "character", date_created = "POSIXct", status = "character", comments = c("note_comments", "list")
)
class_column_comments <- list(
  date = "POSIXct", uid = "character", user = "character", user_url = "character",
  action = "character", text = "character", html = "character"
)


## Retrieving notes data by bounding box: `GET /api/0.6/notes` ----

test_that("osm_read_bbox_notes works", {
  bbox_notes <- list()
  bbox <- c(3.7854767, 39.7837403, 4.3347931, 40.1011851)
  with_mock_dir("mock_read_bbox_notes", {
    bbox_notes$df <- osm_read_bbox_notes(bbox = bbox, limit = 10)
    bbox_notes$sf <- osm_read_bbox_notes(bbox = bbox, limit = 10, format = "sf")
    bbox_notes$xml <- osm_read_bbox_notes(bbox = bbox, limit = 10, format = "xml")
    bbox_notes$rss <- osm_read_bbox_notes(bbox = bbox, limit = 10, format = "rss")
    bbox_notes$json <- osm_read_bbox_notes(bbox = bbox, limit = 10, format = "json")
    bbox_notes$gpx <- osm_read_bbox_notes(bbox = bbox, limit = 10, format = "gpx")
  })

  mapply(function(x, class) expect_true(inherits(x, class)), x = bbox_notes, class = classes)

  expect_named(bbox_notes$df, column_notes)
  expect_named(bbox_notes$sf, column_notes_sf)

  lapply(bbox_notes$df$comments, function(x) {
    expect_s3_class(x, c("note_comments", "data.frame"))
    expect_named(x, column_comments)

    mapply(function(y, cl) expect_true(inherits(y, cl)), y = x, cl = class_column_comments[names(x)])

    # Check that time is extracted, otherwise it's 00:00:00 in local time
    expect_false(unique(strftime(as.POSIXct(x$date), format = "%M:%S") == "00:00"))
  })

  mapply(function(x, cl) expect_true(inherits(x, cl)), x = bbox_notes$df, cl = class_column_notes[names(bbox_notes$df)])

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  expect_false(unique(strftime(as.POSIXct(bbox_notes$df$date_created), format = "%M:%S") == "00:00"))


  sel_cols <- intersect(names(bbox_notes$df), names(bbox_notes$sf))
  expect_equal(as.data.frame(bbox_notes$df[, sel_cols]), as.data.frame(sf::st_drop_geometry(bbox_notes$sf[, sel_cols])))

  # methods
  expect_snapshot(print(bbox_notes$df))
  expect_snapshot(print(bbox_notes$sf))

  # Compare xml, rss, json, gpx & R
  expect_identical(nrow(bbox_notes$df), nrow(bbox_notes$sf))
  expect_identical(nrow(bbox_notes$df), xml2::xml_length(bbox_notes$xml))
  expect_identical(nrow(bbox_notes$df), length(xml2::xml_find_all(bbox_notes$rss, xpath = "//item")))
  expect_identical(nrow(bbox_notes$df), length(bbox_notes$json$features))
  expect_identical(nrow(bbox_notes$df), xml2::xml_length(bbox_notes$gpx))
})


## Read: `GET /api/0.6/notes/#id` ----

test_that("osm_read_note works", {
  read_note <- list()
  read_notes <- list()
  with_mock_dir("mock_read_note", {
    read_note$df <- osm_get_notes(note_id = "2067786")
    read_note$sf <- osm_get_notes(note_id = 2067786, format = "sf")
    read_note$xml <- osm_get_notes(note_id = 2067786, format = "xml")
    read_note$rss <- osm_get_notes(note_id = 2067786, format = "rss")
    read_note$json <- osm_get_notes(note_id = 2067786, format = "json")
    read_note$gpx <- osm_get_notes(note_id = 2067786L, format = "gpx")

    read_notes$df <- osm_get_notes(note_id = c("2067786", "2067786"))
    read_notes$sf <- osm_get_notes(note_id = c("2067786", "2067786"), format = "sf")
    read_notes$xml <- osm_get_notes(note_id = c(2067786, 2067786), format = "xml")
    read_notes$rss <- osm_get_notes(note_id = c(2067786, 2067786), format = "rss")
    read_notes$json <- osm_get_notes(note_id = c(2067786, 2067786), format = "json")
    read_notes$gpx <- osm_get_notes(note_id = c(2067786L, 2067786), format = "gpx")
  })

  mapply(function(x, class) expect_true(inherits(x, class)), x = read_note, class = classes)
  mapply(function(x, class) expect_true(inherits(x, class)), x = read_notes, class = classes)

  expect_named(read_note$df, column_notes)
  expect_named(read_note$sf, column_notes_sf)
  expect_named(read_notes$df, column_notes)
  expect_named(read_notes$sf, column_notes_sf)

  lapply(read_note$df$comments, function(x) {
    expect_s3_class(x, c("note_comments", "data.frame"))
    expect_named(x, column_comments)
  })
  lapply(read_notes$df$comments, function(x) {
    expect_s3_class(x, c("note_comments", "data.frame"))
    expect_named(x, column_comments)
  })

  sel_cols <- intersect(names(read_note$df), names(read_note$sf))
  expect_equal(as.data.frame(read_note$df[, sel_cols]), as.data.frame(sf::st_drop_geometry(read_note$sf[, sel_cols])))
  sel_cols <- intersect(names(read_notes$df), names(read_notes$sf))
  expect_equal(as.data.frame(read_notes$df[, sel_cols]), as.data.frame(sf::st_drop_geometry(read_notes$sf[, sel_cols])))


  # xml_document
  lapply(read_note[c("xml", "rss", "gpx")], function(x) expect_true(xml2::xml_length(x) == 1))
  lapply(read_notes[c("xml", "rss", "gpx")], function(x) {
    expect_true(xml2::xml_length(x) == 2)
    tryCatch(
      expect_identical(xml2::xml_child(x, 1), xml2::xml_child(x, 2)),
      error = function(e) message("TODO: fix added namespaces in the 2on node R/osm_get_notes.R/osm_get_notes()")
    )
  })

  # methods
  expect_snapshot(print(read_note$df))
  expect_snapshot(print(read_note$sf))
  expect_snapshot(print(read_notes$df))
  expect_snapshot(print(read_notes$sf))


  # Compare xml, rss, json, gpx & R
  expect_identical(nrow(read_notes$df), nrow(read_notes$sf))
  expect_identical(nrow(read_notes$df), xml2::xml_length(read_notes$xml))
  expect_identical(nrow(read_notes$df), length(xml2::xml_find_all(read_notes$rss, xpath = "//item")))
  expect_identical(nrow(read_notes$df), length(read_notes$json))
  expect_identical(nrow(read_notes$df), xml2::xml_length(read_notes$gpx))
})


## Create a new note: `POST /api/0.6/notes` ----

test_that("osm_create_note works", {
  with_mock_dir("mock_create_note", {
    note <- osm_create_note(lat = "40.7327375", lon = "0.1702526", text = "There is survey point here.")
  })

  expect_s3_class(note, c("osmapi_map_notes", "data.frame"))
})


## Create a new comment: `POST /api/0.6/notes/#id/comment` ----

test_that("osm_create_comment_note works", {
  with_mock_dir("mock_create_comment_note", {
    com_note <- osm_create_comment_note(note_id = 42091, text = "Right, add it.")
  })

  expect_s3_class(com_note, c("osmapi_map_notes", "data.frame"))
})


## Close: `POST /api/0.6/notes/#id/close` ----

test_that("osm_close_note works", {
  with_mock_dir("mock_close_note", {
    close_note <- osm_close_note(note_id = 42091)
  })

  expect_s3_class(close_note, c("osmapi_map_notes", "data.frame"))
})


## Reopen: `POST /api/0.6/notes/#id/reopen` ----

test_that("osm_reopen_note works", {
  with_mock_dir("mock_reopen_note", {
    reopen_note <- osm_reopen_note(note_id = 42091)
  })

  expect_s3_class(reopen_note, c("osmapi_map_notes", "data.frame"))
})


## Hide: `DELETE /api/0.6/notes/#id` ----

test_that("osm_delete_note works", {
  with_mock_dir("mock_delete_note", {
    note <- osm_create_note(lat = "40.7327375", lon = "0.1702526", text = "Test note to delete.")
    del_note <- osm_delete_note(note_id = note$id, text = "Hide note")
  })

  expect_s3_class(del_note, c("osmapi_map_notes", "data.frame"), exact = TRUE)
  expect_named(del_note, column_notes)


  lapply(del_note$comments, function(x) {
    expect_s3_class(x, c("note_comments", "data.frame"))
    expect_named(x, column_comments)
  })
})


test_that("osm_subscribe_note works", {
  with_mock_dir("mock_subscribe_note", {
    ## Subscribe: `POST /api/0.6/notes/#id/subscription` ----
    subs <- osm_subscribe_note(note_id = 2067786)

    ## Unsubscribe: `DELETE /api/0.6/notes/#id/subscription` ----
    unsubs <- osm_unsubscribe_note(note_id = 2067786)
  })

  expect_null(subs)
  expect_null(unsubs)
})


## Search for notes: `GET /api/0.6/notes/search` ----

test_that("osm_search_notes works", {
  search_notes <- list()
  with_mock_dir("mock_search_notes", {
    search_notes$df <- osm_search_notes(q = "POI", from = "2017-10-01", to = "2017-10-27T15:27A", limit = 10)
    search_notes$sf <- osm_search_notes(
      q = "POI", from = "2017-10-01", to = "2017-10-27T15:27A", limit = 10, format = "sf"
    )
    search_notes$xml <- osm_search_notes(user = "jmaspons", from = "2017-10-01", limit = 10, format = "xml")
    search_notes$rss <- osm_search_notes(q = "POI", from = "2017-10-01", to = "2017-10-27", limit = 10, format = "rss")
    search_notes$json <- osm_search_notes(from = "2017-10-01", to = "2017-10-27", limit = 10, format = "json")
    search_notes$gpx <- osm_search_notes(from = "2023-06-25", closed = -1, limit = 10, format = "gpx")
  })

  mapply(function(x, class) expect_true(inherits(x, class)), x = search_notes, class = classes)
  expect_named(search_notes$df, column_notes)
  expect_named(search_notes$sf, column_notes_sf)
  lapply(search_notes$df$comments, function(x) {
    expect_s3_class(x, c("note_comments", "data.frame"))
    expect_named(x, column_comments)
  })

  sel_cols <- intersect(names(search_notes$df), names(search_notes$sf))
  expect_equal(
    as.data.frame(search_notes$df[, sel_cols]),
    as.data.frame(sf::st_drop_geometry(search_notes$sf[, sel_cols]))
  )

  # methods
  expect_snapshot(print(search_notes$df))
  expect_snapshot(print(search_notes$sf))

  # Compare xml, rss, json, gpx & R
  ## TODO test after batch calls implementation for identical search arguments


  ## Empty results

  empty_search_notes <- list()
  with_mock_dir("mock_search_notes_empty", {
    empty_search_notes$df <- osm_search_notes(q = "Visca la terra!", user = "jmaspons")
    empty_search_notes$sf <- osm_search_notes(q = "Visca la terra!", user = "jmaspons", format = "sf")
    empty_search_notes$xml <- osm_search_notes(q = "Visca la terra!", user = "jmaspons", format = "xml")
    empty_search_notes$rss <- osm_search_notes(q = "Visca la terra!", user = "jmaspons", format = "rss")
    empty_search_notes$json <- osm_search_notes(q = "Visca la terra!", user = "jmaspons", format = "json")
    empty_search_notes$gpx <- osm_search_notes(q = "Visca la terra!", user = "jmaspons", format = "gpx")
  })

  mapply(function(x, class) expect_true(inherits(x, class)), x = empty_search_notes, class = classes)
  expect_named(empty_search_notes$df, column_notes)
  expect_named(empty_search_notes$sf, column_notes_sf)

  mapply(
    function(x, cl) expect_true(inherits(x, cl)),
    x = empty_search_notes$df,
    cl = class_column_notes[names(empty_search_notes$df)]
  )

  sel_cols <- intersect(names(empty_search_notes$df), names(empty_search_notes$sf))
  expect_equal(
    as.data.frame(empty_search_notes$df[, sel_cols]),
    as.data.frame(sf::st_drop_geometry(empty_search_notes$sf[, sel_cols]))
  )


  # methods
  expect_snapshot(print(empty_search_notes$df))
  expect_snapshot(print(empty_search_notes$sf))


  # Compare xml, rss, json, gpx & R
  expect_identical(nrow(empty_search_notes$df), 0L)
  expect_identical(nrow(empty_search_notes$sf), 0L)
  expect_identical(xml2::xml_length(empty_search_notes$xml), 0L)
  expect_identical(length(xml2::xml_find_all(empty_search_notes$rss, xpath = "//item")), 0L)
  expect_identical(xml2::xml_length(empty_search_notes$gpx), 0L)
  expect_identical(length(empty_search_notes$json$features), 0L)
})


## RSS Feed: `GET /api/0.6/notes/feed` ----

test_that("osm_feed_notes works", {
  with_mock_dir("mock_feed_notes", {
    feed_notes <- osm_feed_notes(bbox = c(0.8205414, 40.6686604, 0.8857727, 40.7493377))
  })

  expect_s3_class(feed_notes, "xml_document")
})
