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

    ## TODO: look for error responses with body as text/html
  })
})
