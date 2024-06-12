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

  osmchange_crea <- list()
  osmchange_crea$osmapi_obj <- osmchange_create(obj)
  obj_wide <- tags_list2wide(obj)
  osmchange_crea$osmapi_obj_wide <- osmchange_create(obj_wide)
  osmchange_crea$osmapi_obj_empty <- osmchange_create(obj[logical(), ])

  lapply(osmchange_crea, expect_s3_class, class = c("osmapi_OsmChange", "osmapi_objects", "data.frame"), exact = TRUE)
  lapply(osmchange_crea, function(x) expect_true(all(names(x) %in% column_osmchange)))

  lapply(osmchange_crea, function(x) {
    mapply(
      function(y, cl) expect_true(inherits(y, cl)),
      y = x, cl = class_columns[names(x)]
    )
  })

  lapply(osmchange_crea[!grepl("empty", names(osmchange_crea))], function(x) expect_equal(nrow(x), nrow(obj)))

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
    obj_version$tags[[5]]$value[obj_version$tags[[5]]$key %in% c("name", "name:ca")] <- NA_character_
    osmchange_mod$version <- osmchange_modify(obj_version, members = TRUE, lat_lon = TRUE)
    osmchange_mod$version_name <- osmchange_modify(obj_version, tag_keys = "name", members = TRUE, lat_lon = TRUE)

    # TODO: test update of tags, members and lat_lon only with and without actual changes
  })
  osmchange_mod$empty <- osmchange_modify(obj_current[logical(), ])
  osmchange_mod$empty_name <- osmchange_modify(obj_current[logical(), ], tag_keys = "name")

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

  expect_false("name" %in% osmchange_mod$version_name$tags[[5]]$key)
  expect_true("name:ca" %in% osmchange_mod$version_name$tags[[5]]$key)
  expect_true(all(c("name", "name:ca") %in% osmchange_mod$version$tags[[5]]$key))
  expect_true(all(is.na(
    osmchange_mod$version$tags[[5]]$value[osmchange_mod$version$tags[[5]]$key %in% c("name", "name:ca")]
  )))

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
  osmchange_del$empty <- osmchange_delete(obj_id[logical(), ])

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

  lapply(osmchange_del[!grepl("empty", names(osmchange_del))], function(x) expect_equal(nrow(x), nrow(obj_id)))

  ## osmcha_DF2xml
  lapply(osmchange_del, function(x) expect_s3_class(osmcha_DF2xml(x), "xml_document"))
})
