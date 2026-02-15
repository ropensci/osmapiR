test_that("bbox_to_string works", {
  bb <- c(1.8366775, 41.8336843, 1.8379971, 41.8344537)
  expected <- paste0(bb, collapse = ",")
  bb_string <- expected
  bb_named <- stats::setNames(bb, c("xmin", "ymin", "xmax", "ymax"))
  bb_named2 <- stats::setNames(bb, c("left", "bottom", "right", "top"))
  bb_mat <- matrix(bb, nrow = 2, ncol = 2, byrow = TRUE)#, dimnames = list(c("min", "max"), c("x", "y")))
  bb_mat_named <- matrix(bb, nrow = 2, ncol = 2, dimnames = list(c("x", "y"), c("min", "max")))
  bb_mat_named2 <- matrix(bb, nrow = 2, ncol = 2, dimnames = list(c("coords.x1", "coords.x2"), c("min", "max")))

  expect_identical(bbox_to_string(bb_string), expected)
  expect_identical(bbox_to_string(bb), expected)
  expect_identical(bbox_to_string(bb_named), expected)
  expect_identical(bbox_to_string(bb_named2), expected)
  expect_identical(bbox_to_string(rev(bb_named)), expected)
  expect_identical(bbox_to_string(rev(bb_named2)), expected)
  expect_identical(bbox_to_string(bb_mat), expected)
  expect_identical(bbox_to_string(bb_mat_named), expected)
  expect_identical(bbox_to_string(bb_mat_named2), expected)

  if (requireNamespace("sf", quietly = TRUE)) {
    bb_sf <- sf::st_bbox(bb_named, crs = 4326)
    expect_identical(bbox_to_string(bb_sf), expected)
  }

  ## Warning if terra is not in suggested packages
  # skip_if_not_installed("terra")
  # bb_terra <- terra::ext(bb)
  # expect_identical(bbox_to_string(bb_terra), expected)

  expect_error(bbox_to_string(1:3), "bbox must contain four elements")
  expect_message(bbox_to_string(c(bb, 0)), "only the first four elements of bbox used")
})
