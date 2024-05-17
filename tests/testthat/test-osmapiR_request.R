test_that("error handling works", {
  with_mock_dir("mock_error_responses", {
    ## Status only

    expect_error(
      osm_get_objects(osm_type = "relation", osm_id = 1),
      "Gone."
    )
    expect_error(
      osm_get_objects(osm_type = "way", osm_id = 1),
      "Not Found."
    )


    ## Message in the body (content-type: text/plain)

    expect_error(
      err <- osm_create_object(x = osmapi_objects(data.frame(type = "node")), changeset_id = 1),
      'Cannot parse valid node from xml string <node changeset="1" lat="NULL" lon="NULL"/>. lat not a number'
    )
    expect_error(
      err <- osm_create_object(x = osmapi_objects(data.frame(type = "way")), changeset_id = 1),
      "The user doesn't own that changeset"
    )


    ##  Message in the body (content-type: text/html)

    expect_error(
      osmapi_request() |> httr2::req_url_path_append("err") |> httr2::req_perform(),
      "404 File not found"
    )
    # expect_error(osm_delete_gpx(1:2)) # may be fixed in the future by vectorizing api calls

    expect_error(
      osmapi_request() |> httr2::req_url_path_append("nodes") |>
        httr2::req_url_query(nodes = paste(1:2000, collapse = ",")) |> httr2::req_perform(),
      "414 URI Too Long"
    )
  })
})
