## Comment: `POST /api/0.6/changeset/#id/comment` ----

test_that("osm_comment_changeset_discussion works", {
  with_mock_dir("mock_com_chset_dis", {
    com <- osm_comment_changeset_discussion(changeset_id = 265646, comment = "Testing comments from osmapiR.")
  })

  expect_s3_class(com, c("osmapi_changesets", "data.frame"))
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

  expect_s3_class(subs, c("osmapi_changesets", "data.frame"))
})


## Unsubscribe: `POST /api/0.6/changeset/#id/unsubscribe` ----

test_that("osm_uns_changeset_discussion works", {
  with_mock_dir("mock_uns_chset_dis", {
    unsubs <- osm_unsubscribe_changeset_discussion(changeset_id = 265646)
  })

  expect_s3_class(unsubs, c("osmapi_changesets", "data.frame"))
})


## Hide changeset comment: `POST /api/0.6/changeset/comment/#comment_id/hide` ----

test_that("osm_hide_comment_changeset_discussion works", {
  with_mock_dir("mock_hide_comment_chset_dis", {
    # osm_hide_comment_changeset_discussion(comment_id)
  })
})


## Unhide changeset comment: `POST /api/0.6/changeset/comment/#comment_id/unhide` ----

test_that("osm_unhide_comment_changeset_discussion works", {
  with_mock_dir("mock_unhide_comment_chset_dis", {
    # osm_unhide_comment_changeset_discussion(comment_id)
  })
})
