column_users <- c(
  "id", "display_name", "account_created", "description", "img", "contributor_terms", "roles", "changesets_count",
  "traces_count", "blocks_received.count", "blocks_received.active", "blocks_issued.count", "blocks_issued.active"
)

class_columns <- list(
  id = "character", display_name = "character", account_created = "POSIXct", description = "character",
  img = "character", contributor_terms = "logical", roles = "character", changesets_count = "integer",
  traces_count = "integer", blocks_received.count = "integer", blocks_received.active = "integer",
  blocks_issued.count = "integer", blocks_issued.active = "integer"
)


## Details of a user: `GET /api/0.6/user/#id` ----

test_that("osm_details_user works", {
  usr <- list()
  xml_usr <- list()
  with_mock_dir("mock_details_user", {
    usr$usr <- osm_get_user_details(user_id = "11725140")
    usr$mod <- osm_get_user_details(user_id = 61942)

    xml_usr$usr <- osm_get_user_details(user_id = "11725140", format = "xml")
    xml_usr$mod <- osm_get_user_details(user_id = 61942, format = "xml")
  })

  lapply(usr, expect_s3_class, "data.frame")
  lapply(usr, function(x) expect_named(x, column_users))

  lapply(usr, lapply, function(x) {
    mapply(function(y, cl) expect_true(inherits(y, cl)), y = x, cl = class_columns[names(x)])
  })

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  lapply(usr, function(x) expect_false(unique(strftime(as.POSIXct(x$account_created), format = "%M:%S") == "00:00")))

  lapply(xml_usr, expect_s3_class, "xml_document")

  # Compare xml & R
  mapply(function(d, x) {
    expect_identical(nrow(d), xml2::xml_length(x))
  }, d = usr, x = xml_usr)


  ## Empty results

  with_mock_dir("mock_details_user_empty", {
    empty_usr <- osm_get_user_details(user_id = 2)
    xml_empty_usr <- osm_get_user_details(user_id = 2, format = "xml")
    json_empty_usr <- osm_get_user_details(user_id = 2, format = "json")
  })

  expect_s3_class(empty_usr, "data.frame")
  expect_named(empty_usr, column_users)


  mapply(
    function(x, cl) expect_true(inherits(x, cl)),
    x = empty_usr,
    cl = class_columns[names(empty_usr)]
  )

  expect_s3_class(xml_empty_usr, "xml_document")
  expect_type(json_empty_usr, "list")

  # Compare xml, json & R
  expect_identical(nrow(empty_usr), 0L)
  expect_identical(xml2::xml_length(xml_empty_usr), 0L)
  expect_identical(length(json_empty_usr$users), 0L)
})


## Details of multiple users: `GET /api/0.6/users?users=#id1,#id2,...,#idn` ----

test_that("osm_details_users works", {
  usrs <- list()
  with_mock_dir("mock_details_users", {
    usrs$usrs <- osm_get_user_details(user_id = c(1, 24, 44, 45, 46, 48, 49, 50))
    usrs$mod <- osm_get_user_details(user_id = c(61942, 564990))
  })

  lapply(usrs, expect_s3_class, "data.frame")
  lapply(usrs, function(x) expect_named(x, column_users))

  lapply(usrs, lapply, function(x) {
    mapply(function(y, cl) expect_true(inherits(y, cl)), y = x, cl = class_columns[names(x)])
  })

  # Check that time is extracted, otherwise it's 00:00:00 in local time
  lapply(usrs, function(x) expect_false(unique(strftime(as.POSIXct(x$account_created), format = "%M:%S") == "00:00")))


  ## Empty results

  with_mock_dir("mock_details_users_empty", {
    empty_usrs <- osm_get_user_details(user_id = 2:3)
  })

  expect_s3_class(empty_usrs, "data.frame")
  expect_named(empty_usrs, column_users)
  expect_identical(nrow(empty_usrs), 0L)

  mapply(
    function(x, cl) expect_true(inherits(x, cl)),
    x = empty_usrs,
    cl = class_columns[names(empty_usrs)]
  )
})


## Details of the logged-in user: `GET /api/0.6/user/details` ----

test_that("osm_details_logged_user works", {
  with_mock_dir("mock_details_logged_user", {
    usr_details <- osm_details_logged_user()
  })

  expect_type(usr_details, "list")
  expect_named(
    usr_details,
    c(
      "user", "description", "img", "contributor_terms", "roles",
      "changesets", "traces", "blocks", "home", "languages", "messages"
    )
  )
})


## Preferences of the logged-in user: `GET|PUT|DELETE /api/0.6/user/preferences` ----

test_that("osm_set-get_preferences_user works", {
  with_mock_dir("mock_get_prefs_user", {
    ###  `GET /api/0.6/user/preferences` ----
    preferences <- osm_get_preferences_user()
    preferences_xml <- osm_get_preferences_user(format = "xml")
    preferences_json <- osm_get_preferences_user(format = "json")
    ###  `GET /api/0.6/user/preferences/[your_key]` (without the brackets) ----
    preference <- osm_get_preferences_user(key = "mapcomplete-language")
    # preference <- osm_get_preferences_user(key = "gps.trace.visibility") # TODO: error due to dots?
  })

  path_xml <- tempfile(fileext = ".xml")
  with_mock_dir("mock_set_prefs_user", {
    ###  `PUT /api/0.6/user/preferences/[your_key]` ----
    expect_null(osm_set_preferences_user(key = "test-pref", value = "value"))
    ###  `DELETE /api/0.6/user/preferences/[your_key]` ----
    expect_null(osm_set_preferences_user(key = "test-pref", value = NULL))
    ###  `PUT /api/0.6/user/preferences` ----
    expect_null(osm_set_preferences_user(all_prefs = preferences))
    expect_null(osm_set_preferences_user(all_prefs = preferences_xml))
    expect_null(osm_set_preferences_user(all_prefs = preferences_json))

    xml2::write_xml(preferences_xml, file = path_xml)
    expect_null(osm_set_preferences_user(all_prefs = path_xml))
  })
  file.remove(path_xml)

  expect_s3_class(preferences, "data.frame")
  expect_named(preferences, c("key", "value"))

  expect_s3_class(preferences_xml, "xml_document")
  expect_type(preferences_json, "list")
  expect_named(preferences_json, c("version", "generator", "copyright", "attribution", "license", "preferences"))
  expect_type(preference, "character")


  expect_error(
    osm_set_preferences_user(key = "mapcomplete-language", value = preference, all_prefs = preferences_xml),
    "`key` & `value`, or `all_prefs` must be provided but not all at the same time."
  )
  expect_error(osm_set_preferences_user(), "`key` is missing with no defaults.")
  expect_error(osm_set_preferences_user(key = "mapcomplete-language"), "`value` is missing with no defaults.")
  expect_error(osm_set_preferences_user(all_prefs = "x"), "`all_prefs` is interpreted as a path to an xml file with ")
  expect_error(osm_set_preferences_user(all_prefs = TRUE), "`all_prefs` must be a path to a xml file with the ")
})
