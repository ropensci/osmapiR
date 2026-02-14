column_discuss <- c("id", "date", "visible", "uid", "user", "comment_text")
class_columns_discussion <- list(
  id = "character", date = "POSIXct", visible = "logical",
  user = "character", uid = "character", comment_text = "character"
)


## Comment: `POST /api/0.6/changeset/#id/comment` ----

test_that("osm_comment_changeset_discussion works", {
  with_mock_dir("mock_com_chset_dis", {
    com <- osm_comment_changeset_discussion(changeset_id = 265646, comment = "Testing comments from osmapiR.")
  })

  expect_s3_class(com, c("osmapi_changesets", "data.frame"), exact = TRUE)
})


## Subscribe: `POST /api/0.6/changeset/#id/subscribe` ----

test_that("osm_sub_changeset_discussion works", {
  # with_mock_dir("mock_sub_chset_dis_err", {
  #   # http status: 409 Conflict -> Already subscribed
  #   subs_err <- try(osm_subscribe_changeset_discussion(changeset_id = 265646))
  # })
  with_mock_dir("mock_sub_chset_dis", {
    subs <- osm_subscribe_changeset_discussion(changeset_id = 265636)
  })

  expect_s3_class(subs, c("osmapi_changesets", "data.frame"), exact = TRUE)
})


## Unsubscribe: `POST /api/0.6/changeset/#id/unsubscribe` ----

test_that("osm_uns_changeset_discussion works", {
  with_mock_dir("mock_uns_chset_dis", {
    unsubs <- osm_unsubscribe_changeset_discussion(changeset_id = 265646)
  })

  expect_s3_class(unsubs, c("osmapi_changesets", "data.frame"), exact = TRUE)
})


## Search changeset comments: `GET /api/0.6/changeset_comments` ----

test_that("osm_search_comment_changeset_discussion works", {
  with_mock_dir("mock_search_comment", {
    disc <- osm_search_comment_changeset_discussion(user = "Steve")
    disc_xml<- osm_search_comment_changeset_discussion(user = "Steve", format = "xml")
    disc_json <- osm_search_comment_changeset_discussion(
      user = 355617, from = as.POSIXct("2017-10-1"), to = as.POSIXlt("2017-10-2"), format = "json"
    )
    disc_empty <- osm_search_comment_changeset_discussion(from = "2014-09-11", to = "2014-09-11")
  })

  expect_s3_class(disc, class = c("changeset_comments", "data.frame"), exact = TRUE)
  expect_named(disc, setdiff(column_discuss, "discussion"))
  mapply(function(y, cl) expect_true(inherits(y, cl)), y = disc, cl = class_columns_discussion)

  # Empty
  expect_s3_class(disc_empty, class = c("changeset_comments", "data.frame"), exact = TRUE)
  expect_named(disc_empty, setdiff(column_discuss, "discussion"))
  mapply(function(y, cl) expect_true(inherits(y, cl)), y = disc_empty, cl = class_columns_discussion)
  expect_identical(nrow(disc_empty), 0L)

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  expect_false(unique(strftime(as.POSIXct(disc$date), format = "%M:%S") == "00:00"))

  ## xml
  expect_s3_class(disc_xml, "xml_document")
  expect_length(disc_xml, 2)

  ## json
  expect_type(disc_json, "list")
  expect_named(disc_json, c("version", "generator", "copyright", "attribution", "license", "comments"))
  expect_length(disc_json$comments, 4)
  lapply(disc_json$comments, function(x) {
    expect_contains(names(x), c("id", "date", "visible", "user", "uid", "text"))
  })

  # Compare xml & R
  expect_identical(nrow(disc), xml2::xml_length(disc_xml))
})


test_that("osm_hide_comment_changeset_discussion works", {
  with_mock_dir("mock_hide_com_ch", {
    chdis <- osm_get_changesets("265646", include_discussion = TRUE)

    ## Hide changeset comment: `POST /api/0.6/changeset/comment/#comment_id/hide` ----
    hide_com <- osm_hide_comment_changeset_discussion(comment_id = chdis$discussion[[1]]$id[1])

    ## Unhide changeset comment: `POST /api/0.6/changeset/comment/#comment_id/unhide` ----
    unhide_com <- osm_unhide_comment_changeset_discussion(comment_id = chdis$discussion[[1]]$id[1])
  })

  expect_s3_class(hide_com, c("osmapi_changesets", "data.frame"), exact = TRUE)
  expect_s3_class(unhide_com, c("osmapi_changesets", "data.frame"), exact = TRUE)
  expect_equal(hide_com$comments_count, 1)
  expect_equal(unhide_com$comments_count, 2)
})
