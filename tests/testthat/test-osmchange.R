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
  # TODO: replace osm_get_objects()
  # obj_id <- data.frame(
  #   type = c("node", "way", "way", "relation", "relation", "node"),
  #   changeset = 2017,
  #   lat = character(),
  #   lon = character(),
  #   members = list()
  #   tags = list()
  # )
  # obj<- osmapi_objects(obj)

  with_mock_dir("mock_osmchange_create", {
    obj_current <- osm_get_objects(
      osm_type = c("node", "way", "way", "relation", "relation", "node"),
      osm_id = c("35308286", "13073736", "235744929", "40581", "341530", "1935675367"),
    )
  })
  obj_current <- obj_current[, setdiff(names(obj_current), c("id", "visible", "version", "timestamp", "user", "uid"))]
  osmchange_crea <- list()
  osmchange_crea$osmapi_obj <- osmchange_create(obj_current)
  obj_current_wide <- tags_list2wide(obj_current)
  osmchange_crea$osmapi_obj_wide <- osmchange_create(obj_current_wide)

  lapply(osmchange_crea, expect_s3_class, class = c("osmapi_OsmChange", "osmapi_objects", "data.frame"), exact = TRUE)
  lapply(osmchange_crea, function(x) expect_true(all(names(x) %in% column_osmchange)))

  lapply(osmchange_crea, function(x) {
    mapply(
      function(y, cl) expect_true(inherits(y, cl)),
      y = x, cl = class_columns[names(x)]
    )
  })

  lapply(osmchange_crea, function(x) expect_equal(nrow(x), nrow(obj_current)))

  ## osmcha_DF2xml
  lapply(osmchange_crea, function(x) expect_s3_class(osmcha_DF2xml(x), "xml_document"))
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
    expect_error(osmchange_modify(df_current, members = TRUE, lat_lon = TRUE))

    current_wide <- tags_list2wide(obj_current)
    expect_message(
      osmchange_mod$current_wide <- osmchange_modify(current_wide, tag_keys = "name", members = TRUE, lat_lon = TRUE),
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

  lapply(osmchange_mod[c("current", "current_wide")], function(x) expect_equal(nrow(x), 0))
  expect_equal(nrow(osmchange_mod$version), nrow(obj_version))
  expect_true(nrow(osmchange_mod$version_name) > 0)

  # osmcha_DF2xml
  lapply(osmchange_mod, function(x) expect_s3_class(osmcha_DF2xml(x), "xml_document"))
})


test_that("osmchange_delete works", {
  obj_id <- osmapi_objects(data.frame(
    type = c("node", "way", "way", "relation", "relation", "node"),
    id = c("35308286", "13073736", "235744929", "40581", "341530", "1935675367")
  ))

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
