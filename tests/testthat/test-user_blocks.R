column_user_blocks <- c(
  "id", "created_at", "updated_at", "ends_at", "needs_view",
  "user_uid", "user", "creator_uid", "creator", "revoker_uid", "revoker", "reason"
)

class_columns <- list(
  id = "character", created_at = "POSIXct", updated_at = "POSIXct", ends_at = "POSIXct", needs_view = "logical",
  user_uid = "character", user = "character", creator_uid = "character", creator = "character",
  revoker_uid = "character", revoker = "character", reason = "character"
)


## Create: `POST /api/0.6/user_blocks` ----

test_that("osm_create_user_block works", {
  with_mock_dir("mock_create_user_block", {
    usr_blk <- osm_create_user_block(
      user_id = "12141", reason = "Not really evil, just testing osmapiR (R).", period = 0
    )
    usr_blk_xml <- osm_create_user_block(
      user_id = 12141L, reason = "Not really evil, just testing osmapiR (xml).", period = 0, format = "xml"
    )
    usr_blk_json <- osm_create_user_block(
      user_id = 12141, reason = "Not really evil, just testing osmapiR (json).", period = 0, format = "json",
      needs_view = TRUE
    )
  })

  expect_s3_class(usr_blk, "data.frame")
  expect_named(usr_blk, column_user_blocks)
  lapply(usr_blk, function(x) {
    mapply(function(y, cl) expect_true(inherits(y, cl)), y = x, cl = class_columns[names(x)])
  })

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  expect_false(strftime(as.POSIXct(usr_blk$created_at), format = "%M:%S") == "00:00")
  expect_false(strftime(as.POSIXct(usr_blk$updated_at), format = "%M:%S") == "00:00")
  expect_false(strftime(as.POSIXct(usr_blk$ends_at), format = "%M:%S") == "00:00")


  expect_s3_class(usr_blk_xml, "xml_document")

  expect_type(usr_blk_json, "list")
  expect_named(usr_blk_json, c("version", "generator", "copyright", "attribution", "license", "user_block"))


  # Compare xml, json & R
  expect_identical(nrow(usr_blk), xml2::xml_length(usr_blk_xml))
})



## Read: `GET /api/0.6/user_blocks/#id` ----

test_that(".osm_read_user_block works", {
  usr_blk <- list()
  usr_blk_xml <- list()
  usr_blk_json <- list()
  with_mock_dir("mock_read_user_block", {
    usr_blk$blk <- osm_get_user_blocks(user_block_id = 1)
    usr_blk$blks <- osm_get_user_blocks(user_block_id = c(1, 93))

    usr_blk_xml$blk <- osm_get_user_blocks(user_block_id = 1, format = "xml")
    usr_blk_xml$blks <- osm_get_user_blocks(user_block_id = c(1, 93), format = "xml")

    usr_blk_json$blk <- osm_get_user_blocks(user_block_id = "1", format = "json")
    usr_blk_json$blks <- osm_get_user_blocks(user_block_id = c("1", "93"), format = "json")
  })

  lapply(usr_blk, expect_s3_class, "data.frame")
  lapply(usr_blk, expect_named, column_user_blocks)

  lapply(usr_blk, function(x) {
    mapply(function(y, cl) expect_true(inherits(y, cl)), y = x, cl = class_columns[names(x)])
  })

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  lapply(usr_blk, function(x) {
    expect_false(all(strftime(as.POSIXct(x$created_at), format = "%M:%S") == "00:00"))
    expect_false(all(strftime(as.POSIXct(x$updated_at), format = "%M:%S") == "00:00"))
    expect_false(all(strftime(as.POSIXct(x$ends_at), format = "%M:%S") == "00:00"))
  })


  lapply(usr_blk_xml, expect_s3_class, "xml_document")

  lapply(usr_blk_json, expect_type, "list")
  lapply(
    usr_blk_json,
    expect_named,
    expected = c("version", "generator", "copyright", "attribution", "license", "user_blocks")
  )


  # Compare xml, json & R
  mapply(function(d, x) expect_identical(nrow(d), xml2::xml_length(x)), d = usr_blk, x = usr_blk_xml)
  mapply(function(d, j) expect_identical(nrow(d), length(j$user_blocks)), d = usr_blk, j = usr_blk_json)
})


## List active blocks: `GET /api/0.6/user/blocks/active` ----

test_that("osm_list_active_user_blocks works", {
  # osm_create_user_block(
  #   user_id = "12141", reason = "Not really evil, just testing osmapiR (list active).", period = 0, needs_view = TRUE
  # )
  with_mock_dir("mock_list_active_user_blocks", {
    list_blk <- osm_list_active_user_blocks()
    list_blk_xml <- osm_list_active_user_blocks(format = "xml")
    list_blk_json <- osm_list_active_user_blocks(format = "json")
  })

  expect_s3_class(list_blk, "data.frame")
  expect_named(list_blk, setdiff(column_user_blocks, c("revoker_uid", "revoker", "reason")))
  mapply(function(y, cl) expect_true(inherits(y, cl)), y = list_blk, cl = class_columns[names(list_blk)])

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  expect_false(strftime(as.POSIXct(list_blk$created_at), format = "%M:%S") == "00:00")
  expect_false(strftime(as.POSIXct(list_blk$updated_at), format = "%M:%S") == "00:00")
  expect_false(strftime(as.POSIXct(list_blk$ends_at), format = "%M:%S") == "00:00")


  expect_s3_class(list_blk_xml, "xml_document")

  expect_type(list_blk_json, "list")
  expect_named(list_blk_json, c("version", "generator", "copyright", "attribution", "license", "user_blocks"))

  # Compare xml, json & R
  expect_identical(nrow(list_blk), xml2::xml_length(list_blk_xml))
  expect_identical(nrow(list_blk), length(list_blk_json$user_block))


  ## Empty results

  with_mock_dir("mock_list_active_user_blocks_emp", {
    empty_list_blk <- osm_list_active_user_blocks()
    empty_list_blk_xml <- osm_list_active_user_blocks(format = "xml")
    empty_list_blk_json <- osm_list_active_user_blocks(format = "json")
  })

  expect_s3_class(empty_list_blk, "data.frame")
  expect_named(empty_list_blk, setdiff(column_user_blocks, c("revoker_uid", "revoker", "reason")))
  mapply(function(y, cl) expect_true(inherits(y, cl)), y = empty_list_blk, cl = class_columns[names(empty_list_blk)])


  expect_s3_class(empty_list_blk_xml, "xml_document")

  expect_type(empty_list_blk_json, "list")
  expect_named(empty_list_blk_json, c("version", "generator", "copyright", "attribution", "license", "user_blocks"))

  # Compare xml, json & R
  expect_identical(nrow(empty_list_blk), 0L)
  expect_identical(xml2::xml_length(empty_list_blk_xml), 0L)
  expect_identical(length(empty_list_blk_json$user_block), 0L)
})
