column_changeset <- c(
  "id", "created_at", "closed_at", "open", "user", "uid",
  "min_lat", "min_lon", "max_lat", "max_lon", "comments_count", "changes_count", "discussion", "tags"
)
column_discuss <- c("date", "uid", "user", "comment_text")

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
  date = "POSIXct", uid = "character", user = "character", comment_text = "character"
)


test_that("edit changeset (create/update/diff upload) works", {
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
  })

  expect_type(chset_id, "character")
  expect_s3_class(upd_chaset, c("osmapi_changesets", "data.frame"))
  expect_identical(chaset[, setdiff(names(chaset), "tags")], upd_chaset[, setdiff(names(upd_chaset), "tags")])

  expect_error(osm_create_changeset(), "A descriptive comment of the changeset is mandatory.")
  expect_error(osm_update_changeset(), "A descriptive comment of the changeset is mandatory.")

  ## Diff upload: `POST /api/0.6/changeset/#id/upload` ----

  xml <- xml2::read_xml(test_path("sample_files/osm_objects.xml"))
  objs <- object_xml2DF(xml)
  osm_change <- cbind(action_type = c("delete", "modify", "delete", "modify", "modify"), objs)
  class(osm_change) <- c("osmapi_OsmChange", class(osm_change))

  osm_change$tags[osm_change$action_type == "modify"] <- lapply(
    osm_change$tags[osm_change$action_type == "modify"],
    function(x) rbind(x, c("name:ca", "Test modify with OsmChange"))
  )

  osm_change_xml <- osmcha_DF2xml(osm_change)

  with_mock_dir("mock_diff_up_changeset", {
    # TODO: better testing for osm_idff_upload_changeset
    # fetch <- list()
    # fetch$node <- osm_fetch_objects(osm_type = "nodes", osm_ids = c(35308286, 1935675367))
    # fetch$way <- osm_fetch_objects(osm_type = "ways", osm_ids = c(13073736L, 235744929L))
    # fetch$rel <- osm_fetch_objects(osm_type = "relations", osm_ids = c("40581", "341530"))
    # HTTP 404 Not Found. (testing server)
    # bbox_objects <- osm_bbox_objects(bbox = c(0.5, 40, 1, 40.5))

    # diff_up <-  osm_diff_upload_changeset(changeset_id = chset_id, osmcha = osm_change)
    # TODO: ! HTTP 409 Conflict. In testing server
  })

  ## Close: `PUT /api/0.6/changeset/#id/close` ----
  # osm_close_changeset(changeset_id = chset_id)
})


## Read: `GET /api/0.6/changeset/#id*?include_discussion='true'*` ----

test_that("osm_read_changeset works", {
  with_mock_dir("mock_read_changeset", {
    chaset <- osm_get_changesets(changeset_id = 137595351)
    chaset_discuss <- osm_get_changesets(changeset_id = 137595351, include_discussion = TRUE)
  })

  expect_s3_class(chaset, c("osmapi_changesets", "data.frame"))
  expect_s3_class(chaset_discuss, c("osmapi_changesets", "data.frame"))
  expect_identical(names(chaset), setdiff(column_changeset, "discussion"))
  expect_identical(names(chaset_discuss), c(column_changeset))
  lapply(chaset_discuss$discussion, function(x) {
    expect_s3_class(x, c("changeset_comments", "data.frame"))
    expect_named(x, column_discuss)

    mapply(function(y, cl) expect_true(inherits(y, cl)), y = x, cl = class_columns_discussion[names(x)])

    # Check that time is extracted, otherwise it's 00:00:00 in local time
    expect_false(unique(strftime(as.POSIXct(x$date), format = "%M:%S") == "00:00"))
  })

  mapply(function(x, cl) expect_true(inherits(x, cl)), x = chaset, cl = class_columns[names(chaset)])
  mapply(function(x, cl) expect_true(inherits(x, cl)), x = chaset_discuss, cl = class_columns[names(chaset_discuss)])

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  lapply(chaset[, c("created_at", "closed_at")], function(x) {
    expect_false(strftime(as.POSIXct(x), format = "%M:%S") == "00:00")
  })

  lapply(chaset_discuss[, c("created_at", "closed_at")], function(x) {
    expect_false(strftime(as.POSIXct(x), format = "%M:%S") == "00:00")
  })

  # methods
  expect_s3_class(print(chaset), c("osmapi_changesets", "data.frame"))
  expect_s3_class(print(chaset_discuss), c("osmapi_changesets", "data.frame"))
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
  expect_s3_class(print(osmchange), c("osmapi_OsmChange", "data.frame"))
})


## Query: `GET /api/0.6/changesets` ----

test_that("osm_query_changesets works", {
  chaset <- list()
  with_mock_dir("mock_query_changesets", {
    chaset$ids <- osm_query_changesets(changeset_ids = c(137627129, 137625624))
    chaset$time <- osm_query_changesets(
      bbox = c(-1.241112, 38.0294955, 8.4203171, 42.9186456),
      user = "Mementomoristultus",
      time = "2023-06-22T02:23:23Z",
      time_2 = "2023-06-22T00:38:20Z"
    )
    chaset$closed <- osm_query_changesets(
      bbox = c("-9.3015367,41.8073642,-6.7339533,43.790422"),
      user = "Mementomoristultus",
      closed = TRUE
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

  # methods
  lapply(print(chaset), expect_s3_class, c("osmapi_changesets", "data.frame"))


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
  expect_s3_class(print(empty_chaset), c("osmapi_changesets", "data.frame"))
})
