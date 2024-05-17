test_that("oauth_request works", {
  req <- httr2::request(get_osmapi_url())
  req_oauth <- oauth_request(req = req)

  without_internet({
    expect_GET(httr2::req_perform(req_oauth))
  })
})
