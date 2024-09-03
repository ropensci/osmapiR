test_that("OSM objects tags_list-wide works", {
  tags_list <- list()
  tags_wide <- list()
  with_mock_dir("mock_fetch_objects", {
    tags_list$node <- osm_fetch_objects(osm_type = "nodes", osm_ids = c(35308286, 1935675367))
    tags_list$way <- osm_fetch_objects(osm_type = "ways", osm_ids = c(13073736L, 235744929L))
    tags_list$rel <- osm_fetch_objects(osm_type = "relations", osm_ids = c("40581", "341530"), versions = c(3, 1))

    tags_wide$node <- osm_fetch_objects(osm_type = "nodes", osm_ids = c(35308286, 1935675367), tags_in_columns = TRUE)
    tags_wide$way <- osm_fetch_objects(osm_type = "ways", osm_ids = c(13073736L, 235744929L), tags_in_columns = TRUE)
    suppressWarnings( # Tag's keys clash with other columns
      tags_wide$rel <- osm_fetch_objects(
        osm_type = "relations", osm_ids = c("40581", "341530"), versions = c(3, 1), tags_in_columns = TRUE
      )
    )
  })

  tags_2wide <- lapply(tags_list, tags_list2wide)
  tags_2list <- lapply(tags_wide, tags_wide2list)

  mapply(expect_identical, object = tags_2wide, expected = tags_wide)
  mapply(expect_identical, object = tags_2list[-3], expected = tags_list[-3]) # different order of tags tags_2list$rel

  ## TODO: tags' order not maintained
  mapply(function(object, expected) {
    expect_setequal(do.call(paste, object), do.call(paste, expected))
  }, object = tags_2list$rel$tags, expected = tags_list$rel$tags)
  expect_identical(
    tags_2list$rel[, setdiff(names(tags_2list$rel), "tags")],
    tags_list$rel[, setdiff(names(tags_list$rel), "tags")]
  )


  ## Test one tag only

  tag1_list <- lapply(tags_list, function(x) {
    x$tags <- lapply(x$tags, function(y) structure(y[y$key == "name", ], row.names = 1L))
    x
  })
  tag1_wide <- lapply(tags_wide, function(x) {
    tags <- attr(x, "tag_columns")
    rm_cols <- tags[names(tags) != "name"]
    x <- x[, -rm_cols]
    attr(x, "tag_columns") <- c(name = which(names(x) == "name"))
    x
  })

  tag1_2wide <- lapply(tag1_list, tags_list2wide)
  tag1_2list <- lapply(tag1_wide, tags_wide2list)

  mapply(expect_identical, object = tag1_2wide, expected = tag1_wide)
  mapply(expect_identical, object = tag1_2list, expected = tag1_list)


  ## Test messages and errors

  expect_message(tags_list2wide(tags_wide[[1]]), "x is already in a tags wide format.")
  expect_message(tags_wide2list(tags_list[[1]]), "x is already in a tags list column format.")

  expect_error(tags_list2wide(data.frame()), "x must be an `osmapi_objects` or `osmapi_changesets` object.")
  expect_error(tags_wide2list(data.frame()), "x must be an `osmapi_objects` or `osmapi_changesets` object.")
})


test_that("Changesets tags_list-wide works", {
  api_capabilities_ori <- getOption("osmapir.api_capabilities")
  api_capabilities <- api_capabilities_ori
  api_capabilities$api$changesets[c("default_query_limit", "maximum_query_limit")] <- c(10, 20)
  options(osmapir.api_capabilities = api_capabilities)

  tags_list <- list()
  tags_wide <- list()
  with_mock_dir("mock_query_changesets", {
    tags_list$ids <- osm_query_changesets(changeset_ids = c(137627129, 137625624), order = "oldest")
    tags_list$time <- osm_query_changesets(
      bbox = c(-1.241112, 38.0294955, 8.4203171, 42.9186456),
      user = "Mementomoristultus",
      time = "2023-06-22T02:23:23Z",
      time_2 = "2023-06-22T00:38:20Z"
    )
    tags_list$closed <- osm_query_changesets(
      bbox = c("-9.3015367,41.8073642,-6.7339533,43.790422"),
      user = "Mementomoristultus",
      closed = TRUE
    )

    tags_wide$ids <- osm_query_changesets(
      changeset_ids = c(137627129, 137625624), order = "oldest", tags_in_columns = TRUE
    )
    tags_wide$time <- osm_query_changesets(
      bbox = c(-1.241112, 38.0294955, 8.4203171, 42.9186456),
      user = "Mementomoristultus",
      time = "2023-06-22T02:23:23Z",
      time_2 = "2023-06-22T00:38:20Z",
      tags_in_columns = TRUE
    )
    tags_wide$closed <- osm_query_changesets(
      bbox = c("-9.3015367,41.8073642,-6.7339533,43.790422"),
      user = "Mementomoristultus",
      closed = TRUE,
      tags_in_columns = TRUE
    )
  })

  tags_2wide <- lapply(tags_list, tags_list2wide)
  tags_2list <- lapply(tags_wide, tags_wide2list)

  mapply(expect_identical, object = tags_2wide, expected = tags_wide)

  ## TODO: tags' order not maintained
  mapply(function(object, expected) {
    mapply(function(obj, exp) {
      expect_setequal(do.call(paste, obj), do.call(paste, exp))
    }, obj = object$tags, exp = expected$tags)
    expect_identical(object[, setdiff(names(object), "tags")], expected[, setdiff(names(expected), "tags")])
  }, object = tags_2list, expected = tags_list)

  expect_message(tags_list2wide(tags_wide[[1]]), "x is already in a tags wide format.")
  expect_message(tags_wide2list(tags_list[[1]]), "x is already in a tags list column format.")


  options(osmapir.api_capabilities = api_capabilities_ori)
})
