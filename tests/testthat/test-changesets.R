column_changeset <- c(
  "id", "created_at", "closed_at", "open", "user", "uid",
  "min_lat", "min_lon", "max_lat", "max_lon", "comments_count", "changes_count", "discussion", "tags"
)
column_discuss <- c("id", "date", "uid", "user", "comment_text")

column_osmchange <- c(
  "action_type", "type", "id", "visible", "version", "changeset",
  "timestamp", "user", "uid", "lat", "lon", "members", "tags"
)

class_columns <- list(
  id = "character", created_at = "POSIXct", closed_at = "POSIXct", open = "logical", user = "character",
  uid = "character", min_lat = "character", min_lon = "character", max_lat = "character", max_lon = "character",
  comments_count = "integer", changes_count = "integer", discussion = "list", tags = "list"
)

class_columns_osmchange <- list(
  action_type = "character", type = "character", id = "character", visible = "logical", version = "integer",
  changeset = "character", timestamp = "POSIXct", user = "character", uid = "character",
  lat = "character", lon = "character", members = "list", tags = "list"
)

class_columns_discussion <- list(
  id = "character", date = "POSIXct", uid = "character", user = "character", comment_text = "character"
)


test_that("edit changeset (create/update/diff upload) works", {
  d <- data.frame(
    type = c("node", "node", "way", "relation"),
    id = -(1:4),
    lat = c(0, 1, NA, NA),
    lon = c(0, 1, NA, NA),
    name = c(NA, NA, "My way", "Our relation"),
    type.1 = c(NA, NA, NA, "Column clash!")
  )
  d$members <- list(
    NULL, NULL, -(1:2),
    matrix(
      c("node", "-1", NA, "node", "-2", NA, "way", "-3", "outer"),
      nrow = 3, ncol = 3, byrow = TRUE, dimnames = list(NULL, c("type", "ref", "role"))
    )
  )
  obj <- osmapi_objects(d, tag_columns = c(name = "name", type = "type.1"))
  osmchange_crea <- osmchange_create(obj)

  with_mock_dir("mock_edit_changeset", {
    ## Create: `PUT /api/0.6/changeset/create` ----
    expect_message(
      chset_id <- osm_create_changeset(
        comment = "Describe the changeset",
        created_by = "osmapiR", # avoid changes in calls when updating version
        source = "GPS;survey",
        hashtags = "#testing;#osmapiR",
        verbose = TRUE
      ),
      "New changeset with id = "
    )

    chaset <- osm_get_changesets(changeset_id = chset_id)

    ## Update: `PUT /api/0.6/changeset/#id` ----
    upd_chaset <- osm_update_changeset(
      changeset_id = chset_id,
      comment = "Improved description of the changeset",
      created_by = "osmapiR", # avoid changes in calls when updating version
      hashtags = "#testing;#osmapiR"
    )

    ## Diff upload: `POST /api/0.6/changeset/#id/upload` ----
    diff_up <- osm_diff_upload_changeset(changeset_id = chset_id, osmcha = osmchange_crea)

    osmchange_del <- osmchange_delete(data.frame(type = diff_up$type, id = diff_up$new_id))
    osmchange_del_xml <- osmcha_DF2xml(osmchange_del[osmchange_del$type != "node", ])
    osmchange_del_file <- osmcha_DF2xml(osmchange_del[osmchange_del$type == "node", ])
    path_del <- tempfile(fileext = ".osc")
    xml2::write_xml(osmchange_del_file, path_del)
    diff_up_del1 <- osm_diff_upload_changeset(changeset_id = chset_id, osmcha = osmchange_del_xml, format = "xml")
    diff_up_del2 <- osm_diff_upload_changeset(changeset_id = chset_id, osmcha = path_del)

    ## Close: `PUT /api/0.6/changeset/#id/close` ----
    resp_close <- osm_close_changeset(changeset_id = chset_id)
  })
  file.remove(path_del)

  expect_type(chset_id, "character")
  expect_match(chset_id, "^[0-9]+$")
  expect_s3_class(upd_chaset, c("osmapi_changesets", "data.frame"), exact = TRUE)
  expect_identical(chaset[, setdiff(names(chaset), "tags")], upd_chaset[, setdiff(names(upd_chaset), "tags")])

  expect_error(osm_create_changeset(), "A descriptive comment of the changeset is mandatory.")
  expect_error(osm_update_changeset(), "A descriptive comment of the changeset is mandatory.")

  expect_s3_class(diff_up, "data.frame")
  expect_s3_class(diff_up_del1, "xml_document")
  expect_s3_class(diff_up_del2, "data.frame")
  expect_named(diff_up, c("type", "old_id", "new_id", "new_version"))
  expect_named(diff_up_del2, c("type", "old_id"))
  expect_equal(nrow(diff_up), nrow(obj))
  expect_equal(length(xml2::xml_children(diff_up_del1)) + nrow(diff_up_del2), nrow(obj))

  expect_error(
    osm_diff_upload_changeset(changeset_id = chset_id, osmcha = numeric()),
    "`osmcha` must be a path to a OsmChage file, a `xml_document` with a OsmChange content or an `osmapi_OsmChange` "
  )
  expect_error(
    osm_diff_upload_changeset(changeset_id = chset_id, osmcha = "doesnt_exist"),
    "`osmcha` is interpreted as a path to an OsmChange file, but it can't be found "
  )
  expect_null(resp_close)
})


## Read: `GET /api/0.6/changeset/#id*?include_discussion='true'*` ----

test_that("osm_read_changeset works", {
  with_mock_dir("mock_read_changeset", {
    chaset <- osm_get_changesets(changeset_id = 137595351)
    chaset_discuss <- osm_get_changesets(changeset_id = 137595351, include_discussion = TRUE)
    chasets <- osm_get_changesets(changeset_id = c(137595351, 113271550), format = "R")
    chasets_xml <- osm_get_changesets(changeset_id = c(137595351, 113271550), format = "xml")
  })

  expect_s3_class(chaset, c("osmapi_changesets", "data.frame"))
  expect_s3_class(chasets, c("osmapi_changesets", "data.frame"))
  expect_s3_class(chaset_discuss, c("osmapi_changesets", "data.frame"))
  expect_identical(names(chaset), setdiff(column_changeset, "discussion"))
  expect_identical(names(chasets), setdiff(column_changeset, "discussion"))
  expect_identical(names(chaset_discuss), c(column_changeset))
  lapply(chaset_discuss$discussion, function(x) {
    expect_s3_class(x, c("changeset_comments", "data.frame"))
    expect_named(x, column_discuss)

    mapply(function(y, cl) expect_true(inherits(y, cl)), y = x, cl = class_columns_discussion[names(x)])

    # Check that time is extracted, otherwise it's 00:00:00 in local time
    expect_false(unique(strftime(as.POSIXct(x$date), format = "%M:%S") == "00:00"))
  })

  mapply(function(x, cl) expect_true(inherits(x, cl)), x = chaset, cl = class_columns[names(chaset)])
  mapply(function(x, cl) expect_true(inherits(x, cl)), x = chasets, cl = class_columns[names(chasets)])
  mapply(function(x, cl) expect_true(inherits(x, cl)), x = chaset_discuss, cl = class_columns[names(chaset_discuss)])

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  lapply(chaset[, c("created_at", "closed_at")], function(x) {
    expect_false(strftime(as.POSIXct(x), format = "%M:%S") == "00:00")
  })
  lapply(chasets[, c("created_at", "closed_at")], function(x) {
    expect_false(all(strftime(as.POSIXct(x), format = "%M:%S") == "00:00"))
  })

  lapply(chaset_discuss[, c("created_at", "closed_at")], function(x) {
    expect_false(strftime(as.POSIXct(x), format = "%M:%S") == "00:00")
  })

  # methods
  expect_snapshot(print(chaset))
  expect_snapshot(print(chaset_discuss))


  ## xml
  expect_s3_class(chasets_xml, "xml_document")
  expect_length(chasets_xml, 2)


  ## json
  with_mock_dir("mock_read_changeset_json", {
    chaset_json <- osm_get_changesets(changeset_id = c(137595351, 113271550), format = "json")
  })
  expect_type(chaset_json, "list")
  expect_named(chaset_json, c("version", "generator", "copyright", "attribution", "license", "elements"))
  expect_length(chaset_json$elements, 2)
  lapply(chaset_json$elements, function(x) {
    expect_contains(
      names(x),
      c(
        "type", "id", "created_at", "closed_at", "open", "user", "uid",
        "minlat", "minlon", "maxlat", "maxlon", "comments_count", "changes_count", "tags"
      )
    )
  })
})


## Download: `GET /api/0.6/changeset/#id/download` ----

test_that("osm_download_changeset works", {
  with_mock_dir("mock_download_changeset", {
    osmchange <- osm_download_changeset(changeset_id = 137003062)
    osmchange_xml <- osm_download_changeset(changeset_id = 137003062, format = "xml")
  })

  expect_s3_class(osmchange, c("osmapi_OsmChange", "data.frame"))
  expect_identical(names(osmchange), column_osmchange)

  mapply(function(x, cl) expect_true(inherits(x, cl)), x = osmchange, cl = class_columns_osmchange[names(osmchange)])

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  expect_false(unique(strftime(as.POSIXct(osmchange$timestamp), format = "%M:%S") == "00:00"))


  ### test transformation df <-> xml ----

  expect_identical(xml2::xml_children(osmcha_DF2xml(osmchange)), xml2::xml_children(osmchange_xml))
  expect_identical(osmchange_xml2DF(osmchange_xml), osmchange)

  # methods
  expect_snapshot(print(osmchange))
})


## Query: `GET /api/0.6/changesets` ----

test_that("osm_query_changesets works", {
  api_capabilities_ori <- getOption("osmapir.api_capabilities")
  api_capabilities <- api_capabilities_ori
  api_capabilities$api$changesets[c("default_query_limit", "maximum_query_limit")] <- c(10, 20)
  options(osmapir.api_capabilities = api_capabilities)

  chaset <- list()
  with_mock_dir("mock_query_changesets", {
    chaset$ids <- osm_query_changesets(changeset_ids = c(137627129, 137625624), order = "oldest")
    chaset$empty <- osm_query_changesets(changeset_ids = c(151819967, 137595351)) # empty & no empty
    chaset$time <- osm_query_changesets(
      bbox = c(-1.241112, 38.0294955, 8.4203171, 42.9186456),
      user = "Mementomoristultus",
      time = "2023-06-22T02:23:23Z",
      time_2 = "2023-06-22T00:38:20Z"
    )
    chaset$closed <- osm_query_changesets(
      bbox = "-9.3015367,41.8073642,-6.7339533,43.790422",
      user = "Mementomoristultus",
      closed = TRUE
    )

    # limit > maximum_query_limit: requests in batches
    chaset$batches <- osm_query_changesets(
      bbox = "-9.3015367,41.8073642,-6.7339533,43.790422",
      user = "Mementomoristultus",
      closed = TRUE,
      limit = 50
    )

    chaset_xml <- osm_query_changesets(
      bbox = "-9.3015367,41.8073642,-6.7339533,43.790422",
      user = "Mementomoristultus",
      closed = TRUE,
      limit = 50,
      format = "xml"
    )
    chaset_json <- osm_query_changesets(
      bbox = "-9.3015367,41.8073642,-6.7339533,43.790422",
      user = "Mementomoristultus",
      closed = TRUE,
      limit = 50,
      format = "json"
    )
  })

  lapply(chaset, expect_s3_class, c("osmapi_changesets", "data.frame"))
  lapply(chaset, function(x) expect_identical(names(x), setdiff(column_changeset, "discussion")))
  lapply(chaset, function(x) {
    lapply(x$discussion, function(y) {
      expect_s3_class(y, c("changeset_comments", "data.frame"))
      expect_named(y, column_discuss)
    })
  })

  # Check batch union for xml and json
  expect_identical(nrow(chaset$batches), length(xml2::xml_children(chaset_xml)))
  expect_identical(nrow(chaset$batches), length(chaset_json$changeset))

  # methods
  lapply(chaset, function(x) expect_snapshot(print(x)))


  ## Empty results

  with_mock_dir("mock_query_changesets_empty", {
    empty_chaset <- osm_query_changesets(bbox = c(-180, 0, -179.9, 0.1), user = "jmaspons")
  })

  expect_s3_class(empty_chaset, c("osmapi_changesets", "data.frame"))
  expect_identical(names(empty_chaset), setdiff(column_changeset, "discussion"))
  expect_identical(nrow(empty_chaset), 0L)

  mapply(
    function(x, cl) expect_true(inherits(x, cl)),
    x = empty_chaset,
    cl = class_columns[names(empty_chaset)]
  )

  # methods
  expect_snapshot(print(empty_chaset))


  ## Input errors

  expect_error(
    osm_query_changesets(time = "don't care", order = "oldest"),
    "Cannot use `order = \"oldest\"` with `time` parameter."
  )
  expect_error(
    osm_query_changesets(order = "oldest", limit = 101),
    "Cannot use `order = \"oldest\"` with `limit` > "
  )


  options(osmapir.api_capabilities = api_capabilities_ori)
})
