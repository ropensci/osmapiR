classes <- list(df = c("osmapi_map_notes", "data.frame"), xml = "xml_document", rss = "xml_document", json = "list", gpx = "xml_document")
column_notes <- c("lon", "lat", "id", "url", "comment_url", "close_url", "date_created", "status", "comments")
column_comments <- c("date", "uid", "user", "user_url", "action", "text", "html")


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
  })

  # methods
  expect_s3_class(print(bbox_notes$df), classes$df)
})


## Read: `GET /api/0.6/notes/#id` ----

test_that("osm_read_note works", {
  read_note <- list()
  with_mock_dir("mock_read_note", {
    read_note$df <- osm_read_note(note_id = "2067786")
    read_note$xml <- osm_read_note(note_id = 2067786, format = "xml")
    read_note$rss <- osm_read_note(note_id = 2067786, format = "rss")
    read_note$json <- osm_read_note(note_id = 2067786, format = "json")
    read_note$gpx <- osm_read_note(note_id = 2067786L, format = "gpx")
  })

  mapply(function(x, class) expect_true(inherits(x, class)), x = read_note, class = classes)
  expect_named(read_note$df, column_notes)
  lapply(read_note$df$comments, function(x) {
    expect_s3_class(x, c("note_comments", "data.frame"))
    expect_named(x, column_comments)
  })

  # methods
  expect_s3_class(print(read_note$df), classes$df)
})


## Create a new note: `POST /api/0.6/notes` ----

test_that("osm_create_note works", {
  with_mock_dir("mock_create_note", {
    # osm_create_note()
  })
})


## Create a new comment: `POST /api/0.6/notes/#id/comment` ----

test_that("osm_create_comment_note works", {
  with_mock_dir("mock_create_comment_note", {
    # osm_create_comment_note(note_id)
  })
})


## Close: `POST /api/0.6/notes/#id/close` ----

test_that("osm_close_note works", {
  with_mock_dir("mock_close_note", {
    # osm_close_note(note_id)
  })
})


## Reopen: `POST /api/0.6/notes/#id/reopen` ----

test_that("osm_reopen_note works", {
  with_mock_dir("mock_reopen_note", {
    # osm_reopen_note(note_id)
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
  expect_s3_class(print(search_notes$df), classes$df)
})


## RSS Feed: `GET /api/0.6/notes/feed` ----

test_that("osm_feed_notes works", {
  with_mock_dir("mock_feed_notes", {
    feed_notes <- osm_feed_notes(bbox = c(0.8205414, 40.6686604, 0.8857727, 40.7493377))
  })

  expect_s3_class(feed_notes, "xml_document")
})
