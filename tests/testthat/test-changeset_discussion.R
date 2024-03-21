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



test_that("osm_hide_comment_changeset_discussion works", {
  with_mock_dir("mock_hide_com_chset_dis", {
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
