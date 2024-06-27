## Miscellaneous
#
#
## Available API versions: `GET /api/versions` ----
#
# Returns a list of API versions supported by this instance.
#
### Response XML ----
#  `GET /api/versions`
#
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <osm generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="https://www.openstreetmap.org/copyright" license="https://opendatacommons.org/licenses/odbl/1-0/">
# 	<api>
# 		<version>0.6</version>
# 	</api>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  `GET /api/versions.json```
#
# <syntaxhighlight lang="json">
# {
#  "version": "0.6",
#  "generator": "OpenStreetMap server",
#  "api": {
#   "versions": ["0.6"]
#  }
# }
# </syntaxhighlight>

#' Available API versions
#'
#' @return A character vector with the supported versions
#' @family API functions
#' @export
#'
#' @examples
#' osm_api_versions()
osm_api_versions <- function() {
  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path(req, "api", "versions")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  versions <- xml2::xml_find_all(obj_xml, xpath = ".//version")
  out <- xml2::xml_text(versions)

  return(out)
}


## Capabilities: `GET /api/capabilities` ----
# Also available as: GET /api/0.6/capabilities.
# This API call is meant to provide information about the capabilities and limitations of the current API.
#
### Response ----
# Returns a XML document (content type `text/xml`)
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="https://www.openstreetmap.org/copyright" license="https://opendatacommons.org/licenses/odbl/1-0/">
# 	<api>
# 		<version minimum="0.6" maximum="0.6"/>
# 		<area maximum="0.25"/>
# 		<note_area maximum="25"/>
# 		<tracepoints per_page="5000"/>
# 		<waynodes maximum="2000"/>
# 		<relationmembers maximum="32000"/>
# 		<changesets maximum_elements="10000" default_query_limit="100" maximum_query_limit="100"/>
# 		<notes default_query_limit="100" maximum_query_limit="10000"/>
# 		<timeout seconds="300"/>
# 		<status database="online" api="online" gpx="online"/>
# 	</api>
# 	<policy>
# 		<imagery>
# 			<blacklist regex=".*\.google(apis)?\..*/(vt|kh)[\?/].*([xyz]=.*){3}.*"/>
# 			<blacklist regex="http://xdworld\.vworld\.kr:8080/.*"/>
# 			<blacklist regex=".*\.here\.com[/:].*"/>
# 		</imagery>
# 	</policy>
# </osm>
# </syntaxhighlight>
# Please note that actual returned values may change at any time and this XML document only serves as an example.
#
# * Copyright, attribution, and license: referring to legal information
#
# API:
# * '''version''' '''minimum''' and '''maximum''' are the API call versions that the server will accept.
# * '''area''' '''maximum''' is the maximum area in square degrees that can be queried by API calls.
# * '''tracepoints''' '''per_page''' is the maximum number of points in a single GPS trace. (Possibly incorrect)
# * '''waynodes''' '''maximum''' is the maximum number of nodes that a way may contain.
# * '''relationmembers''' '''maximum''' is the maximum number of members that a relation may contain. (''added in February 2022'')
# * '''changesets''' '''maximum_elements''' is the maximum number of combined nodes, ways and relations that can be contained in a changeset.
# * '''changesets''' '''default_query_limit''' and '''maximum_query_limit''' are the default and maximum values of the limit parameter of [[API v0.6#Query:_GET_/api/0.6/changesets|changeset queries]]. (''added in {{GitHub link|openstreetmap/openstreetmap-website/pull/4142| August 2023}}'')
# * '''notes''' '''default_query_limit''' and '''maximum_query_limit''' are the default and maximum values of the limit parameter of notes [[API_v0.6#Retrieving_notes_data_by_bounding_box:_GET_/api/0.6/notes| bounding box queries]] and [[API_v0.6#Search_for_notes:_GET_/api/0.6/notes/search| search]]. (''added in {{GitHub link|openstreetmap/openstreetmap-website/pull/4187| August 2023}}'')
# * The '''status''' element returns either ''online'', ''readonly'' or ''offline'' for each of the database, API and GPX API. The '''database''' field is informational, and the '''api'''/'''gpx''' fields indicate whether a client should expect read and write requests to work (''online''), only read requests to work (''readonly'') or no requests to work (''offline'').#
#
# Policy:
# * Imagery blacklist lists all aerial and map sources, which are not permitted for OSM usage due to copyright. Editors must not show these resources as background layer.
#
### Notes ----
# * Currently both versioned (<tt>/api/0.6/capabilities</tt>) and unversioned (<tt>/api/capabilities</tt>) version of this call exist. The unversioned one is {{GitHub link|openstreetmap/openstreetmap-website/commit/2398614349e3ff5605868fea82e013d2a9a16ef9| deprecated}} in favor of [[API_v0.6#Available_API_versions:_GET_/api/versions| checking the available versions]] first, then accessing the capabilities of a particular version.
# * Element and relation member ids are currently implementation dependent limited to 64bit signed integers, this should not be a problem :-).

#' Capabilities of the API
#'
#' Provide information about the capabilities and limitations of the current API.
#'
#' @details
#' API:
#' * `version` `minimum` and `maximum` are the API call versions that the server will accept.
#' * `area` `maximum` is the maximum area in square degrees that can be queried by API calls.
#' * `tracepoints` `per_page` is the maximum number of points in a single GPS trace. (Possibly incorrect)
#' * `waynodes` `maximum` is the maximum number of nodes that a way may contain.
#' * `relationmember` `maximum` is the maximum number of members that a relation may contain.
#' * `changesets` `maximum_elements` is the maximum number of combined nodes, ways and relations that can be contained
#'   in a changeset.
#' * `changesets` `default_query_limit` and `maximum_query_limit` are the default and maximum values of the limit
#'   parameter of [osm_query_changesets()].
#' * `notes` `default_query_limit` and `maximum_query_limit` are the default and maximum values of the limit parameter
#'   of notes bounding box queries ([osm_read_bbox_notes()]) and search ([osm_search_notes()]).
#' * The `status` element returns either _online_, _readonly_ or _offline_ for each of the database, API and GPX
#'   API. The `database` field is informational, and the `API`/`GPX-API` fields indicate whether a client should expect
#'   read and write requests to work (_online_), only read requests to work (_readonly_) or no requests to work
#'   (_offline_).
#'
#' Policy:
#' * Imagery blacklist lists all aerial and map sources, which are not permitted for OSM usage due to copyright. Editors
#'   must not show these resources as background layer.
#'
#'
#' @return A list with the API capabilities and policies.
#' @family API functions
#' @export
#'
#' @examples
#' osm_capabilities()
osm_capabilities <- function() {
  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "capabilities")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)


  api <- xml2::xml_contents(xml2::xml_child(obj_xml, search = "api"))
  apiL <- structure(xml2::xml_attrs(api), names = xml2::xml_name(api))
  num <- c("area", "note_area", "timeout")
  apiL[num] <- lapply(apiL[num], function(x) {
    stats::setNames(as.numeric(x), nm = names(x))
  })
  int <- c("tracepoints", "waynodes", "relationmembers", "changesets", "notes")
  apiL[int] <- lapply(apiL[int], function(x) {
    stats::setNames(as.integer(x), nm = names(x))
  })

  policy <- xml2::xml_contents(xml2::xml_child(obj_xml, search = "policy"))
  policyL <- lapply(policy, function(x) {
    out <- lapply(xml2::xml_children(x), function(y) {
      structure(xml2::xml_attrs(y), names = xml2::xml_name(y))
    })

    out
  })
  names(policyL) <- xml2::xml_name(policy)

  return(list(api = apiL, policy = policyL))
}


## Retrieving map data by bounding box: `GET /api/0.6/map` ----
# The following command returns:
# * All nodes that are inside a given bounding box and any relations that reference them.
# * All ways that reference at least one node that is inside a given bounding box, any relations that reference them [the ways], and any nodes outside the bounding box that the ways may reference.
# * All relations that reference one of the nodes, ways or relations included due to the above rules. (Does '''not''' apply recursively, see explanation below.)
#
#  GET /api/0.6/map?bbox='left','bottom','right','top'
#
# where:
#
# * <code>''left''</code> is the longitude of the left (westernmost) side of the bounding box.
# * <code>''bottom''</code> is the latitude of the bottom (southernmost) side of the bounding box.
# * <code>''right''</code> is the longitude of the right (easternmost) side of the bounding box.
# * <code>''top''</code> is the latitude of the top (northernmost) side of the bounding box.
#
# Note that, while this command returns those relations that reference the aforementioned nodes and ways, the reverse is not true: it does not (necessarily) return all of the nodes and ways that are referenced by these relations. This prevents unreasonably-large result sets. For example, imagine the case where:
# * There is a relation named "England" that references every node in England.
# * The nodes, ways, and relations are retrieved for a bounding box that covers a small portion of England.
# While the result would include the nodes, ways, and relations as specified by the rules for the command, including the "England" relation, it would (fortuitously) ''not'' include ''every'' node and way in England. If desired, the nodes and ways referenced by the "England" relation could be retrieved by their respective IDs.
#
# Also note that ways which intersect the bounding box but have no nodes within the bounding box will not be returned.
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : When any of the node/way/relation limits are exceeded, in particular if the call would return more than 50'000 nodes. See above for other uses of this code.
#
# ; HTTP status code 509 (Bandwidth Limit Exceeded)
# : "Error:  You have downloaded too much data. Please try again later." See [[Developer FAQ#I've been blocked from the API for downloading too much. Now what?|Developer FAQ]].

#' Retrieve map data by bounding box
#'
#' The following command returns:
#' * All nodes that are inside a given bounding box and any relations that reference them.
#' * All ways that reference at least one node that is inside a given bounding box, any relations that reference them
#'   \[the ways\], and any nodes outside the bounding box that the ways may reference.
#' * All relations that reference one of the nodes, ways or relations included due to the above rules. (Does '''not'''
#'   apply recursively, see explanation below.)
#'
#' @param bbox Coordinates for the area to retrieve the map data from (`left,bottom,right,top`).
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the objects are saved in a single list column `tags`
#'   containing a `data.frame` for each OSM object with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
#'
#' @details
#' Note that, while this command returns those relations that reference the aforementioned nodes and ways, the reverse
#' is not true: it does not (necessarily) return all of the nodes and ways that are referenced by these relations. This
#' prevents unreasonably-large result sets. For example, imagine the case where:
#' * There is a relation named "England" that references every node in England.
#' * The nodes, ways, and relations are retrieved for a bounding box that covers a small portion of England.
#' While the result would include the nodes, ways, and relations as specified by the rules for the command, including
#' the "England" relation, it would (fortuitously) **not** include **every** node and way in England. If desired, the
#' nodes and ways referenced by the "England" relation could be retrieved by their respective IDs.
#'
#' Also note that ways which intersect the bounding box but have no nodes within the bounding box will not be returned.
#'
#' @note
#' For downloading data for purposes other than editing or exploring the history of the objects, perhaps is better to
#' use the Overpass API. A similar function to download OSM objects using Overpass, is implemented in the
#' \pkg{osmdata} function `opq()`.
#'
#' @return
#' If `format = "R"`, returns a data frame with one OSM object per row. If `format = "xml"`, returns a
#' [xml2::xml_document-class] following the
#' [OSM_XML format](https://wiki.openstreetmap.org/wiki/OSM_XML#OSM_XML_file_format_notes). If `format = "json"`,
#' returns a list with a json structure following the [OSM_JSON format](https://wiki.openstreetmap.org/wiki/OSM_JSON).
#'
#' @family get OSM objects' functions
#' @export
#'
#' @examples
#' map_data <- osm_bbox_objects(bbox = c(1.8366775, 41.8336843, 1.8379971, 41.8344537))
#' ## bbox as a character value also works (bbox = "1.8366775,41.8336843,1.8379971,41.8344537").
#' map_data
osm_bbox_objects <- function(bbox, format = c("R", "xml", "json"), tags_in_columns = FALSE) {
  format <- match.arg(format)

  if (format == "json") {
    ext <- "map.json"
  } else {
    ext <- "map"
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, ext)
  req <- httr2::req_url_query(req, bbox = paste(bbox, collapse = ","))

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "xml")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- object_xml2DF(out, tags_in_columns = tags_in_columns)
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


## Retrieving permissions: `GET /api/0.6/permissions` ----
# Returns the permissions granted to the current API connection.
#
# * If the API client is not authorized, an empty list of permissions will be returned.
# * If the API client uses Basic Auth, the list of permissions will contain all permissions.
# * If the API client uses OAuth 1.0a, the list will contain the permissions actually granted by the user.
# * If the API client uses OAuth 2.0, the list will be based on the granted scopes.
#
# Note that for compatibility reasons, all OAuth 2.0 scopes will be prefixed by "allow_", e.g. scope "read_prefs" will be shown as permission "allow_read_prefs".
#
### Response XML ----
#  GET /api/0.6/permissions
#
# Returns the single permissions element containing the permission tags (content type `text/xml`)
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <osm version="0.6" generator="OpenStreetMap server">
# 	<permissions>
# 		<permission name="allow_read_prefs"/>
# 		...
# 		<permission name="allow_read_gpx"/>
# 		<permission name="allow_write_gpx"/>
# 	</permissions>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/permissions.json
# Returns the single permissions element containing the permission tags (content type `application/json`)
# <syntaxhighlight lang="json">
# {
#  "version": "0.6",
#  "generator": "OpenStreetMap server",
#  "permissions": ["allow_read_prefs", ..., "allow_read_gpx", "allow_write_gpx"]
# }
# </syntaxhighlight>
#
### Notes ----
# {{anchor|List_of_permissions}}<!-- linked from [[OAuth]] -->
# Currently the following permissions can appear in the result, corresponding directly to the ones used in the OAuth 1.0a application definition:
# * allow_read_prefs (read user preferences)
# * allow_write_prefs (modify user preferences)
# * allow_write_diary (create diary entries, comments and make friends)
# * allow_write_api (modify the map)
# * allow_read_gpx (read private GPS traces)
# * allow_write_gpx (upload GPS traces)
# * allow_write_notes (modify notes)

#' Retrieving permissions
#'
#' Returns the permissions granted to the current API connection.
#'
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#'
#' @details
#' Currently the following permissions can appear in the result, corresponding directly to the ones used in the OAuth
#' 1.0a application definition:
#' * allow_read_prefs (read user preferences)
#' * allow_write_prefs (modify user preferences)
#' * allow_write_diary (create diary entries, comments and make friends)
#' * allow_write_api (modify the map)
#' * allow_read_gpx (read private GPS traces)
#' * allow_write_gpx (upload GPS traces)
#' * allow_write_notes (modify notes)
#'
#'
#' @note For compatibility reasons, all OAuth 2.0 scopes will be prefixed by "allow_", e.g. scope "read_prefs" will be
#'   shown as permission "allow_read_prefs".
#'
#' @return If the API client is not authorized, an empty list of permissions will be returned. Otherwise, the list will
#'   be based on the granted scopes of the logged user.
#' @family API functions
#' @export
#'
#' @examples
#' \dontrun{
#' perms <- osm_permissions()
#' perms
#' }
osm_permissions <- function(format = c("R", "xml", "json")) {
  format <- match.arg(format)

  if (format == "json") {
    ext <- "permissions.json"
  } else {
    ext <- "permissions"
  }

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, ext)

  resp <- httr2::req_perform(req)


  if (format %in% c("R", "xml")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- xml2::xml_find_all(out, xpath = ".//permission")
      out <- xml2::xml_attr(out, "name")
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}
