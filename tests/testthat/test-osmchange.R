column_osmchange <- c(
  "action_type", "type", "id", "visible", "version", "changeset", "timestamp",
  "user", "uid", "lat", "lon", "members", "tags"
)

class_columns <- list(
  action_type = "character", type = "character", id = "character", visible = "logical", version = "integer",
  changeset = "character", timestamp = "POSIXct", user = "character", uid = "character",
  lat = "character", lon = "character", members = "list", tags = "list"
)


test_that("osmchange_create works", {
  # obj_id <- data.frame(
  #   type = c("node", "way", "way", "relation", "relation", "node"),
  #   changeset = 2017,
  #   tags = list()
  # )

  with_mock_dir("mock_osmchange_create", {
    obj_current <- osm_get_objects(
      osm_type = c("node", "way", "way", "relation", "relation", "node"),
      osm_id = c("35308286", "13073736", "235744929", "40581", "341530", "1935675367"),
    )
  })
  osmchange_crea <- list()
  osmchange_crea$osmapi_obj <- osmchange_create(obj_current)
  df_current <- tags_list2wide(obj_current)
  class(df_current) <- "data.frame"
  osmchange_crea$df <- osmchange_create(df_current)

  expect_s3_class(
    osmchange_crea$osmapi_obj,
    class = c("osmapi_OsmChange", "osmapi_objects", "data.frame"), exact = TRUE
  )
  expect_s3_class(osmchange_crea$df, class = c("osmapi_OsmChange", "data.frame"), exact = TRUE)
  expect_named(osmchange_crea$osmapi_obj, column_osmchange)

  mapply(
    function(x, cl) expect_true(inherits(x, cl)),
    x = osmchange_crea$osmapi_obj, cl = class_columns[names(osmchange_crea$osmapi_obj)]
  )

  sel_cols <- intersect(names(osmchange_crea$df), names(class_columns))
  mapply(
    function(x, cl) expect_true(inherits(x, cl)),
    x = osmchange_crea$df[sel_cols], cl = class_columns[sel_cols]
  )

  lapply(osmchange_crea, function(x) expect_equal(nrow(x), nrow(obj_current)))
})


test_that("osmchange_modify works", {
  osmchange_mod <- list()
  with_mock_dir("mock_osmchange_modify", {
    obj_current <- osm_get_objects(
      osm_type = c("node", "way", "way", "relation", "relation", "node"),
      osm_id = c("35308286", "13073736", "235744929", "40581", "341530", "1935675367")
    )
    expect_message(
      osmchange_mod$current <- osmchange_modify(obj_current, members = TRUE, lat_lon = TRUE),
      " objects without modifications will be discarded."
    )

    df_current <- obj_current
    class(df_current) <- "data.frame"
    expect_error(
      osmchange_modify(df_current, members = TRUE, lat_lon = TRUE),
      "Specify `tag_keys` or pass a `osmapi_objects` as `x` parameter to update all tags. To omit tags, set parameter"
    )
    # tags_in_columns = TRUE  # TODO tag type column clashes with id
    df_current_wide <- osmapiR::tags_list2wide(obj_current)
    class(df_current_wide) <- "data.frame"
    expect_message(
      osmchange_mod$current_df <- osmchange_modify(df_current_wide, tag_keys = "name", members = TRUE, lat_lon = TRUE),
      " objects without modifications will be discarded."
    )


    obj_version <- osm_get_objects(
      osm_type = c("node", "way", "way", "relation", "relation", "node"),
      osm_id = c("35308286", "13073736", "235744929", "40581", "341530", "1935675367"),
      version = c(1, 3, 2, 5, 7, 1)
    )
    osmchange_mod$version <- osmchange_modify(obj_version, members = TRUE, lat_lon = TRUE)
    osmchange_mod$version_name <- osmchange_modify(obj_version, tag_keys = "name", members = TRUE, lat_lon = TRUE)
  })

  lapply(osmchange_mod, function(x) {
    expect_s3_class(x, class = c("osmapi_OsmChange", "osmapi_objects", "data.frame"), exact = TRUE)
  })
  lapply(osmchange_mod, function(x) expect_named(x, column_osmchange))

  lapply(osmchange_mod, function(x) {
    mapply(
      function(y, cl) expect_true(inherits(y, cl)),
      y = x, cl = class_columns[names(x)]
    )
  })

  lapply(osmchange_mod[c("current", "current_df")], function(x) expect_equal(nrow(x), 0))
  expect_equal(nrow(osmchange_mod$version), nrow(obj_version))
  expect_true(nrow(osmchange_mod$version_name) > 0)

  expect_error(
    osmchange_modify(df_current, tag_keys = "NON_existent"),
    "Missing columns for `tag_keys`: "
  )

  # osmcha_DF2xml
  lapply(osmchange_mod, function(x) expect_s3_class(osmcha_DF2xml(x), "xml_document"))
})


test_that("osmchange_delete works", {
  obj_id <- data.frame(
    type = c("node", "way", "way", "relation", "relation", "node"),
    id = c("35308286", "13073736", "235744929", "40581", "341530", "1935675367")
  )

  osmchange_del <- list()
  with_mock_dir("mock_osmchange_delete", {
    osmchange_del$del <- osmchange_delete(obj_id, delete_if_unused = FALSE)
    osmchange_del$if_unused <- osmchange_delete(obj_id, delete_if_unused = TRUE)
  })

  lapply(osmchange_del, function(x) {
    expect_s3_class(x, class = c("osmapi_OsmChange", "osmapi_objects", "data.frame"), exact = TRUE)
  })
  lapply(osmchange_del, function(x) expect_named(x, column_osmchange))

  lapply(osmchange_del, function(x) {
    mapply(
      function(y, cl) expect_true(inherits(y, cl)),
      y = x, cl = class_columns[names(x)]
    )
  })

  lapply(osmchange_del, function(x) expect_equal(nrow(x), nrow(obj_id)))

  ## osmcha_DF2xml
  lapply(osmchange_del, function(x) expect_s3_class(osmcha_DF2xml(x), "xml_document"))
})
