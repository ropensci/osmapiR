test_that("osmapi_objects works", {
  x <- data.frame(
    type = c("node", "node", "way", "relation"),
    id = 1:4,
    lat = c(0, 1, NA, NA),
    lon = c(0, 1, NA, NA),
    name = c(NA, NA, "My way", "Our relation"),
    type.1 = c(NA, NA, NA, "Column clash!")
  )
  x$members <- list(
    NULL, NULL, 1:2,
    matrix(
      c("node", "1", "node", "2", "way", "3"),
      nrow = 3, ncol = 2, byrow = TRUE, dimnames = list(NULL, c("type", "ref"))
    )
  )

  objs <- list()
  objs$tag_ch <- osmapi_objects(x, tag_columns = "name")
  objs$tag_num <- osmapi_objects(x, tag_columns = 5)
  objs$tag_bool <- osmapi_objects(x, tag_columns = c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE))
  objs$tag_ch_named <- osmapi_objects(x, tag_columns = c(type = "type.1"))
  objs$tag_num_named <- osmapi_objects(x, tag_columns = c(type = 6))

  x$name <- NULL
  x$tags <- list(
    new_tags_df(),
    new_tags_df(),
    new_tags_df(data.frame(key = "name", value = "May way")),
    new_tags_df(data.frame(key = "name", value = "Our relation"))
  )
  objs$tags <- osmapi_objects(x)

  lapply(objs, function(x) {
    expect_s3_class(
      validate_osmapi_objects(x, commited = FALSE),
      class = c("osmapi_objects", "data.frame"),
      exact = TRUE
    )
  })
})
