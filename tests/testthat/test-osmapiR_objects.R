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
  objs$tag_ch <- osmapi_objects(x, tag_columns = c("type.1", "name"))
  objs$tag_num <- osmapi_objects(x, tag_columns = 6:5)
  objs$tag_bool <- osmapi_objects(x, tag_columns = c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE))
  objs$tag_ch_named <- osmapi_objects(x, tag_columns = c(type = "type.1", name = "name"))
  objs$tag_num_named <- osmapi_objects(x, tag_columns = c(type = 6, name = 5))

  x_tags <- x
  x_tags$name <- NULL
  x_tags$tags <- list(
    new_tags_df(),
    new_tags_df(),
    new_tags_df(data.frame(key = "name", value = "May way")),
    new_tags_df(data.frame(key = "name", value = "Our relation"))
  )
  objs$tags <- osmapi_objects(x_tags)

  lapply(objs, function(x) {
    expect_s3_class(
      validate_osmapi_objects(x, commited = FALSE),
      class = c("osmapi_objects", "data.frame"),
      exact = TRUE
    )
    lapply(x$tags, function(y) expect_false(any(is.na(y$value))))
  })


  # keep_na_tags = TRUE

  objs_na <- list()
  objs_na$tag_ch <- osmapi_objects(x, tag_columns = c("type.1", "name"), keep_na_tags = TRUE)
  objs_na$tag_num <- osmapi_objects(x, tag_columns = 6:5, keep_na_tags = TRUE)
  objs_na$tag_bool <- osmapi_objects(
    x = x, tag_columns = c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE), keep_na_tags = TRUE
  )
  objs_na$tag_ch_named <- osmapi_objects(x, tag_columns = c(type = "type.1", name = "name"), keep_na_tags = TRUE)
  objs_na$tag_num_named <- osmapi_objects(x, tag_columns = c(type = 6, name = 5), keep_na_tags = TRUE)

  lapply(objs_na, function(x) {
    expect_s3_class(
      validate_osmapi_objects(x, commited = FALSE),
      class = c("osmapi_objects", "data.frame"),
      exact = TRUE
    )
    expect_true(any(vapply(x$tags, function(y) any(is.na(y$value)), FUN.VALUE = logical(1))))
  })


  # 0 row input

  x_empty <- x[logical(), ]
  objs_empty <- list()
  objs_empty$tag_ch <- osmapi_objects(x_empty, tag_columns = c("type.1", "name"))
  objs_empty$tag_bool <- osmapi_objects(x_empty, tag_columns = c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE))
  objs_empty$tag_ch_named <- osmapi_objects(x_empty, tag_columns = c(type = "type.1"))
  objs_empty$mis <- osmapi_objects(x_empty)

  x_empty$tags <- list()
  objs_empty$tags <- osmapi_objects(x_empty)

  lapply(objs_empty, function(x) {
    expect_s3_class(
      validate_osmapi_objects(x, commited = FALSE),
      class = c("osmapi_objects", "data.frame"),
      exact = TRUE
    )
    expect_identical(nrow(x), 0L)
  })
})
