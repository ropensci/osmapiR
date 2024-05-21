test_that("osmapi_connection works", {
  expect_message(
    expect_identical(set_osmapi_connection(server = "openstreetmap.org"), "https://api.openstreetmap.org"),
    "Logged out from"
  )
  expect_message(
    expect_identical(set_osmapi_connection(server = "testing"), "https://master.apis.dev.openstreetmap.org"),
    "Logged out from"
  )

  with_mock_dir("mock_osmapi_authenticate", {
    expect_message(display_name <- authenticate_osmapi(), "Logged in at")
  })

  expect_identical(display_name, c(display_name = "jmaspons"))

  without_internet({
    expect_message(expect_invisible(logout_osmapi()), "Logged out from")
  })
})
