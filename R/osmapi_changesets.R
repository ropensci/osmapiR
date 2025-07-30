## Changesets
# To make it easier to identify related changes the concept of changesets is introduced. Every modification of the standard OSM elements has to reference an open changeset. A changeset may contain tags just like the other elements. A recommended tag for changesets is the key {{key|comment}} with a short human readable description of the changes being made in that changeset, similar to a commit message in a revision control system. A new changeset can be opened at any time and a changeset may be referenced from multiple API calls. Because of this it can be closed manually as the server can't know when one changeset ends and another should begin. To avoid stale open changesets a mechanism is implemented to automatically close changesets upon one of the following three conditions:
# * 10,000 edits on a single changeset (see the [[#Capabilities: GET /api/capabilities|capabilities endpoint]] for specific limits)
# * The changeset has been open for more than 24 hours
# * There have been no changes/API calls related to a changeset in 1 hour (i.e. idle timeout)
#
# Note that some older changesets may contain slightly more than 10k (or previously 50k) changes due to some glitches in the API.
#
# Changesets are specifically ''not'' atomic - elements added within a changeset will be visible to other users before the changeset is closed. Given how many changes might be uploaded in one step it's not feasible. Instead optimistic locking is used as described above. Anything submitted to the server in a single request will be considered atomically. To achieve transactionality for multiple changes there is the new ''diff upload'' API call.
#
# Changesets facilitate the implementation of rollbacks. By providing insight into the changes committed by a single person it becomes easier to identify the changes made, rather than just rolling back a whole region. Direct support for rollback will not be in the API, instead they will be a form of reverse merging, where client can download the changeset, examine the changes and then manipulate the API to obtain the desired results. Rolling back a changeset can be be an extremely complex process especially if the rollback conflicts with other changes made in the mean time; we expect (hope) that in time, expert applications will be created that make rollback on various levels available to the average user.
#
# To support easier usage, the server stores a bounding box for each changeset and allows users to query changesets in an area. This will be calculated by the server, since it needs to look up the relevant nodes anyway. Client should note that if people make many small changes in a large area they will be easily matched. In this case clients should examine the changeset directly to see if it truly overlaps.
#
# It is not possible to delete changesets at the moment, even if they don't contain any changes. The server may at a later time delete changesets which are closed and which do not contain any changes. This is not yet implemented.


## Bounding box computation ----
#
# This is how the API computes the bounding box associated with a changeset:
#
# * Nodes: Any change to a node, including deletion, adds the node's old and new location to the bbox.
# * Ways: Any change to a way, including deletion, adds all of the way's nodes to the bbox.
# * Relations:
# ** adding or removing nodes or ways from a relation causes them to be added to the changeset bounding box.
# ** adding a relation as a member or changing tag values causes all node and way members to be added to the bounding box.
# ** this is similar to how the map call does things and is reasonable on the assumption that adding or removing members doesn't materially change the rest of the relation.
#
# As an optimisation the server will create a buffer slightly larger than the objects to avoid having to update the bounding box too often. Thus a changeset may have a different bounding box than its reversion, and the distance between bounding box and the next node may not be constant for all four directions.


## Create: `PUT /api/0.6/changeset/create` ----
#
# The payload of a changeset creation request is the metadata of this changeset. The body of the request has to include one or more `changeset` elements, which optionally include an arbitrary number of tags (such as 'comment', 'created_by", ...). All `changeset` elements need to be enclosed in an `osm` element.
# <syntaxhighlight lang="xml">
# <osm>
#   <changeset>
#     <tag k="created_by" v="JOSM 1.61"/>
#     <tag k="comment" v="Just adding some streetnames"/>
#     ...
#   </changeset>
#   ...
# </osm>
# </syntaxhighlight>
# If there are multiple `changeset` elements in the XML the tags from all of them are used, later ones overriding the earlier ones in case of duplicate keys.
#
### Response ----
# The ID of the newly created changeset with a content type of `text/plain`
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : When there are errors parsing the XML
# ; HTTP status code 405 (Method Not Allowed)
# : If the request is not a HTTP PUT request
#
### Notes ----
# Any number of possibly editor-specific, tags are allowed. An editor might, for example, automatically include information about which background image was used, or even a bit of internal state information that will make it easier to revisit the changeset with the same editor later, etc.
#
# Clients ''should'' include a {{tag|created_by}} tag. Clients are advised to make sure that a {{tag|comment}} is present, which the user has entered. It is optional at the moment but this ''might'' change in later API versions. Clients ''should not'' automatically generate the comment tag, as this tag is for the end-user to describe their changes. Clients ''may'' add any other tags as they see fit.

#' Create, update, or close a changeset
#'
#' @describeIn osm_create_changeset Open a new changeset for editing.
#'
#' @param comment Tag comment is mandatory.
#' @param ... Arbitrary tags to add to the changeset as named parameters (key = "value").
#' @param created_by Tag with the client data. By default, `osmapiR x.y.z`.
#' @param verbose If `TRUE`, print the tags of the new changeset.
#'
#' @details
#' See <https://wiki.openstreetmap.org/wiki/Changeset> for details and the most common changeset's tags.
#'
#'
#' @return The ID of the newly created changeset or a `data.frame` inheriting `osmapi_changesets` with the details of
#'   the updated changeset.
#' @family edit changeset's functions
#' @export
#'
#' @examples
#' \dontrun{
#' set_osmapi_connection("testing") # use the testing server
#'
#' chset_id <- osm_create_changeset(
#'   comment = "Describe the changeset",
#'   source = "GPS;survey",
#'   hashtags = "#testing;#osmapiR"
#' )
#'
#' chaset <- osm_get_changesets(changeset_id = chset_id)
#' chaset
#'
#' upd_chaset <- osm_update_changeset(
#'   changeset_id = chset_id,
#'   comment = "Improved description of the changeset",
#'   hashtags = "#testing;#osmapiR"
#' )
#' upd_chaset
#' }
osm_create_changeset <- function(comment, ...,
                                 created_by = paste("osmapiR", getOption("osmapir.osmapir_version")), verbose = FALSE) {
  tags <- list(...)

  if (missing(comment)) {
    stop("A descriptive comment of the changeset is mandatory.")
  }

  tags <- c(list(comment = comment, created_by = created_by), tags)

  xml <- changeset_create_xml(tags)
  path <- tempfile(fileext = ".xml")
  xml2::write_xml(xml, path)

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "PUT")
  req <- httr2::req_url_path_append(req, "changeset", "create")
  req <- httr2::req_body_file(req, path = path)

  resp <- httr2::req_perform(req)
  out <- httr2::resp_body_string(resp)

  if (verbose) {
    df_msg <- data.frame(key = names(tags), value = vapply(tags, I, FUN.VALUE = character(1L), USE.NAMES = FALSE))

    message(
      "New changeset with id = ", out, ", and the following tags:\n",
      paste(utils::capture.output(print(df_msg)), collapse = "\n")
    )
  }

  file.remove(path)

  return(out)
}


## Read: `GET /api/0.6/changeset/#id*?include_discussion='true'*` ----
# Returns the changeset with the given `id` in OSM-XML format.
#
### Parameters ----
# ; id
# : The id of the changeset to retrieve
# ; include_discussion
# : Indicates whether the result should contain the changeset discussion or not. If this parameter is set to anything, the discussion is returned. If it is empty or omitted, the discussion will not be in the result.
#
### Response XML ----
# Returns the single changeset element containing the changeset tags with a content type of `text/xml`
#  GET /api/0.6/changeset/#id?include_discussion=true
# <syntaxhighlight lang="xml">
#
# <osm version="0.6" generator="CGImap 0.9.3 (987909 spike-08.openstreetmap.org)" copyright="OpenStreetMap and contributors" attribution="http://www.openstreetmap.org/copyright" license="http://opendatacommons.org/licenses/odbl/1-0/">
#   <changeset id="10" created_at="2008-11-08T19:07:39+01:00" open="true" user="fred" uid="123" min_lon="7.0191821" min_lat="49.2785426" max_lon="7.0197485" max_lat="49.2793101" comments_count="3" changes_count="10">
#     <tag k="created_by" v="JOSM 1.61"/>
#     <tag k="comment" v="Just adding some streetnames"/>
#     ...
#     <discussion>
#       <comment id="1234" date="2015-01-01T18:56:48Z" uid="1841" user="metaodi">
#         <text>Did you verify those street names?</text>
#       </comment>
#       <comment id="5678" date="2015-01-01T18:58:03Z" uid="123" user="fred">
#         <text>sure!</text>
#       </comment>
#       ...
#     </discussion>
#   </changeset>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
# Returns the single changeset element containing the changeset tags with a content type of `application/json`
#  GET /api/0.6/changeset/#id.json?include_discussion=true
# Please note that the JSON format has changed on August 25, 2024 with the release of openstreetmap-cgimap 2.0.0, to align it with the existing Rails format.
# <syntaxhighlight lang="json">
#   {
#     "version": "0.6",
#     "generator": "openstreetmap-cgimap 2.0.0 (4003517 spike-08.openstreetmap.org)",
#     "copyright": "OpenStreetMap and contributors",
#     "attribution": "http://www.openstreetmap.org/copyright",
#     "license": "http://opendatacommons.org/licenses/odbl/1-0/",
#     "changeset": {
#       "id": 10,
#       "created_at": "2005-05-01T16:09:37Z",
#       "open": false,
#       "comments_count": 1,
#       "changes_count": 10,
#       "closed_at": "2005-05-01T17:16:44Z",
#       "min_lat": 59.9513092,
#       "min_lon": 10.7719727,
#       "max_lat": 59.9561501,
#       "max_lon": 10.7994537,
#       "uid": 24,
#       "user": "Petter Reinholdtsen",
#       "comments": [
#         {
#           "id": 836447,
#           "visible": true,
#           "date": "2022-03-22T20:58:30Z",
#           "uid": 15079200,
#           "user": "Ethan White of Cheriton",
#           "text": "wow no one have said anything here 3/22/2022\n"
#         }
#       ]
#     }
#   }
# </syntaxhighlight>
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : When no changeset with the given id could be found
#
### Notes ----
# * The `uid` might not be available for changesets auto generated by the API v0.5 to API v0.6 transition?
# * The bounding box attributes will be missing for an empty changeset.
# * The changeset bounding box is a rectangle that contains the bounding boxes of all objects changed in this changeset. It is not necessarily the smallest possible rectangle that does so.
# * This API call only returns information about the changeset itself but not the actual changes made to elements in this changeset. To access this information use the ''download'' API call.

#' Read a changeset
#'
#' Returns the changeset with the given `changeset_id`.
#'
#' @param changeset_id The id of the changeset to retrieve represented by a numeric or a character value.
#' @param include_discussion Indicates whether the result should contain the changeset discussion or not.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the changesets are saved in a single list column `tags`
#'   containing a `data.frame` for each changeset with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
#'
#' @details
#' * The `uid` might not be available for changesets auto generated by the API v0.5 to API v0.6 transition
#' * The bounding box attributes will be missing for an empty changeset.
#' * The changeset bounding box is a rectangle that contains the bounding boxes of all objects changed in this
#'   changeset. It is not necessarily the smallest possible rectangle that does so.
#' * This API call only returns information about the changeset itself but not the actual changes made to elements in
#'   this changeset. To access this information use [osm_download_changeset()].
#'
#' @return
#' If `format = "R"`, returns a data frame with one OSM changeset per row.
#'
#' ## `format = "xml"`
#' Returns a [xml2::xml_document-class] with the following format:
#' ``` xml
#' <osm version="0.6" generator="CGImap 0.9.3 (987909 spike-08.openstreetmap.org)" copyright="OpenStreetMap and contributors" attribution="http://www.openstreetmap.org/copyright" license="http://opendatacommons.org/licenses/odbl/1-0/">
#'   <changeset id="10" created_at="2008-11-08T19:07:39+01:00" open="true" user="fred" uid="123" min_lon="7.0191821" min_lat="49.2785426" max_lon="7.0197485" max_lat="49.2793101" comments_count="3" changes_count="10">
#'     <tag k="created_by" v="JOSM 1.61"/>
#'     <tag k="comment" v="Just adding some streetnames"/>
#'     ...
#'     <discussion>
#'       <comment id="1234" date="2015-01-01T18:56:48Z" uid="1841" user="metaodi">
#'         <text>Did you verify those street names?</text>
#'       </comment>
#'       <comment id="5678" date="2015-01-01T18:58:03Z" uid="123" user="fred">
#'         <text>sure!</text>
#'       </comment>
#'       ...
#'     </discussion>
#'   </changeset>
#' </osm>
#' ```
#'
#' ## `format = "json"`
#' *Please note that the JSON format has changed on August 25, 2024 with the release of openstreetmap-cgimap 2.0.0, to*
#' *align it with the existing Rails format.*
#'
#' Returns a list with the following json structure:
#' ``` json
#' {
#'   "version": "0.6",
#'   "generator": "openstreetmap-cgimap 2.0.0 (4003517 spike-08.openstreetmap.org)",
#'   "copyright": "OpenStreetMap and contributors",
#'   "attribution": "http://www.openstreetmap.org/copyright",
#'   "license": "http://opendatacommons.org/licenses/odbl/1-0/",
#'   "changeset": {
#'     "id": 10,
#'     "created_at": "2005-05-01T16:09:37Z",
#'     "open": false,
#'     "comments_count": 1,
#'     "changes_count": 10,
#'     "closed_at": "2005-05-01T17:16:44Z",
#'     "min_lat": 59.9513092,
#'     "min_lon": 10.7719727,
#'     "max_lat": 59.9561501,
#'     "max_lon": 10.7994537,
#'     "uid": 24,
#'     "user": "Petter Reinholdtsen",
#'     "comments": [
#'       {
#'         "id": 836447,
#'         "visible": true,
#'         "date": "2022-03-22T20:58:30Z",
#'         "uid": 15079200,
#'         "user": "Ethan White of Cheriton",
#'         "text": "wow no one have said anything here 3/22/2022\n"
#'       }
#'     ]
#'   }
#' }
#' ```
#'
# @family get changesets' functions
#' @noRd
#'
#' @examples
#' chaset <- .osm_read_changeset(changeset_id = 137595351, include_discussion = TRUE)
#' chaset
#' chaset$discussion
.osm_read_changeset <- function(changeset_id, include_discussion = FALSE,
                                format = c("R", "xml", "json"), tags_in_columns = FALSE) {
  format <- match.arg(format)

  if (format == "json") {
    changeset_id <- paste0(changeset_id, ".json")
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")

  req <- httr2::req_url_path_append(req, "changeset", changeset_id)
  if (include_discussion) {
    req <- httr2::req_url_query(req, include_discussion = I("'true'"))
  }

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "xml")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- changeset_xml2DF(out, tags_in_columns = tags_in_columns)
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


## Update: `PUT /api/0.6/changeset/#id` ----
# For updating tags on the changeset, e.g. changeset {{tag|comment|foo}}.
#
# Payload should be an OSM document containing the new version of a single changeset. Bounding box, update time and other attributes are ignored and cannot be updated by this method. Only those tags provided in this call remain in the changeset object. For updating the bounding box see the ''expand_bbox'' method.
# <syntaxhighlight lang="xml">
# <osm>
#   <changeset>
#     <tag k="comment" v="Just adding some streetnames and a restaurant"/>
#   </changeset>
# </osm>
# </syntaxhighlight>
#
### Parameters ----
# ; id
# : The id of the changeset to update. The user issuing this API call has to be the same that created the changeset
#
### Response ----
# An OSM document containing the new version of the changeset with a content type of `text/xml`
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : When there are errors parsing the XML
# ; HTTP status code 404 (Not Found)
# : When no changeset with the given id could be found
# ; HTTP status code 405 (Method Not Allowed)
# : If the request is not a HTTP PUT request
# ; HTTP status code 409 (Conflict) - `text/plain`
# : If the changeset in question has already been closed (either by the user itself or as a result of the auto-closing feature). A message with the format "`The changeset #id was closed at #closed_at.`" is returned
# : Or if the user trying to update the changeset is not the same as the one that created it
#
### Notes ----
# Unchanged tags have to be repeated in order to not be deleted.

#' @describeIn osm_create_changeset Update the tags of an open changeset.
#'
#' @param changeset_id The id of the changeset to update. The user issuing this API call has to be the same that created
#'   the changeset.
#'
#' @details
#' When updating a changeset, unchanged tags have to be repeated in order to not be deleted.
#'
#' @export
osm_update_changeset <- function(changeset_id, comment, ...,
                                 created_by = paste("osmapiR", getOption("osmapir.osmapir_version")), verbose = FALSE) {
  tags <- list(...)

  if (missing(comment)) {
    stop("A descriptive comment of the changeset is mandatory.")
  }

  tags <- c(list(comment = comment, created_by = created_by), tags)

  xml <- changeset_create_xml(tags)
  path <- tempfile(fileext = ".xml")
  xml2::write_xml(xml, path)

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "PUT")
  req <- httr2::req_url_path_append(req, "changeset", changeset_id)
  req <- httr2::req_body_file(req, path = path)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- changeset_xml2DF(obj_xml)

  file.remove(path)

  return(out)
}


## Close: `PUT /api/0.6/changeset/#id/close` ----
# Closes a changeset. A changeset may already have been closed without the owner issuing this API call. In this case an error code is returned.
#
### Parameters ----
# ; id
# : The id of the changeset to close. The user issuing this API call has to be the same that created the changeset.
#
### Response ----
# Nothing is returned upon successful closing of a changeset (HTTP status code 200)
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : When no changeset with the given id could be found
# ; HTTP status code 405 (Method Not Allowed)
# : If the request is not a HTTP PUT request
# ; HTTP status code 409 (Conflict) - `text/plain`
# : If the changeset in question has already been closed (either by the user itself or as a result of the auto-closing feature). A message with the format "`The changeset #id was closed at #closed_at.`" is returned
# : Or if the user trying to update the changeset is not the same as the one that created it

#' @describeIn osm_create_changeset Close a changeset. A changeset may already have been closed without the owner
#'   issuing this API call. In this case an error code is returned.
#'
#' @return Nothing is returned upon successful closing of a changeset.
#' @export
osm_close_changeset <- function(changeset_id) {
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "PUT")
  req <- httr2::req_url_path_append(req, "changeset", changeset_id, "close")

  httr2::req_perform(req)

  invisible()
}


## Download: `GET /api/0.6/changeset/#id/download` ----
# Returns the [[OsmChange]] document describing all changes associated with the changeset.
#
### Parameters ----
# ; id
# : The id of the changeset for which the OsmChange is requested.
#
### Response ----
# The OsmChange XML with a content type of `text/xml`.
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : When no changeset with the given id could be found
#
### Notes ----
# * The result of calling this may change as long as the changeset is open.
# * The elements in the OsmChange are sorted by timestamp and version number.
# * There is a [https://wiki.openstreetmap.org/wiki/API_v0.6#Read:_GET_/api/0.6/changeset/#id?include_discussion=true separate call] to get only information about the changeset itself

#' Download a changeset in `OsmChange` format
#'
#' Returns the [OsmChange](https://wiki.openstreetmap.org/wiki/OsmChange) document describing all changes associated with the changeset.
#'
#' @param changeset_id The id of the changeset represented by a numeric or a character value for which the OsmChange is
#'   requested.
#' @param format Format of the output. Can be `"R"` (default) or `"osc"` (`"xml"` is a synonym for `"osc"`).
#'
#' @details
#' * The result of calling this may change as long as the changeset is open.
#' * The elements in the OsmChange are sorted by timestamp and version number.
#' * There is [osm_get_changesets()] to get only information about the changeset itself.
#'
#' @return
#' If `format = "R"`, returns a data frame with one row for each edit action in the changeset. If `format = "osc"`,
#' returns a [xml2::xml_document-class] in the [OsmChange](https://wiki.openstreetmap.org/wiki/OsmChange) format.
#'
#' @family get changesets' functions
#' @family OsmChange's functions
#' @export
#'
#' @examples
#' chaset <- osm_download_changeset(changeset_id = 137003062)
#' chaset
osm_download_changeset <- function(changeset_id, format = c("R", "osc", "xml")) {
  format <- match.arg(format)

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "changeset", changeset_id, "download")

  resp <- httr2::req_perform(req)
  out <- httr2::resp_body_xml(resp)

  if (format == "R") {
    out <- osmchange_xml2DF(out)
  }

  return(out)
}


## DEPRECATED: Expand Bounding Box: `POST /api/0.6/changeset/#id/expand_bbox`</s> (deprecated, gone) ----
#
# ''Note: This endpoint was removed in December 2019. See this'' [https://github.com/openstreetmap/openstreetmap-website/issues/2316 GitHub issue].


## Query: `GET /api/0.6/changesets` ----
# This is an API method for getting a list of changesets. It supports filtering by different criteria.
#
# Where multiple queries are given the result will be those which match all of the requirements. The contents of the returned document are the changesets and their tags. To get the full set of changes associated with a changeset, use the ''download'' method on each changeset ID individually.
#
# Modification and extension of the basic queries above may be required to support rollback and other uses we find for changesets.
#
# This call returns changesets matching criteria, ordered by their creation time. The default ordering is newest first, but you can specify '''order=oldest''' to reverse the sort order<ref>https://github.com/openstreetmap/openstreetmap-website/blob/f1c6a87aa137c11d0aff5a4b0e563ac2c2a8f82d/app/controllers/api/changesets_controller.rb#L174 - see the current state at https://github.com/openstreetmap/openstreetmap-website/blob/master/app/controllers/api/changesets_controller.rb#L174</ref>. Reverse ordering cannot be combined with '''time'''.
#
### Parameters ----
# ; bbox=min_lon,min_lat,max_lon,max_lat (W,S,E,N)
# : Find changesets within the given bounding box
# ; user=#uid '''or''' display_name=#name
# : Find changesets by the user with the given user id or display name. Providing both is an error.
# ; time=T1
# : Find changesets ''closed'' after T1. Compare with '''from=T1''' which filters by creation time instead.
# ; time=T1,T2
# : Find changesets that were ''closed'' after T1 and ''created'' before T2. In other words, any changesets that were open ''at some time'' during the given time range T1 to T2.
# ; from=T1 [& to=T2]
# : Find changesets ''created'' at or after T1, and (optionally) before T2. '''to''' requires '''from''', but not vice-versa. If '''to''' is provided alone, it has no effect.
# ; open=true
# : Only finds changesets that are still ''open'' but excludes changesets that are closed or have reached the element limit for a changeset (10.000 at the moment<ref>https://api.openstreetmap.org/api/0.6/capabilities "<changesets maximum_elements="10000"/>"</ref>)
# ; closed=true
# : Only finds changesets that are ''closed'' or have reached the element limit
# ; changesets=#cid{,#cid}
# : Finds changesets with the specified ids (since [https://github.com/openstreetmap/openstreetmap-website/commit/1d1f194d598e54a5d6fb4f38fb569d4138af0dc8 2013-12-05])
# ; limit=N
# : Specifies the maximum number of changesets returned. A number between 1 and the maximum limit value (currently 100). If omitted, the default limit value is used (currently 100). The actual maximum and default limit values can be found with [[API_v0.6#Capabilities:_GET_/api/capabilities| a capabilities request]].
# Time format:
# Anything that [https://ruby-doc.org/stdlib-2.7.0/libdoc/time/rdoc/Time.html#method-c-parse <code>Time.parse</code> Ruby function] will parse.
#
### Response ----
# Returns a list of all changeset ordered by creation date. The `<osm>` element may be empty if there were no results for the query. The response is sent with a content type of `text/xml`.
#
### Error codes ----
# ; HTTP status code 400 (Bad Request) - `text/plain`
# : On misformed parameters. A text message explaining the error is returned. In particular, trying to provide both the UID and display name as user query parameters will result in this error.
# ; HTTP status code 404 (Not Found)
# : When no user with the given `uid` or `display_name` could be found.
#
### Notes ----
# * Only changesets by public users are returned.
# * Returns at most 100 changesets

#' Query changesets
#'
#' This is an API method for getting a list of changesets. It supports filtering by different criteria.
#'
#' @param bbox Find changesets within the given bounding box coordinates (`left,bottom,right,top`).
#' @param user Find changesets by the user with the given user id (numeric) or display name (character).
#' @param time Find changesets **closed** after this date and time. Compare with `from=T1` which filters by creation
#'   time instead. See details for the valid formats.
#' @param time_2 Find changesets that were **closed** after `time` and **created** before `time_2`. In other words, any
#'   changesets that were open **at some time** during the given time range `time` to `time_2`. See details for the
#'   valid formats.
#' @param from Find changesets **created** at or after this value. See details for the valid formats.
#' @param to Find changesets **created** before this value. `to` requires `from`, but not vice-versa. If `to` is
#'   provided alone, it has no effect. See details for the valid formats.
#' @param open If `TRUE`, only finds changesets that are still **open** but excludes changesets that are closed or have
#'   reached the element limit for a changeset (10,000 at the moment `osm_capabilities()$api$changesets`).
#' @param closed If `TRUE`, only finds changesets that are **closed** or have reached the element limit.
#' @param changeset_ids Finds changesets with the specified ids.
#' @param order If `"newest"` (default), sort newest changesets first. If `"oldest"`, reverse order.
#' @param limit Specifies the maximum number of changesets returned. A number between 1 and 100, with 100 as the default
#'   value.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the changesets are saved in a single list column `tags`
#'   containing a `data.frame` for each changeset with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
#'
#' @details
#' Where multiple queries are given the result will be those which match all of the requirements. The contents of the
#' returned document are the changesets and their tags. To get the full set of changes associated with a changeset, use
#' [osm_download_changeset()] on each changeset ID individually.
#'
#' Modification and extension of the basic queries above may be required to support rollback and other uses we find for
#' changesets.
#'
#' This call returns changesets matching criteria, ordered by their creation time. The default ordering is newest first,
#' but you can specify `order="oldest"` to reverse the sort order (see
#' [ordered by `created_at`](https://github.com/openstreetmap/openstreetmap-website/blob/f1c6a87aa137c11d0aff5a4b0e563ac2c2a8f82d/app/controllers/api/changesets_controller.rb#L174)
#' – see the [current state](https://github.com/openstreetmap/openstreetmap-website/blob/master/app/controllers/api/changesets_controller.rb#L174)).
#' Reverse ordering cannot be combined with `time`.
#'
#' Te valid formats for `time`, `time_2`, `from` and `to` parameters are [POSIXt] values or characters with anything
#' that [`Time.parse` Ruby function](https://ruby-doc.org/stdlib-2.7.0/libdoc/time/rdoc/Time.html#method-c-parse) will
#' parse.
#'
#' @return
#' If `format = "R"`, returns a data frame with one OSM changeset per row.
#'
#' ## `format = "xml"`
#' Returns a [xml2::xml_document-class] with the following format:
#' ``` xml
#' <osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="http://www.openstreetmap.org/copyright" license="http://opendatacommons.org/licenses/odbl/1-0/">
#'   <changeset id="10" created_at="2005-05-01T16:09:37Z" open="false" comments_count="1" changes_count="10" closed_at="2005-05-01T17:16:44Z" min_lat="59.9513092" min_lon="10.7719727" max_lat="59.9561501" max_lon="10.7994537" uid="24" user="Petter Reinholdtsen">
#'     <tag k="created_by" v="JOSM 1.61"/>
#'     <tag k="comment" v="Just adding some streetnames"/>
#'     ...
#'   </changeset>
#'   <changeset ...>
#'     ...
#'   </changeset>
#' </osm>
#' ```
#'
#' ## `format = "json"`
#' Returns a list with the following json structure:
#' ``` json
#' {
#'   "version": "0.6",
#'   "generator": "openstreetmap-cgimap 2.0.0 (4003517 spike-08.openstreetmap.org)",
#'   "copyright": "OpenStreetMap and contributors",
#'   "attribution": "http://www.openstreetmap.org/copyright",
#'   "license": "http://opendatacommons.org/licenses/odbl/1-0/",
#'   "changesets": [
#'     {
#'       "id": 10,
#'       "created_at": "2005-05-01T16:09:37Z",
#'       "open": false,
#'       "comments_count": 1,
#'       "changes_count": 10,
#'       "closed_at": "2005-05-01T17:16:44Z",
#'       "min_lat": 59.9513092,
#'       "min_lon": 10.7719727,
#'       "max_lat": 59.9561501,
#'       "max_lon": 10.7994537,
#'       "uid": 24,
#'       "user": "Petter Reinholdtsen",
#'       "tags": {
#'           "comment": "Just adding some streetnames",
#'           "created_by": "JOSM 1.61"
#'       }
#'     },
#'     ...
#'   ]
#' }
#' ```
#'
#' @family get changesets' functions
#' @noRd
#'
#' @examples
#' chst_ids <- osm_query_changesets(changeset_ids = c(137627129, 137625624))
#' chst_ids
#'
#' chsts <- osm_query_changesets(
#'   bbox = c(-1.241112, 38.0294955, 8.4203171, 42.9186456),
#'   user = "Mementomoristultus",
#'   time = "2023-06-22T02:23:23Z",
#'   time_2 = "2023-06-22T00:38:20Z"
#' )
#' chsts
#'
#' chsts2 <- osm_query_changesets(
#'   bbox = c("-9.3015367,41.8073642,-6.7339533,43.790422"),
#'   user = "Mementomoristultus",
#'   closed = "true"
#' )
#' chsts2
.osm_query_changesets <- function(bbox = NULL, user = NULL, time = NULL, time_2 = NULL, from = NULL, to = NULL,
                                  open = NULL, closed = NULL, changeset_ids = NULL, order = NULL,
                                  limit = getOption(
                                    "osmapir.api_capabilities"
                                  )$api$changesets["default_query_limit"],
                                  format = c("R", "xml", "json"), tags_in_columns = FALSE) {
  format <- match.arg(format)

  if (is.null(user)) {
    display_name <- NULL
  } else {
    if (is.numeric(user)) {
      display_name <- NULL
    } else {
      display_name <- user
      user <- NULL
    }
  }

  if (!is.null(time) && inherits(time, "POSIXt")) {
    time <- format(time, "%Y-%m-%dT%H:%M:%SZ")
  }
  if (!is.null(time_2)) {
    stopifnot("`time_2` requires `time` parameter." = !is.null(time))
    if (inherits(time_2, "POSIXt")) {
      time_2 <- format(time_2, "%Y-%m-%dT%H:%M:%SZ")
    }
    time <- paste0(time, ",", time_2)
  }

  if (!is.null(from) && inherits(from, "POSIXt")) {
    from <- format(from, "%Y-%m-%dT%H:%M:%SZ")
  }
  if (!is.null(to) && inherits(to, "POSIXt")) {
    to <- format(to, "%Y-%m-%dT%H:%M:%SZ")
  }

  if (format == "json") {
    ext <- "changesets.json"
  } else {
    ext <- "changesets"
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, ext)
  req <- httr2::req_url_query(req,
    bbox = bbox,
    user = user, display_name = display_name,
    time = time, from = from, to = to,
    open = open, closed = closed,
    changesets = changeset_ids,
    order = order,
    limit = limit
  )

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "xml")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- changeset_xml2DF(out, tags_in_columns = tags_in_columns)
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


## Diff upload: `POST /api/0.6/changeset/#id/upload` ----
# With this API call files in the [[OsmChange]] format can be uploaded to the server. This is guaranteed to be running in a transaction. So either all the changes are applied or none.
#
# To upload an OSC file it has to conform to the [[OsmChange]] specification with the following differences:
#
# * each element must carry a ''changeset'' and a ''version'' attribute, except when you are creating an element where the version is not required as the server sets that for you. The ''changeset'' must be the same as the changeset ID being uploaded to.
#
# * a <delete> block in the OsmChange document may have an ''if-unused'' attribute (the value of which is ignored). If this attribute is present, then the delete operation(s) in this block are conditional and will only be executed if the object to be deleted is not used by another object. Without the ''if-unused'', such a situation would lead to an error, and the whole diff upload would fail. Setting the attribute will also cause deletions of already deleted objects to not generate an error.
#
# * [[OsmChange]] documents generally have ''user'' and ''uid'' attributes on each element. These are not required in the document uploaded to the API.
#
### Parameters ----
# ; id
# : The ID of the changeset this diff belongs to.
# ; POST data
# : The OsmChange file data
#
### Response ----
# If a diff is successfully applied a XML (content type `text/xml`) is returned in the following format
# <syntaxhighlight lang="xml">
# <diffResult generator="OpenStreetMap Server" version="0.6">
#   <node|way|relation old_id="#" new_id="#" new_version="#"/>
#   ...
# </diffResult>
# </syntaxhighlight>
# with one element for every element in the upload. Note that this can be counter-intuitive when the same element has appeared multiple times in the input then it will appear multiple times in the output.
#
# {| class="wikitable" style="text-align:center"
# |-
# ! Attribute !! create !! modify !! delete
# |-
# ! old_id
# | colspan=3| same as uploaded element.
# |-
# ! new_id
# | new ID ||new ID ''or'' same as uploaded||not present
# |-
# ! new_version
# | colspan=2| new version || not present
# |}
#
### Error codes ----
# ; HTTP status code 400 (Bad Request) - `text/plain`
# : When there are errors parsing the XML. A text message explaining the error is returned.
# : When an placeholder ID is missing or not unique (this will occur for circular relation references)
# ; HTTP status code 404 (Not Found)
# : When no changeset with the given id could be found
# : Or when the diff contains elements that could not be found for the given id
# ; HTTP status code 405 (Method Not Allowed)
# : If the request is not a HTTP POST request
# ; HTTP status code 409 (Conflict) - `text/plain`
# : If the changeset in question has already been closed (either by the user itself or as a result of the auto-closing feature). A message with the format "`The changeset #id was closed at #closed_at.`" is returned
# : If, while uploading, the max. size of the changeset is exceeded. A message with the format "`The changeset #id was closed at #closed_at.`" is returned
# : Or if the user trying to update the changeset is not the same as the one that created it
# : Or if the diff contains elements with changeset IDs which don't match the changeset ID that the diff was uploaded to
# : Or any of the error messages that could occur as a result of a create, update or delete operation for one of the elements
# ; HTTP status code 413 (Payload too large/Content too large)
# : If, while uploading, the permitted bounding box size is exceeded, an error "<tt>Changeset bounding box size limit exceeded.</tt>" is returned.
# ; HTTP status code 429 (Too many requests)
# : When the request has been blocked due to rate limiting
# ; Other status codes
# : Any of the error codes and associated messages that could occur as a result of a create, update or delete operation for one of the elements
# : See the according sections in this page
#
### Notes ----
# * Processing stops at the first error, so if there are multiple conflicts in one diff upload, only the first problem is reported.
# * Refer to <code>/api/capabilities</code> --> ''changesets'' -> ''maximum_elements'' for the maximum number of changes permitted in a changeset.
# * There is currently no limit in the diff size on the Rails port. CGImap limits diff size to 50MB (uncompressed size).
# * Forward referencing of placeholder ids is not permitted and will be rejected by the API.

#' Diff (OsmChange format) upload to a changeset
#'
#' With this API call files in the [OsmChange](https://wiki.openstreetmap.org/wiki/OsmChange) format can be uploaded to
#' the server. This is guaranteed to be running in a transaction. So either all the changes are applied or none.
#'
#' @param changeset_id The ID of the changeset this diff belongs to. The user issuing this API call has to be the same
#'   that created the changeset.
#' @param osmcha The OsmChange data. Can be the path of an OsmChange file, a [xml2::xml_document-class] or an
#'   `osmapi_OsmChange` object (see `osmchange_*()` functions).
#' @param format Format of the output. Can be `"R"` (default) or `"xml"`.
#'
#' @details
#' To upload an OSC file it has to conform to the [OsmChange](https://wiki.openstreetmap.org/wiki/OsmChange)
#' specification with the following differences:
#' * each element must carry a `changeset` and a `version` attribute (xml) / column (data.frame), except when you are
#'   creating an element where the version is not required as the server sets that for you. The `changeset` must be the
#'   same as the changeset ID being uploaded to.
#' * a `<delete>` block in the OsmChange document may have an `if-unused` attribute (the value of which is ignored)
#'   (`action_type` column with `delete if-unused` for data.frames). If this attribute is present, then the delete
#'   operation(s) in this block are conditional and will only be executed if the object to be deleted is not used by
#'   another object. Without the `if-unused`, such a situation would lead to an error, and the whole diff upload would
#'   fail. Setting the attribute will also cause deletions of already deleted objects to not generate an error.
#' * [OsmChange](https://wiki.openstreetmap.org/wiki/OsmChange) documents generally have `user` and `uid` attributes
#'   on each element. These are not required in the document uploaded to the API.
#'
#' @note
#' * Processing stops at the first error, so if there are multiple conflicts in one diff upload, only the first problem
#'   is reported.
#' * Refer to [osm_capabilities()] --> `changesets$maximum_elements` for the maximum number of changes permitted in a
#'   changeset.
#' * There is currently no limit in the diff size on the Rails port. CGImap limits diff size to 50MB (uncompressed
#'   size).
#' * Forward referencing of placeholder ids is not permitted and will be rejected by the API.
#'
#' @return
#' If a diff is successfully applied and `format = "R"`, it returns a data frame with one row for each edited object.
#' For `format = "xml"`, a [xml2::xml_document-class] is returned in the following format:
#' ```xml
#' <diffResult generator="OpenStreetMap Server" version="0.6">
#'   <node|way|relation old_id="#" new_id="#" new_version="#"/>
#'   ...
#' </diffResult>
#' ```
#' with one element for every object in the upload.
#'
#' Note that this can be counter-intuitive when the same element has appeared multiple times in the input then it will
#' appear multiple times in the output.
#'
#' | **Attribute**   | **create**  | **modify**  | **delete**  |
#' |-----------------|:-----------:|:-----------:|:-----------:|
#' | **old_id**      | same as uploaded element  | same as uploaded element | same as uploaded element |
#' | **new_id**      | new ID      | new ID ''or'' same as uploaded | not present |
#' | **new_version** | new version | new version | not present |
#'
#' @family edit changeset's functions
#' @family OsmChange's functions
#' @export
#'
#' @examples
#' vignette("how_to_edit_osm", package = "osmapiR")
osm_diff_upload_changeset <- function(changeset_id, osmcha, format = c("R", "xml")) {
  format <- match.arg(format)

  if (is.character(osmcha)) {
    if (file.exists(osmcha)) {
      path <- osmcha
      rm_path <- FALSE
    } else {
      stop("`osmcha` is interpreted as a path to an OsmChange file, but it can't be found (", osmcha, ").")
    }
  } else {
    if (inherits(osmcha, "xml_document")) {
      xml <- osmcha
    } else if (inherits(osmcha, "osmapi_OsmChange")) {
      xml <- osmcha_DF2xml(osmcha)
    } else if (inherits(osmcha, "data.frame")) {
      xml <- osmcha_DF2xml(osmcha)
    } else {
      stop(
        "`osmcha` must be a path to a OsmChage file, a `xml_document` with a OsmChange content ",
        "or an `osmapi_OsmChange` object."
      )
    }

    if (!missing(changeset_id)) {
      lapply(xml2::xml_children(xml), function(x) {
        osm_obj <- xml2::xml_children(x)
        xml2::xml_attr(osm_obj, attr = "changeset") <- changeset_id
      })
    }

    path <- tempfile(fileext = ".osc")
    xml2::write_xml(xml, path)
    rm_path <- TRUE
  }

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "changeset", changeset_id, "upload")
  req <- httr2::req_body_file(req, path = path)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  if (format == "R") {
    out <- osmchange_upload_response_xml2DF(obj_xml)
  } else {
    out <- obj_xml
  }

  if (rm_path) {
    file.remove(path)
  }

  return(out)
}


## Changeset summary ----
#
# The procedure for successful creation of a changeset is summarized in the following picture.
# https://wiki.openstreetmap.org/wiki/API_v0.6#Changeset_summary
# ''Note that the picture demonstrates single object operations to create/update/delete elements as per API 0.5. For performance reasons, API users are advised to use the API 0.6 diff upload endpoint instead.''
#
# [[Image:OSM API0.6 Changeset successful creation V0.1.png|600px]]
