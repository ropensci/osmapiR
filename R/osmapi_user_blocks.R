# User Blocks

## Create: `POST /api/0.6/user_blocks` ----
#
### Parameters ----
#
# {| class="wikitable"
# |-
# ! Parameter
# ! Description
# ! Allowed values
# ! Default value
# |-
# | <code>user</code>
# | Blocked user id
# | Integer; User id
# | No default, needs to be specified
# |-
# | <code>reason</code>
# | Reason for block shown to the blocked user
# | Markdown text
# | No default, needs to be specified
# |-
# | <code>period</code>
# | Block duration in hours
# | Integer between 0 and maximum block period, currently 87660
# | No default, needs to be specified
# |-
# | <code>needs_view</code>
# | Whether the user is required to view the block page for the block to be lifted
# | <code>true</code>
# | None, optional parameter
# |}
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : When any of the required parameters is missing or has invalid value
# ; HTTP status code 404 (Not found)
# : When blocked user is not found

#' Create a user block
#'
#' @param user_id Blocked user id.
#' @param reason Reason for block shown to the blocked user (markdown text).
#' @param period Block duration in hours between 0 and maximum block period, currently 87660.
#' @param needs_view If `TRUE`, the user is required to view the block page for the block to be lifted.
#'   Default to `FALSE`.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#'
#' @returns Same format as [`osm_get_user_blocks()`]
#'
#' @family user blocks' functions
#' @family functions for moderators
#' @export
#'
#' @examples
#' \dontrun{
#' set_osmapi_connection("testing") # use the testing server
#'
#' my_user_id <- osm_details_logged_user()$user["id"]
#' osm_create_user_block(user_id = my_user_id, reason = "Not really evil, just testing.", period = 0)
#' }
osm_create_user_block <- function(user_id, reason, period, needs_view = FALSE, format = c("R", "xml", "json")) {
  format <- match.arg(format)

  if (format == "json") {
    ext <- "user_blocks.json"
  } else {
    ext <- "user_blocks"
  }

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, ext)
  req <- httr2::req_url_query(req, user = user_id, reason = reason, period = period)
  if (needs_view) {
    req <- httr2::req_url_query(req, needs_view = "true")
  }

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "xml")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- user_blocks_xml2DF(out)
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


## Read: `GET /api/0.6/user_blocks/#id` ----
#
### Response XML ----
#  GET /api/0.6/user_blocks/#id
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="http://www.openstreetmap.org/copyright" license="http://opendatacommons.org/licenses/odbl/1-0/">
#   <user_block id="96" created_at="2025-01-21T23:23:50Z" updated_at="2025-01-21T23:24:16Z" ends_at="2025-01-21T23:24:16Z" needs_view="false">
#     <user uid="3" user="fakeuser1"/>
#     <creator uid="5" user="fakemod1"/>
#     <revoker uid="5" user="fakemod1"/>
#     <reason>reason text
#
# more reason text</reason>
#   </user_block>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/user_blocks/#id.json
# <syntaxhighlight lang="json">
# {
#   "version":"0.6",
#   "generator":"OpenStreetMap server",
#   "copyright":"OpenStreetMap and contributors",
#   "attribution":"http://www.openstreetmap.org/copyright",
#   "license":"http://opendatacommons.org/licenses/odbl/1-0/",
#   "user_block":{
#     "id":96,
#     "created_at":"2025-01-21T23:23:50Z",
#     "updated_at":"2025-01-21T23:24:16Z",
#     "ends_at":"2025-01-21T23:24:16Z",
#     "needs_view":false,
#     "user":{"uid":3,"user":"fakeuser1"},
#     "creator":{"uid":5,"user":"fakemod1"},
#     "revoker":{"uid":5,"user":"fakemod1"},
#     "reason":"reason text\r\n\r\nmore reason text"
#   }
# }
# </syntaxhighlight>

#' Read user block
#'
#' @param user_block_id The id of the user block to retrieve represented by a numeric or a character value.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#'
#' @returns
#' If `format = "R"`, returns a data frame with one row with the details of the block.
#'
#' ## `format = "xml"`
#' Returns a [xml2::xml_document-class] with the following format:
#' ``` xml
#' <?xml version="1.0" encoding="UTF-8"?>
#' <osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="http://www.openstreetmap.org/copyright" license="http://opendatacommons.org/licenses/odbl/1-0/">
#'   <user_block id="96" created_at="2025-01-21T23:23:50Z" updated_at="2025-01-21T23:24:16Z" ends_at="2025-01-21T23:24:16Z" needs_view="false">
#'     <user uid="3" user="fakeuser1"/>
#'     <creator uid="5" user="fakemod1"/>
#'     <revoker uid="5" user="fakemod1"/>
#'     <reason>reason text
#'
#' more reason text</reason>
#'   </user_block>
#' </osm>
#' ```
#'
#' ## `format = "json"`
#' Returns a list with the following json structure:
#' ``` json
#' {
#'   "version":"0.6",
#'   "generator":"OpenStreetMap server",
#'   "copyright":"OpenStreetMap and contributors",
#'   "attribution":"http://www.openstreetmap.org/copyright",
#'   "license":"http://opendatacommons.org/licenses/odbl/1-0/",
#'   "user_block":{
#'     "id":96,
#'     "created_at":"2025-01-21T23:23:50Z",
#'     "updated_at":"2025-01-21T23:24:16Z",
#'     "ends_at":"2025-01-21T23:24:16Z",
#'     "needs_view":false,
#'     "user":{"uid":3,"user":"fakeuser1"},
#'     "creator":{"uid":5,"user":"fakemod1"},
#'     "revoker":{"uid":5,"user":"fakemod1"},
#'     "reason":"reason text\r\n\r\nmore reason text"
#'   }
#' }
#' ```
#'
# @family user blocks' functions
#' @noRd
#'
#' @examples
#' .osm_read_user_block(1)
.osm_read_user_block <- function(user_block_id, format = c("R", "xml", "json")) {
  format <- match.arg(format)

  if (format == "json") {
    user_block_id <- paste0(user_block_id, ".json")
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "user_blocks", user_block_id)

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "xml")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- user_blocks_xml2DF(out)
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


## List active blocks: `GET /api/0.6/user/blocks/active` ----
#
# Allows the applications to check if the currently authorized user is blocked.
# This endpoint is accessible even with an active block, unlike some other endpoints requiring authorization.
#
### Response XML ----
#  GET /user/blocks/active
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="http://www.openstreetmap.org/copyright" license="http://opendatacommons.org/licenses/odbl/1-0/">
#   <user_block id="101" created_at="2025-02-22T02:11:55Z" updated_at="2025-02-22T02:11:55Z" ends_at="2025-02-22T03:11:55Z" needs_view="true">
#     <user uid="5" user="fakemod1"/>
#     <creator uid="115" user="fakemod2"/>
#   </user_block>
#   <user_block id="100" created_at="2025-02-22T02:11:10Z" updated_at="2025-02-22T02:11:10Z" ends_at="2025-02-22T02:11:10Z" needs_view="true">
#     <user uid="5" user="fakemod1"/>
#     <creator uid="115" user="fakemod2"/>
#   </user_block>
#   ...
# </osm>
# </syntaxhighlight>
#
# Empty <osm> element indicates no active blocks.
#
### Response JSON ----
# GET /user/blocks/active.json
# <syntaxhighlight lang="json">
# {
#   "version":"0.6","generator":"OpenStreetMap server","copyright":"OpenStreetMap and contributors","attribution":"http://www.openstreetmap.org/copyright","license":"http://opendatacommons.org/licenses/odbl/1-0/",
#   "user_blocks":[
#     {
#       "id":101,
#       "created_at":"2025-02-22T02:11:55Z",
#       "updated_at":"2025-02-22T02:11:55Z",
#       "ends_at":"2025-02-22T03:11:55Z",
#       "needs_view":true,
#       "user":{"uid":5,"user":"fakemod1"},
#       "creator":{"uid":115,"user":"fakemod2"}
#     },
#     {
#       "id":100,
#       "created_at":"2025-02-22T02:11:10Z",
#       "updated_at":"2025-02-22T02:11:10Z",
#       "ends_at":"2025-02-22T02:11:10Z",
#       "needs_view":true,
#       "user":{"uid":5,"user":"fakemod1"},
#       "creator":{"uid":115,"user":"fakemod2"}
#     },
#     ...
#   ]
# }
# </syntaxhighlight>
#
# Empty <code>user_blocks</code> array indicates no active blocks.

#' List active blocks
#'
#' Allows to check if the currently authorized user is blocked.
#'
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#'
#' @details
#' This endpoint is accessible even with an active block, unlike some other endpoints requiring authorization.
#'
#' @returns
#' If `format = "R"`, returns a data frame with one row per block. No rows, no blocks.
#'
#' ## `format = "xml"`
#' Returns a [xml2::xml_document-class] with the following format:
#' ``` xml
#' <?xml version="1.0" encoding="UTF-8"?>
#' <osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="http://www.openstreetmap.org/copyright" license="http://opendatacommons.org/licenses/odbl/1-0/">
#'   <user_block id="101" created_at="2025-02-22T02:11:55Z" updated_at="2025-02-22T02:11:55Z" ends_at="2025-02-22T03:11:55Z" needs_view="true">
#'     <user uid="5" user="fakemod1"/>
#'     <creator uid="115" user="fakemod2"/>
#'   </user_block>
#'   <user_block id="100" created_at="2025-02-22T02:11:10Z" updated_at="2025-02-22T02:11:10Z" ends_at="2025-02-22T02:11:10Z" needs_view="true">
#'     <user uid="5" user="fakemod1"/>
#'     <creator uid="115" user="fakemod2"/>
#'   </user_block>
#'   ...
#' </osm>
#' ```
#'
#' Empty `<osm>` element indicates no active blocks.
#
#' ## `format = "json"`
#' Returns a list with the following json structure:
#' ``` json
#' {
#'   "version":"0.6","generator":"OpenStreetMap server","copyright":"OpenStreetMap and contributors","attribution":"http://www.openstreetmap.org/copyright","license":"http://opendatacommons.org/licenses/odbl/1-0/",
#'   "user_blocks":[
#'     {
#'       "id":101,
#'       "created_at":"2025-02-22T02:11:55Z",
#'       "updated_at":"2025-02-22T02:11:55Z",
#'       "ends_at":"2025-02-22T03:11:55Z",
#'       "needs_view":true,
#'       "user":{"uid":5,"user":"fakemod1"},
#'       "creator":{"uid":115,"user":"fakemod2"}
#'     },
#'     {
#'       "id":100,
#'       "created_at":"2025-02-22T02:11:10Z",
#'       "updated_at":"2025-02-22T02:11:10Z",
#'       "ends_at":"2025-02-22T02:11:10Z",
#'       "needs_view":true,
#'       "user":{"uid":5,"user":"fakemod1"},
#'       "creator":{"uid":115,"user":"fakemod2"}
#'     },
#'     ...
#'   ]
#' }
#' ```
#'
#' @family user blocks' functions
#' @export
#'
#' @examples
#' \dontrun{
#' osm_list_active_user_blocks()
#' }
osm_list_active_user_blocks <- function(format = c("R", "xml", "json")) {
  format <- match.arg(format)

  if (format == "json") {
    ext <- "active.json"
  } else {
    ext <- "active"
  }

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "user", "blocks", ext)

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "xml")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- user_blocks_xml2DF(out)
      out[, c("revoker", "revoker_uid", "reason")] <- NULL
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}
