test_that("osmapi_connection works", {
  expect_identical(set_osmapi_connection(server = "openstreetmap.org"), "https://api.openstreetmap.org")
  expect_identical(set_osmapi_connection(server = "testing"), "https://master.apis.dev.openstreetmap.org")

  with_mock_dir("mock_osmapi_authenticate", {
    display_name <- expect_invisible(authenticate_osmapi())
  })

  expect_identical(display_name, c(display_name = "jmaspons"))

  without_internet({
    expect_invisible(logout_osmapi())
  })
})
