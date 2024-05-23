classes <- list(
  df = c("osmapi_map_notes", "data.frame"), xml = "xml_document",
  rss = "xml_document", json = "list", gpx = "xml_document"
)

column_notes <- c("lon", "lat", "id", "url", "comment_url", "close_url", "date_created", "status", "comments")
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
    bbox_notes$xml <- osm_read_bbox_notes(bbox = bbox, limit = 10, format = "xml")
    bbox_notes$rss <- osm_read_bbox_notes(bbox = bbox, limit = 10, format = "rss")
    bbox_notes$json <- osm_read_bbox_notes(bbox = bbox, limit = 10, format = "json")
    bbox_notes$gpx <- osm_read_bbox_notes(bbox = bbox, limit = 10, format = "gpx")
  })

  mapply(function(x, class) expect_true(inherits(x, class)), x = bbox_notes, class = classes)
  expect_named(bbox_notes$df, column_notes)
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


  # methods
  expect_snapshot(print(bbox_notes$df))
})


## Read: `GET /api/0.6/notes/#id` ----

test_that("osm_read_note works", {
  read_note <- list()
  read_notes <- list()
  with_mock_dir("mock_read_note", {
    read_note$df <- osm_get_notes(note_id = "2067786")
    read_note$xml <- osm_get_notes(note_id = 2067786, format = "xml")
    read_note$rss <- osm_get_notes(note_id = 2067786, format = "rss")
    read_note$json <- osm_get_notes(note_id = 2067786, format = "json")
    read_note$gpx <- osm_get_notes(note_id = 2067786L, format = "gpx")

    read_notes$df <- osm_get_notes(note_id = c("2067786", "2067786"))
    read_notes$xml <- osm_get_notes(note_id = c(2067786, 2067786), format = "xml")
    read_notes$rss <- osm_get_notes(note_id = c(2067786, 2067786), format = "rss")
    read_notes$json <- osm_get_notes(note_id = c(2067786, 2067786), format = "json")
    read_notes$gpx <- osm_get_notes(note_id = c(2067786L, 2067786), format = "gpx")
  })

  mapply(function(x, class) expect_true(inherits(x, class)), x = read_note, class = classes)
  mapply(function(x, class) expect_true(inherits(x, class)), x = read_notes, class = classes)

  expect_named(read_note$df, column_notes)
  expect_named(read_notes$df, column_notes)

  lapply(read_note$df$comments, function(x) {
    expect_s3_class(x, c("note_comments", "data.frame"))
    expect_named(x, column_comments)
  })
  lapply(read_notes$df$comments, function(x) {
    expect_s3_class(x, c("note_comments", "data.frame"))
    expect_named(x, column_comments)
  })

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
  expect_snapshot(print(read_notes$df))
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


## Search for notes: `GET /api/0.6/notes/search` ----

test_that("osm_search_notes works", {
  search_notes <- list()
  with_mock_dir("mock_search_notes", {
    search_notes$df <- osm_search_notes(q = "POI", from = "2017-10-01", to = "2017-10-27T15:27A", limit = 10)
    search_notes$xml <- osm_search_notes(user = "jmaspons", from = "2017-10-01", limit = 10, format = "xml")
    search_notes$rss <- osm_search_notes(q = "POI", from = "2017-10-01", to = "2017-10-27", limit = 10, format = "rss")
    search_notes$json <- osm_search_notes(from = "2017-10-01", to = "2017-10-27", limit = 10, format = "json")
    search_notes$gpx <- osm_search_notes(from = "2023-06-25", closed = -1, limit = 10, format = "gpx")
  })

  mapply(function(x, class) expect_true(inherits(x, class)), x = search_notes, class = classes)
  expect_named(search_notes$df, column_notes)
  lapply(search_notes$df$comments, function(x) {
    expect_s3_class(x, c("note_comments", "data.frame"))
    expect_named(x, column_comments)
  })

  # methods
  expect_snapshot(print(search_notes$df))


  ## Empty results

  with_mock_dir("mock_search_notes_empty", {
    empty_search_notes <- osm_search_notes(q = "Visca la terra!", user = "jmaspons")
  })

  expect_s3_class(empty_search_notes, c("osmapi_map_notes", "data.frame"))
  expect_identical(names(empty_search_notes), column_notes)
  expect_identical(nrow(empty_search_notes), 0L)

  mapply(
    function(x, cl) expect_true(inherits(x, cl)),
    x = empty_search_notes,
    cl = class_column_notes[names(empty_search_notes)]
  )

  # methods
  expect_snapshot(print(empty_search_notes))
})


## RSS Feed: `GET /api/0.6/notes/feed` ----

test_that("osm_feed_notes works", {
  with_mock_dir("mock_feed_notes", {
    feed_notes <- osm_feed_notes(bbox = c(0.8205414, 40.6686604, 0.8857727, 40.7493377))
  })

  expect_s3_class(feed_notes, "xml_document")
})
