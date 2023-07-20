test_that("osmapi_connection works", {
  expect_identical(set_osmapi_connection(server = "openstreetmap.org"), "https://api.openstreetmap.org")
  expect_identical(set_osmapi_connection(server = "testing"), "https://master.apis.dev.openstreetmap.org")

  # expect_invisible(logout_osmapi()) # Error in `loadNamespace(x)`: there is no package called 'httpuv'
})
