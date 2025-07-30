## Methods for user data


## Details of a user: `GET /api/0.6/user/#id` ----
# This API method was added in September 2012 ([https://github.com/openstreetmap/openstreetmap-website/commit/3ce4de1295ecec082313740a3cdf25c2831164f7 code]).
#
# You can get the home location and the displayname of the user, by using
#
### Response XML ----
#  GET /api/0.6/user/#id
# this returns for example
# <syntaxhighlight lang="xml">
# <osm version="0.6" generator="OpenStreetMap server">
#   <user id="12023" display_name="jbpbis" account_created="2007-08-16T01:35:56Z">
#     <description></description>
#     <contributor-terms agreed="false"/>
#     <img href="http://www.gravatar.com/avatar/c8c86cd15f60ecca66ce2b10cb6b9a00.jpg?s=256&amp;d=http%3A%2F%2Fwww.openstreetmap.org%2Fassets%2Fusers%2Fimages%2Flarge-39c3a9dc4e778311af6b70ddcf447b58.png"/>
#     <roles>
#       <moderator/>
#     </roles>
#     <changesets count="1"/>
#     <traces count="0"/>
#     <blocks>
#       <received count="0" active="0"/>
#       <issued count="68" active="45"/>
#     </blocks>
#   </user>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/user/#id.json
# <syntaxhighlight lang="json">
# {
#   "version": "0.6",
#   "generator": "OpenStreetMap server",
#   "user": {"id": 12023, "display_name": "jbpbis", "account_created": "2007-08-16T01:35:56Z", "description": "", "contributor_terms": {"agreed": False}, "roles": [], "changesets": {"count": 1}, "traces": {"count": 0}, "blocks": {"received": {"count": 0, "active": 0}}}
# }
# </syntaxhighlight>
#
# or an empty file if no user found for given identifier.
#
# Note that user accounts which made edits may be deleted. Such users are listed at https://planet.osm.org/users_deleted/users_deleted.txt

#' Details of a user
#'
#' @param user_id The id of the user to retrieve represented by a numeric or a character value (not the display name).
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#'
#' @return
#' For users not found, the result is empty. If `format = "R"`, returns a data frame with one user per row.
#'
#' ## `format = "xml"`
#'
#' Returns a [xml2::xml_document-class] with the following format:
#' ``` xml
#' <osm version="0.6" generator="OpenStreetMap server">
#'   <user id="12023" display_name="jbpbis" account_created="2007-08-16T01:35:56Z">
#'     <description></description>
#'     <contributor-terms agreed="false"/>
#'     <img href="http://www.gravatar.com/avatar/c8c86cd15f60ecca66ce2b10cb6b9a00.jpg?s=256&amp;d=http%3A%2F%2Fwww.openstreetmap.org%2Fassets%2Fusers%2Fimages%2Flarge-39c3a9dc4e778311af6b70ddcf447b58.png"/>
#'     <roles>
#'     </roles>
#'     <changesets count="1"/>
#'     <traces count="0"/>
#'     <blocks>
#'       <received count="0" active="0"/>
#'     </blocks>
#'   </user>
#' </osm>
#' ```
#'
#' ## `format = "json"`
#'
#' Returns a list with the following json structure:
#' ``` json
#' {
#'   "version": "0.6",
#'   "generator": "OpenStreetMap server",
#'   {"user": {"id": 12023, "display_name": "jbpbis", "account_created": "2007-08-16T01:35:56Z", "description": "", "contributor_terms": {"agreed": False}, "roles": [], "changesets": {"count": 1}, "traces": {"count": 0}, "blocks": {"received": {"count": 0, "active": 0}}}}
#' }
#' ```
#'
# @family users' functions
#' @noRd
#'
#' @examples
#' usr <- .osm_details_user(user_id = "11725140")
#' usr
.osm_details_user <- function(user_id, format = c("R", "xml", "json")) {
  format <- match.arg(format)

  if (format == "json") {
    user_id <- paste0(user_id, ".json")
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "user", user_id)

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "xml")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- user_details_xml2DF(out)
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


## Details of multiple users: `GET /api/0.6/users?users=#id1,#id2,...,#idn` ----
# This API method was added in July 2018 ([https://github.com/openstreetmap/openstreetmap-website/commit/b4106383d99ccbf152d79b0f2c9deca95df9fb61 code]).
#
# You can get the details of a number of users via
#
### Response XML ----
#  GET /api/0.6/users?users=#id1,#id2,...,#idn
# this returns for example
# <syntaxhighlight lang="xml">
# <osm version="0.6" generator="OpenStreetMap server">
#   <user id="12023" display_name="jbpbis" account_created="2007-08-16T01:35:56Z">
#     <description></description>
#     <contributor-terms agreed="false"/>
#     <img href="http://www.gravatar.com/avatar/c8c86cd15f60ecca66ce2b10cb6b9a00.jpg?s=256&amp;d=http%3A%2F%2Fwww.openstreetmap.org%2Fassets%2Fusers%2Fimages%2Flarge-39c3a9dc4e778311af6b70ddcf447b58.png"/>
#     <roles>
#     </roles>
#     <changesets count="1"/>
#     <traces count="0"/>
#     <blocks>
#       <received count="0" active="0"/>
#     </blocks>
#   </user>
#   <user id="210447" display_name="siebh" account_created="2009-12-20T10:11:42Z">
#     <description></description>
#     <contributor-terms agreed="true"/>
#     <roles>
#     </roles>
#     <changesets count="267"/>
#     <traces count="1"/>
#     <blocks>
#       <received count="0" active="0"/>
#     </blocks>
#   </user>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/users.json?users=#id1,#id2,...,#idn
# <syntaxhighlight lang="json">
# {
#   "version": "0.6",
#   "generator": "OpenStreetMap server",
#   "users": [
#     {"user": {"id": 12023, "display_name": "jbpbis", "account_created": "2007-08-16T01:35:56Z", "description": "", "contributor_terms": {"agreed": False}, "roles": [], "changesets": {"count": 1}, "traces": {"count": 0}, "blocks": {"received": {"count": 0, "active": 0}}}},
#     {"user": {"id": 210447, "display_name": "siebh", "account_created": "2009-12-20T10:11:42Z", "description": "", "contributor_terms": {"agreed": True}, "roles": [], "changesets": {"count": 363}, "traces": {"count": 1}, "blocks": {"received": {"count": 0, "active": 0}}}}
#   ]
# }
# </syntaxhighlight>
#
# or an empty file if no user found for given identifier.
# Note: Since [https://github.com/openstreetmap/openstreetmap-website/pull/4203 Pull request 4203 (deployed on August 26 2023)], both XML and JSON based variants of the users endpoint will skip any non-existing/suspended/deleted users, rather than reporting a previously undocumented HTTP 404 error.

#' Details of multiple users
#'
#' @param user_ids The ids of the users to retrieve represented by a numeric or a character value (not the display
#'   names).
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#'
#' @return
#' For users not found, the result is empty. If `format = "R"`, returns a data frame with one user per row.
#'
#' ## `format = "xml"`
#'
#' Returns a [xml2::xml_document-class] with the following format:
#' ``` xml
#' <osm version="0.6" generator="OpenStreetMap server">
#'   <user id="12023" display_name="jbpbis" account_created="2007-08-16T01:35:56Z">
#'     <description></description>
#'     <contributor-terms agreed="false"/>
#'     <img href="http://www.gravatar.com/avatar/c8c86cd15f60ecca66ce2b10cb6b9a00.jpg?s=256&amp;d=http%3A%2F%2Fwww.openstreetmap.org%2Fassets%2Fusers%2Fimages%2Flarge-39c3a9dc4e778311af6b70ddcf447b58.png"/>
#'     <roles>
#'     </roles>
#'     <changesets count="1"/>
#'     <traces count="0"/>
#'     <blocks>
#'       <received count="0" active="0"/>
#'     </blocks>
#'   </user>
#'   <user id="210447" display_name="siebh" account_created="2009-12-20T10:11:42Z">
#'     <description></description>
#'     <contributor-terms agreed="true"/>
#'     <roles>
#'     </roles>
#'     <changesets count="267"/>
#'     <traces count="1"/>
#'     <blocks>
#'       <received count="0" active="0"/>
#'     </blocks>
#'   </user>
#' </osm>
#' ```
#'
#' ## `format = "json"`
#'
#' Returns a list with the following json structure:
#' ``` json
#' {
#'   "version": "0.6",
#'   "generator": "OpenStreetMap server",
#'   "users": [
#'     {"user": {"id": 12023, "display_name": "jbpbis", "account_created": "2007-08-16T01:35:56Z", "description": "", "contributor_terms": {"agreed": False}, "roles": [], "changesets": {"count": 1}, "traces": {"count": 0}, "blocks": {"received": {"count": 0, "active": 0}}}},
#'     {"user": {"id": 210447, "display_name": "siebh", "account_created": "2009-12-20T10:11:42Z", "description": "", "contributor_terms": {"agreed": True}, "roles": [], "changesets": {"count": 363}, "traces": {"count": 1}, "blocks": {"received": {"count": 0, "active": 0}}}}
#'   ]
#' }
#' ```
#'
# @family users' functions
#' @noRd
#'
#' @examples
#' usrs <- .osm_details_users(user_ids = c(1, 24, 44, 45, 46, 48, 49, 50))
#' usrs
.osm_details_users <- function(user_ids, format = c("R", "xml", "json")) {
  format <- match.arg(format)

  if (format == "json") {
    ext <- "users.json"
  } else {
    ext <- "users"
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, ext)
  req <- httr2::req_url_query(req, users = paste(user_ids, collapse = ","))

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "xml")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- user_details_xml2DF(out)
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


## Details of the logged-in user: `GET /api/0.6/user/details` ----
# You can get the home location and the displayname of the user, by using
#
### Response XML ----
#  GET /api/0.6/user/details
# this returns an XML document of the from
# <syntaxhighlight lang="xml">
# <osm version="0.6" generator="OpenStreetMap server">
#   <user display_name="Max Muster" account_created="2006-07-21T19:28:26Z" id="1234">
#     <contributor-terms agreed="true" pd="true"/>
#     <img href="https://www.openstreetmap.org/attachments/users/images/000/000/1234/original/someLongURLOrOther.JPG"/>
#     <roles></roles>
#     <changesets count="4182"/>
#     <traces count="513"/>
#     <blocks>
#       <received count="0" active="0"/>
#     </blocks>
#     <home lat="49.4733718952806" lon="8.89285988577866" zoom="3"/>
#     <description>The description of your profile</description>
#     <languages>
#       <lang>de-DE</lang>
#       <lang>de</lang>
#       <lang>en-US</lang>
#       <lang>en</lang>
#     </languages>
#     <messages>
#       <received count="1" unread="0"/>
#       <sent count="0"/>
#     </messages>
#   </user>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/user/details.json
# this returns an JSON document of the from
# <syntaxhighlight lang="json">
# {
#   "version": "0.6",
#   "generator": "OpenStreetMap server",
#   "user": {
#     "id": 1234,
#     "display_name": "Max Muster",
#     "account_created": "2006-07-21T19:28:26Z",
#     "description": "The description of your profile",
#     "contributor_terms": {"agreed": True, "pd": True},
#     "img": {"href": "https://www.openstreetmap.org/attachments/users/images/000/000/1234/original/someLongURLOrOther.JPG"},
#     "roles": [],
#     "changesets": {"count": 4182},
#     "traces": {"count": 513},
#     "blocks": {"received": {"count": 0, "active": 0}},
#     "home": {"lat": 49.4733718952806, "lon": 8.89285988577866, "zoom": 3},
#     "languages": ["de-DE", "de", "en-US", "en"],
#     "messages": {"received": {"count": 1, "unread": 0},
#     "sent": {"count": 0}}
#   }
# }
# </syntaxhighlight>
#
# The messages section has been available since mid-2013. It provides a basic counts of received, sent, and unread osm [[Web front end#User messaging|messages]].

#' Details of the logged-in user
#'
#' You can get the home location, the display name of the user and other details.
#'
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#'
#' @return
#' If `format = "R"`, returns a list with the user details.
#'
#' ## `format = "xml"`
#'
#' Returns a [xml2::xml_document-class] with the following format:
#' ``` xml
#' <osm version="0.6" generator="OpenStreetMap server">
#'   <user display_name="Max Muster" account_created="2006-07-21T19:28:26Z" id="1234">
#'     <contributor-terms agreed="true" pd="true"/>
#'     <img href="https://www.openstreetmap.org/attachments/users/images/000/000/1234/original/someLongURLOrOther.JPG"/>
#'     <roles></roles>
#'     <changesets count="4182"/>
#'     <traces count="513"/>
#'     <blocks>
#'       <received count="0" active="0"/>
#'     </blocks>
#'     <home lat="49.4733718952806" lon="8.89285988577866" zoom="3"/>
#'     <description>The description of your profile</description>
#'     <languages>
#'       <lang>de-DE</lang>
#'       <lang>de</lang>
#'       <lang>en-US</lang>
#'       <lang>en</lang>
#'     </languages>
#'     <messages>
#'       <received count="1" unread="0"/>
#'       <sent count="0"/>
#'     </messages>
#'   </user>
#' </osm>
#' ```
#'
#' ## `format = "json"`
#'
#' ``` json
#' {
#'   "version": "0.6",
#'   "generator": "OpenStreetMap server",
#'   "user": {
#'     "id": 1234,
#'     "display_name": "Max Muster",
#'     "account_created": "2006-07-21T19:28:26Z",
#'     "description": "The description of your profile",
#'     "contributor_terms": {"agreed": True, "pd": True},
#'     "img": {"href": "https://www.openstreetmap.org/attachments/users/images/000/000/1234/original/someLongURLOrOther.JPG"},
#'     "roles": [],
#'     "changesets": {"count": 4182},
#'     "traces": {"count": 513},
#'     "blocks": {"received": {"count": 0, "active": 0}},
#'     "home": {"lat": 49.4733718952806, "lon": 8.89285988577866, "zoom": 3},
#'     "languages": ["de-DE", "de", "en-US", "en"],
#'     "messages": {"received": {"count": 1, "unread": 0},
#'     "sent": {"count": 0}}
#'   }
#' }
#' ```
#'
#' @family users' functions
#' @export
#'
#' @examples
#' \dontrun{
#' usr_details <- osm_details_logged_user()
#' usr_details
#' }
osm_details_logged_user <- function(format = c("R", "xml", "json")) {
  format <- match.arg(format)

  if (format == "json") {
    ext <- "details.json"
  } else {
    ext <- "details"
  }

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "user", ext)

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "xml")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- logged_user_details_xml2list(out)
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


## Preferences of the logged-in user: `GET|PUT|DELETE /api/0.6/user/preferences` ----
# The OSM server supports storing arbitrary user preferences. This can be used by editors, for example, to offer the same configuration wherever the user logs in, instead of a locally-stored configuration. For an overview of applications using the preferences-API and which key-schemes they use, see [[preferences|this wiki page]].
#
# You can retrieve the list of current preferences using
#
### Response XML ----
#  GET /api/0.6/user/preferences
# this returns an XML document of the form
# <syntaxhighlight lang="xml">
# <osm version="0.6" generator="OpenStreetMap server">
#   <preferences>
#     <preference k="somekey" v="somevalue" />
#     ...
#   </preferences>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/user/preferences.json
# this returns an JSON document of the form
# <syntaxhighlight lang="json">
# {
#   "version": "0.6",
#   "generator": "OpenStreetMap server",
#   "preferences": {"somekey": "somevalue, ...}
# }
# </syntaxhighlight>
#
#  PUT /api/0.6/user/preferences
#
# The same structure in the body of the a PUT will upload preferences. All existing preferences are replaced by the newly uploaded set.
#
#  GET /api/0.6/user/preferences/[your_key] (without the brackets)
#
# Returns a string with that preference's value.
#
#  PUT /api/0.6/user/preferences/[your_key] (without the brackets)
#
# Will set a single preference's value to a string passed as the content of the request.
#
#  PUT /api/0.6/user/preferences/[your_key]
#
# in this instance, the payload of the request should only contain the value of the preference, i.e. not XML formatted.
#
# The PUT call returns HTTP response code 406 (not acceptable) if the same key occurs more than once, and code 413 (request entity too large) if you try to upload more than 150 preferences at once. The sizes of the key and value are limited to 255 characters.
#
# A single preference entry can be deleted with
#
#  DELETE /api/0.6/user/preferences/[your_key]

#' Get or set preferences for the logged-in user
#'
#' @param key Returns a string with this preference's value. If missing, return all preferences.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`. Only relevant when `key` is
#'   missing.
#'
#' @details
#' The sizes of the key and value are limited to 255 characters.
#'
#' The OSM server supports storing arbitrary user preferences. This can be used by editors, for example, to offer the
#' same configuration wherever the user logs in, instead of a locally-stored configuration. For an overview of
#' applications using the preferences-API and which key-schemes they use, see
#' [this wiki page](https://wiki.openstreetmap.org/wiki/Preferences).
#'
#' @return
#' If `format = "R"`, returns a data frame with `key` and `value` columns of the user preferences.
#'
#' ## `format = "xml"`
#' Returns a [xml2::xml_document-class] with the following format:
#' ``` xml
#' <osm version="0.6" generator="OpenStreetMap server">
#'   <preferences>
#'     <preference k="somekey" v="somevalue" />
#'     ...
#'   </preferences>
#' </osm>
#' ```
#'
#' ## `format = "json"`
#' Returns a list with the following json structure:
#' ``` json
#' {
#'   "version": "0.6",
#'   "generator": "OpenStreetMap server",
#'   "preferences": {"somekey": "somevalue, ...}
#' }
#' ```
#' @family users' functions
#' @rdname osm_preferences_user
#' @export
#'
#' @examples
#' \dontrun{
#' prefs_ori <- osm_get_preferences_user()
#' prefs_ori
#'
#'
#' osm_set_preferences_user(key = "osmapiR-test", value = "good!")
#' osm_get_preferences_user(key = "osmapiR-test")
#'
#' osm_set_preferences_user(key = "osmapiR-test", value = NULL) # Delete pref
#'
#' ## Restore all preferences
#' osm_set_preferences_user(all_prefs = prefs_ori)
#' }
osm_get_preferences_user <- function(key, format = c("R", "xml", "json")) {
  format <- match.arg(format)

  if (format == "json") {
    ext <- "preferences.json"
  } else {
    ext <- "preferences"
  }

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "GET")

  if (missing(key)) {
    req <- httr2::req_url_path_append(req, "user", ext)
  } else {
    req <- httr2::req_url_path_append(req, "user", "preferences", key)
  }

  resp <- httr2::req_perform(req)

  if (!missing(key)) {
    out <- httr2::resp_body_string(resp)
    out <- enc2utf8(out)
  } else if (format %in% c("R", "xml")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- user_preferences_xml2DF(out)
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


#' @rdname osm_preferences_user
#' @param value A string with the preference value to set for `key`. If `NULL`, deletes the `key` preference.
#' @param all_prefs A `data.frame`, `xml_document` or a json list following the format returned by
#'   `osm_get_preferences_user()`. Also, a path to an xml file describing the user preferences.
#'    **All** existing preferences are replaced by the newly uploaded set.
#'
#' @return ## Set preferences
#' Nothing is returned upon successful setting of user preferences.
#' @export
osm_set_preferences_user <- function(key, value, all_prefs) {
  if ((!missing(key) || !missing(value)) && !missing(all_prefs)) {
    stop("`key` & `value`, or `all_prefs` must be provided but not all at the same time.")
  }

  rm_path <- FALSE
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "PUT")


  if (!missing(all_prefs)) { # set all preferences
    req <- httr2::req_url_path_append(req, "user", "preferences")

    if (is.character(all_prefs)) {
      if (file.exists(all_prefs)) {
        path <- all_prefs
      } else {
        stop(
          "`all_prefs` is interpreted as a path to an xml file with the preferences, but it can't be found (",
          all_prefs, ")."
        )
      }
    } else {
      if (inherits(all_prefs, "xml_document")) {
        xml <- all_prefs
      } else if (inherits(all_prefs, "data.frame")) {
        xml <- user_preferences_DF2xml(all_prefs)
      } else if (inherits(all_prefs, "list") && "preferences" %in% names(all_prefs)) {
        xml <- user_preferences_json2xml(all_prefs)
      } else {
        stop(
          "`all_prefs` must be a path to a xml file with the preferences, a `xml_document`, a json list or a data ",
          "frame with columns `key` and `value` as returned by osm_get_preferences_user()."
        )
      }

      path <- tempfile(fileext = ".xml")
      xml2::write_xml(xml, path)
      rm_path <- TRUE
    }

    req <- httr2::req_body_file(req, path = path)
  } else { # set a single preference
    if (missing(key)) {
      stop("`key` is missing with no defaults.")
    }
    if (missing(value)) {
      stop("`value` is missing with no defaults.")
    }

    req <- httr2::req_url_path_append(req, "user", "preferences", key)

    if (is.null(value)) {
      req <- httr2::req_method(req, "DELETE")
    } else {
      req <- httr2::req_body_raw(req, body = value)
    }
  }

  httr2::req_perform(req)

  if (rm_path) {
    file.remove(path)
  }

  invisible()
}
