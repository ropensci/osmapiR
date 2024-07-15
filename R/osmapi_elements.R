## Elements
# There are create, read, update and delete calls for all of the three basic elements in OpenStreetMap (''Nodes'', ''Ways'' and ''Relations''). These calls are very similar except for the payload and a few special error messages so they are documented only once.


## Create: `PUT /api/0.6/[node|way|relation]/create` ----
# Creates a new element of the specified type. Note that the entire request should be wrapped in a <code><osm>...</osm></code> element.
#
# A Node:
# <syntaxhighlight lang="xml">
# <osm>
# 	<node changeset="12" lat="..." lon="...">
# 		<tag k="note" v="Just a node"/>
# 		...
# 	</node>
# </osm>
# </syntaxhighlight>
# A Way:
# <syntaxhighlight lang="xml">
# <osm>
# 	<way changeset="12">
# 		<tag k="note" v="Just a way"/>
# 		...
# 		<nd ref="123"/>
# 		<nd ref="4345"/>
# 		...
# 	</way>
# </osm>
# </syntaxhighlight>
# A Relation:
# <syntaxhighlight lang="xml">
# <osm>
# 	<relation changeset="12">
# 		<tag k="note" v="Just a relation"/>
# 		...
# 		<member type="node" role="stop" ref="123"/>
# 		<member type="way" ref="234"/>
# 	</relation>
# </osm>
# </syntaxhighlight>
# If multiple elements are provided only the first is created. The rest is discarded (this behavior differs from changeset creation).
#
### Response ----
# The ID of the newly created element (content type is `text/plain`)
#
### Error codes ----
# ; HTTP status code 400 (Bad Request) - `text/plain`
# : When there are errors parsing the XML. A text message explaining the error is returned.
# : When a changeset ID is missing (unfortunately the error messages are not consistent)
# : When a node is outside the world
# : When there are too many nodes for a way
# ; HTTP status code 405 (Method Not Allowed)
# : If the request is not a HTTP PUT request
# ; HTTP status code 409 (Conflict) - `text/plain`
# : If the changeset in question has already been closed (either by the user itself or as a result of the auto-closing feature). A message with the format "`The changeset #id was closed at #closed_at.`" is returned
# : Or if the user trying to update the changeset is not the same as the one that created it
# ; HTTP status code 412 (Precondition Failed)
# : When a way has nodes that do not exist or are not visible (i.e. deleted): "`Way #{id} requires the nodes with id in (#{missing_ids}), which either do not exist, or are not visible.`"
# : When a relation has elements that do not exist or are not visible: "`Relation with id #{id} cannot be saved due to #{element} with id #{element.id}`"
# ; HTTP status code 429 (Too many requests)
# : When the request has been blocked due to rate limiting
#
### Notes ----
# * This updates the bounding box of the changeset.
# * The ''role'' attribute for relations is optional. An empty string is the default.
# * To avoid performance issues when uploading multiple objects, the use of the [[API v0.6#Diff upload: POST /api/0.6/changeset/#id/upload|Diff upload]] endpoint is highly recommended.

#' Create an OSM object
#'
#' Creates a new element in an open changeset as specified.
#'
#' @param x The new object data. Can be the path to an xml file, a [xml2::xml_document-class] or a data.frame inheriting
#'   or following the structure of an `osmapi_objects` object.
#' @param changeset_id The ID of an open changeset where to create the object. If missing, `x` should define the
#'   changeset ID, otherwise it will be overwritten with `changeset_id`. Ignored if `x` is a path.
#'
#' @details
#' If `x` is a data.frame, the columns `type`, `changeset`, `tags` must be present + column `members` for ways and
#' relations + `lat` and `lon` for nodes. For the xml format, see the
#' [OSM wiki](https://wiki.openstreetmap.org/wiki/API_v0.6#Create:_PUT_/api/0.6/%5Bnode%7Cway%7Crelation%5D/create).
#'
#' If multiple elements are provided only the first is created. The rest is discarded.
#'
#' @note
#' * This updates the bounding box of the changeset.
#' * The `role` attribute for relations is optional. An empty string is the default.
#' * To avoid performance issues when uploading multiple objects, the use of the [osm_diff_upload_changeset()] is highly
#'   recommended.
#' * The version of the created object will be 1.
#'
#' @return The ID of the newly created OSM object.
#' @family edit OSM objects' functions
#' @export
#'
#' @examples
#' vignette("how_to_edit_osm", package = "osmapiR")
osm_create_object <- function(x, changeset_id) {
  if (is.character(x)) {
    if (file.exists(x)) {
      path <- x
      rm_path <- FALSE
    } else {
      stop("`x` is interpreted as a path to an xml file, but it can't be found (", x, ").")
    }
  } else {
    if (inherits(x, "xml_document")) {
      xml <- x
    } else if (inherits(x, "osmapi_objects")) {
      xml <- object_new_DF2xml(x)
    } else if (inherits(x, "data.frame")) {
      cols <- c("type", "changeset", "lat", "lon", "members", "tags")
      if (all(setdiff(cols, c("lat", "lon")) %in% names(x))) { # lat & lon can be missing for ways and relations
        xml <- object_new_DF2xml(x)
      } else {
        stop("`x` lacks ", paste0("`", paste(setdiff(cols, names(x)), collapse = "`, `"), "`"), " columns.")
      }
    } else {
      stop(
        "`x` must be a path to a xml file, a `xml_document` ",
        "or a `osmapi_objects` data.frame describing OSM objects."
      )
    }

    if (!missing(changeset_id)) {
      obj <- xml2::xml_child(xml)
      xml2::xml_attr(obj, "changeset") <- changeset_id
    }

    path <- tempfile(fileext = ".osm")
    xml2::write_xml(xml, path)
    rm_path <- TRUE
  }

  if (length(xml2::xml_children(xml)) > 1L) {
    warning(
      "Multiple elements are provided, but only the first is created. Use `osmchange_create()` + ",
      "`osm_diff_upload_changeset()` to efficiently create more than one object."
    )
  }
  osm_type <- xml2::xml_name(xml2::xml_child(xml))

  if (!osm_type[1] %in% c("node", "way", "relation")) {
    warning("Malformed xml. Node name is ", osm_type[1], ", and should be one of `node`, `way` or `relation`.")
  }


  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "PUT")
  req <- httr2::req_url_path_append(req, osm_type, "create")
  req <- httr2::req_body_file(req, path = path)

  resp <- httr2::req_perform(req)
  out <- httr2::resp_body_string(resp)

  if (rm_path) {
    file.remove(path)
  }

  return(out)
}


## Read: `GET /api/0.6/[node|way|relation]/#id` ----
# Returns the XML representation of the element.
#
### Response XML ----
#  GET /api/0.6/[node|way|relation]/#id
# XML representing the element, wrapped in an <code><osm></code> element:
# <syntaxhighlight lang="xml">
# <osm>
# 	<node id="123" lat="..." lon="..." version="142" changeset="12" user="fred" uid="123" visible="true" timestamp="2005-07-30T14:27:12+01:00">
# 		<tag k="note" v="Just a node"/>
# 		...
# 	</node>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/[node|way|relation]/#id.json
# JSON representing the element, wrapped in an <code><json></code> element:
# <syntaxhighlight lang="json">
# {
#  "version": "0.6",
#  "elements": [
#   {"type": "node", "id": 4326396331, "lat": 31.9016302, "lon": -81.5990471, "timestamp": "2016-07-31T00:08:11Z", "version": 2, "changeset": 41136027, "user": "maven149", "id": 136601}
#  ]
# }
# </syntaxhighlight>
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : When no element with the given id could be found
# ; HTTP status code 410 (Gone)
# : If the element has been deleted

#' Read an object
#'
#' Returns the representation of an object from OSM.
#'
#' @param osm_type Object type (`"node"`, `"way"` or `"relation"`).
#' @param osm_id Object id represented by a numeric or a character value.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the objects are saved in a single list column `tags`
#'   containing a `data.frame` for each OSM object with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
#'
#' @return
#' If `format = "R"`, returns a data frame with one OSM object per row. If `format = "xml"`, returns a
#' [xml2::xml_document-class] following the
#' [OSM_XML format](https://wiki.openstreetmap.org/wiki/OSM_XML#OSM_XML_file_format_notes). If `format = "json"`,
#' returns a list with a json structure following the [OSM_JSON format](https://wiki.openstreetmap.org/wiki/OSM_JSON).
#'
# @family get OSM objects' functions
#' @noRd
#'
#' @examples
#' node <- osm_read_object(osm_type = "node", osm_id = 35308286)
#' node
#'
#' way <- osm_read_object(osm_type = "way", osm_id = 13073736L)
#' way
#'
#' rel <- osm_read_object(osm_type = "relation", osm_id = "40581")
#' rel
osm_read_object <- function(osm_type = c("node", "way", "relation"),
                            osm_id, format = c("R", "xml", "json"), tags_in_columns = FALSE) {
  osm_type <- match.arg(osm_type)
  format <- match.arg(format)

  if (format == "json") {
    osm_id <- paste0(osm_id, ".json")
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, osm_type, osm_id)

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


## Update: `PUT /api/0.6/[node|way|relation]/#id` ----
# Updates data from a preexisting element. A full representation of the element as it should be after the update has to be provided. Any tags, way-node refs, and relation members that remain unchanged must be in the update as well. A version number must be provided as well, it must match the current version of the element in the database.
#
# This example is an update of the node 4326396331, updating the version 1 to alter existing tags. This change is made while the changeset with id 188021 is still open:
# <syntaxhighlight lang="xml">
# <osm>
# 	<node changeset="188021" id="4326396331" lat="50.4202102" lon="6.1211032" version="1" visible="true">
# 		<tag k="foo" v="barzzz" />
# 	</node>
# </osm>
# </syntaxhighlight>
#
### Response ----
# Returns the new version number with a content type of `text/plain`.
#
### Error codes ----
# ; HTTP status code 400 (Bad Request) - `text/plain`
# : When there are errors parsing the XML. A text message explaining the error is returned. This can also happen if you forget to pass the Content-Length header.
# : When a changeset ID is missing (unfortunately the error messages are not consistent)
# : When a node is outside the world
# : When there are too many nodes for a way
# ; HTTP status code 409 (Conflict) - `text/plain`
# : When the version of the provided element does not match the current database version of the element
# : If the changeset in question has already been closed (either by the user itself or as a result of the auto-closing feature). A message with the format "`The changeset #id was closed at #closed_at.`" is returned
# : Or if the user trying to update the changeset is not the same as the one that created it
# ; HTTP status code 404 (Not Found)
# : When no element with the given id could be found
# ; HTTP status code 412 (Precondition Failed)
# : When a way has nodes that do not exist or are not visible (i.e. deleted): "`Way #{id} requires the nodes with id in (#{missing_ids}), which either do not exist, or are not visible.`"
# : When a relation has elements that do not exist or are not visible: "`Relation with id #{id} cannot be saved due to #{element} with id #{element.id}`"
# ; HTTP status code 429 (Too many requests)
# : When the request has been blocked due to rate limiting
#
### Notes ----
# * This updates the bounding box of the changeset.
# * To avoid performance issues when updating multiple objects, the use of the [[API v0.6#Diff upload: POST /api/0.6/changeset/#id/upload|Diff upload]] endpoint is highly recommended. This is also the only way to ensure that multiple objects are updated in a single database transaction.

#' Update an OSM object
#'
#' Updates data from a preexisting element.
#'
#' @param x The new object data. Can be the path of an xml file, a [xml2::xml_document-class] or a data.frame inheriting
#'   or following the structure of an `osmapi_objects` object.
#' @param changeset_id The ID of an open changeset where to create the object. If missing, `x` should define the
#'   changeset ID, otherwise it will be overwritten with `changeset_id`. Ignored if `x` is a path.
#'
#' @details
#' A full representation of the element as it should be after the update has to be provided. Any tags, way-node refs,
#' and relation members that remain unchanged must be in the update as well. A version number must be provided as well,
#' it must match the current version of the element in the database.
#'
#' If `x` is a data.frame, the columns `type`, `id`, `visible`, `version`, `changeset`, and `tags` must be present +
#' column `members` for ways and relations + `lat` and `lon` for nodes. For the xml format, see the
#' [OSM wiki](https://wiki.openstreetmap.org/wiki/API_v0.6#Update:_PUT_/api/0.6/%5Bnode%7Cway%7Crelation%5D/%23id).
#'
#' If multiple elements are provided only the first is updated. The rest is discarded.
#'
#' @note
#' * This updates the bounding box of the changeset.
#' * To avoid performance issues when updating multiple objects, the use of the [osm_diff_upload_changeset()] is highly
#'   recommended. This is also the only way to ensure that multiple objects are updated in a single database
#'   transaction.
#'
#' @return Returns the new version number of the object.
#' @family edit OSM objects' functions
#' @export
#'
#' @examples
#' vignette("how_to_edit_osm", package = "osmapiR")
osm_update_object <- function(x, changeset_id) {
  if (is.character(x)) {
    if (file.exists(x)) {
      path <- x
      rm_path <- FALSE
    } else {
      stop("`x` is interpreted as a path to an xml file, but it can't be found (", x, ").")
    }
  } else {
    if (inherits(x, "xml_document")) {
      xml <- x
    } else if (inherits(x, "osmapi_objects")) {
      xml <- object_update_DF2xml(x)
    } else if (inherits(x, "data.frame")) {
      cols <- c("type", "id", "visible", "version", "changeset", "lat", "lon", "members", "tags")
      if (all(setdiff(cols, c("lat", "lon")) %in% names(x))) { # lat & lon can be missing for ways and relations
        xml <- object_update_DF2xml(x)
      } else {
        stop("`x` lacks ", paste0("`", paste(setdiff(cols, names(x)), collapse = "`, `"), "`"), " columns.")
      }
    } else {
      stop(
        "`x` must be a path to a xml file, a `xml_document` ",
        "or a `osmapi_objects` data.frame describing OSM objects."
      )
    }

    if (!missing(changeset_id)) {
      obj <- xml2::xml_child(xml)
      xml2::xml_attr(obj, "changeset") <- changeset_id
    }

    path <- tempfile(fileext = ".osm")
    xml2::write_xml(xml, path)
    rm_path <- TRUE
  }

  if (length(xml2::xml_children(xml)) > 1L) {
    warning(
      "Multiple elements are provided, but only the first is updated. Use `osmchange_modify()` + ",
      "`osm_diff_upload_changeset()` to efficiently update more than one object."
    )
  }

  osm_type <- xml2::xml_name(xml2::xml_child(xml))
  osm_id <- xml2::xml_attr(xml2::xml_child(xml), "id")

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "PUT")
  req <- httr2::req_url_path_append(req, osm_type, osm_id)
  req <- httr2::req_body_file(req, path = path)

  resp <- httr2::req_perform(req)
  out <- httr2::resp_body_string(resp)

  if (rm_path) {
    file.remove(path)
  }

  return(out)
}


## Delete: `DELETE /api/0.6/[node|way|relation]/#id` ----
# Expects a valid XML representation of the element to be deleted.
#
# For example:
#
# <syntaxhighlight lang="xml">
# <osm>
# 	<node id="..." version="..." changeset="..." lat="..." lon="..." />
# </osm>
# </syntaxhighlight>
#
# Where the node ID in the XML must match the ID in the URL, the version must match the version of the element you downloaded and the changeset must match the ID of an open changeset owned by the current authenticated user. It is allowed, but not necessary, to have tags on the element except for lat/long tags which are required, without lat+lon the server gives 400 Bad request.
#
### Response ----
# Returns the new version number with a content type of `text/plain`.
#
### Error codes ----
# ; HTTP status code 400 (Bad Request) - `text/plain`
# : When there are errors parsing the XML. A text message explaining the error is returned.
# : When a changeset ID is missing (unfortunately the error messages are not consistent)
# : When a node is outside the world
# : When there are too many nodes for a way
# : When the version of the provided element does not match the current database version of the element
#
# ; HTTP status code 404 (Not Found)
# : When no element with the given id could be found
#
# ; HTTP status code 409 (Conflict) - `text/plain`
# : If the changeset in question has already been closed (either by the user itself or as a result of the auto-closing feature). A message with the format "`The changeset #id was closed at #closed_at.`" is returned
# : Or if the user trying to update the changeset is not the same as the one that created it
#
# ; HTTP status code 410 (Gone)
# : If the element has already been deleted
#
# ; HTTP status code 412 (Precondition Failed)
# : When a node is still used by a way: `Node #{id} is still used by way #{way.id}.`
# : When a node is still member of a relation: `Node #{id} is still used by relation #{relation.id}.`
# : When a way is still member of a relation: `Way #{id} still used by relation #{relation.id}.`
# : When a relation is still member of another relation: `The relation #{id} is used in relation #{relation.id}.`
# :
# : Note when returned as a result of a OsmChange upload operation the error messages contain a spurious plural "s" as in "... still used by ways ...", "... still used by relations ..." even when only 1 way or relation id is returned, as this implies multiple ids can be returned if the deleted object was/is a member of multiple parent objects, these ids are seperated by commas.
# ; HTTP status code 429 (Too many requests)
# : When the request has been blocked due to rate limiting
#
### Notes ----
# * In earlier API versions no payload was required. It is needed now because of the need for changeset IDs and version numbers.
# * To avoid performance issues when updating multiple objects, the use of the Diff upload endpoint is highly recommended. This is also the only way to ensure that multiple objects are updated in a single database transaction.

#' Delete an OSM object
#'
#' Expects a valid XML representation of the element to be deleted.
#'
#' @param x The object data. Can be the path of an xml file, a [xml2::xml_document-class] or a data.frame inheriting
#'   or following the structure of an `osmapi_objects` object.
#' @param changeset_id The ID of an open changeset where to create the object. If missing, `x` should define the
#'   changeset ID, otherwise it will be overwritten with `changeset_id`. Ignored if `x` is a path.
#'
#' @details
#' The version must match the version of the element you downloaded and the changeset must match the `id` of an open
#' changeset owned by the current authenticated user. It is allowed, but not necessary, to have tags on the element
#' except for lat/long which are required for nodes, without lat+lon the server gives 400 Bad request.
#'
#' If `x` is a data.frame, the columns `type`, `id`, `version` and `changeset` must be present + `lat` and `lon` for
#' nodes. For the xml format, see the
#' [OSM wiki](https://wiki.openstreetmap.org/wiki/API_v0.6#Delete:_DELETE_/api/0.6/%5Bnode%7Cway%7Crelation%5D/%23id).
#'
#' If multiple elements are provided only the first is deleted. The rest is discarded.
#'
#' @note
#' * This updates the bounding box of the changeset.
#' * To avoid performance issues when deleting multiple objects, the use of the [osm_diff_upload_changeset()] is highly
#'   recommended. This is also the only way to ensure that multiple objects are updated in a single database
#'   transaction.
#'
#' @return Returns the new version number of the object.
#' @family edit OSM objects' functions
#' @export
#'
#' @examples
#' vignette("how_to_edit_osm", package = "osmapiR")
osm_delete_object <- function(x, changeset_id) {
  if (is.character(x)) {
    if (file.exists(x)) {
      path <- x
      rm_path <- FALSE
    } else {
      stop("`x` is interpreted as a path to an xml file, but it can't be found (", x, ").")
    }
  } else {
    if (inherits(x, "xml_document")) {
      xml <- x
    } else if (inherits(x, "osmapi_objects")) {
      xml <- object_update_DF2xml(x)
    } else if (inherits(x, "data.frame")) {
      cols <- c("type", "id", "version", "changeset", "lat", "lon")
      if (all(setdiff(cols, c("lat", "lon")) %in% names(x))) { # lat & lon can be missing for ways and relations
        xml <- object_update_DF2xml(x)
      } else {
        stop("`x` lacks ", paste0("`", paste(setdiff(cols, names(x)), collapse = "`, `"), "`"), " columns.")
      }
    } else {
      stop(
        "`x` must be a path to a xml file, a `xml_document` ",
        "or a `osmapi_objects` data.frame describing OSM objects."
      )
    }

    if (!missing(changeset_id)) {
      obj <- xml2::xml_child(xml)
      xml2::xml_attr(obj, "changeset") <- changeset_id
    }

    path <- tempfile(fileext = ".osm")
    xml2::write_xml(xml, path)
    rm_path <- TRUE
  }

  if (length(xml2::xml_children(xml)) > 1L) {
    warning(
      "Multiple elements are provided, but only the first is deleted. Use `osmchange_delete()` + ",
      "`osm_diff_upload_changeset()` to efficiently delete more than one object."
    )
  }

  osm_type <- xml2::xml_name(xml2::xml_child(xml))
  osm_id <- xml2::xml_attr(xml2::xml_child(xml), "id")

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "DELETE")
  req <- httr2::req_url_path_append(req, osm_type, osm_id)
  req <- httr2::req_body_file(req, path = path)

  resp <- httr2::req_perform(req)
  out <- httr2::resp_body_string(resp)

  if (rm_path) {
    file.remove(path)
  }

  return(out)
}


## History: `GET /api/0.6/[node|way|relation]/#id/history` ----
# Retrieves all old versions of an element. ([https://api.openstreetmap.org/api/0.6/way/250066046/history example])
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : When no element with the given id could be found

#' Get the history of an object
#'
#' Retrieves all old versions of an object from OSM.
#'
#' @param osm_type Object type (`"node"`, `"way"` or `"relation"`).
#' @param osm_id Object id represented by a numeric or a character value.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the objects are saved in a single list column `tags`
#'   containing a `data.frame` for each OSM object with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
#'
#' @return
#' If `format = "R"`, returns a data frame with a version of the OSM object per row. If `format = "xml"`, returns a
#' [xml2::xml_document-class] following the
#' [OSM_XML format](https://wiki.openstreetmap.org/wiki/OSM_XML#OSM_XML_file_format_notes). If `format = "json"`,
#' returns a list with a json structure following the [OSM_JSON format](https://wiki.openstreetmap.org/wiki/OSM_JSON).
#' @family get OSM objects' functions
#' @export
#'
#' @examples
#' node <- osm_history_object(osm_type = "node", osm_id = 35308286)
#' node
#'
#' way <- osm_history_object(osm_type = "way", osm_id = 13073736L)
#' way
#'
#' rel <- osm_history_object(osm_type = "relation", osm_id = "40581")
#' rel
osm_history_object <- function(osm_type = c("node", "way", "relation"), osm_id,
                               format = c("R", "xml", "json"), tags_in_columns = FALSE) {
  osm_type <- match.arg(osm_type)
  format <- match.arg(format)

  if (format == "json") {
    ext <- "history.json"
  } else {
    ext <- "history"
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, osm_type, osm_id, ext)

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


## Version: `GET /api/0.6/[node|way|relation]/#id/#version` ----
# Retrieves a specific version of the element.
#
### Error codes ----
# ; HTTP status code 403 (Forbidden)
# : When the version of the element is not available (due to redaction)
# ; HTTP status code 404 (Not Found)
# : When no element with the given id could be found

#' Get a version of an object
#'
#' Retrieves a specific version of an object from OSM.
#'
#' @param osm_type Object type (`"node"`, `"way"` or `"relation"`).
#' @param osm_id Object id represented by a numeric or a character value.
#' @param version Version of the object to retrieve.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the objects are saved in a single list column `tags`
#'   containing a `data.frame` for each OSM object with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
#'
#' @return
#' If `format = "R"`, returns a data frame with one OSM object per row. If `format = "xml"`, returns a
#' [xml2::xml_document-class] following the
#' [OSM_XML format](https://wiki.openstreetmap.org/wiki/OSM_XML#OSM_XML_file_format_notes). If `format = "json"`,
#' returns a list with a json structure following the [OSM_JSON format](https://wiki.openstreetmap.org/wiki/OSM_JSON).
#'
# @family get OSM objects' functions
#' @noRd
#'
#' @examples
#' node <- osm_version_object(osm_type = "node", osm_id = 35308286, version = 1)
#' node
#'
#' way <- osm_version_object(osm_type = "way", osm_id = 13073736L, version = 2)
#' way
#'
#' rel <- osm_version_object(osm_type = "relation", osm_id = "40581", version = 3)
#' rel
osm_version_object <- function(osm_type = c("node", "way", "relation"), osm_id, version,
                               format = c("R", "xml", "json"), tags_in_columns = FALSE) {
  osm_type <- match.arg(osm_type)
  format <- match.arg(format)

  if (format == "json") {
    version <- paste0(version, ".json")
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, osm_type, osm_id, version)

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


## Multi fetch: `GET /api/0.6/[nodes|ways|relations]?#parameters` ----
# Allows a user to fetch multiple elements at once.
#
### Parameters ----
# ; [nodes|ways|relations]=comma separated list
# : The parameter has to be the same in the URL (e.g. /api/0.6/nodes?nodes=123,456,789)
# : Version numbers for each object may be optionally provided following a lowercase "v" character, e.g. /api/0.6/nodes?nodes=421586779v1,421586779v2
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : On a malformed request (parameters missing or wrong)
# ; HTTP status code 404 (Not Found)
# : If one of the elements could not be found (By "not found" is meant never existed in the database, if the object was deleted, it will be returned with the attribute visible="false")
# ; HTTP status code 414 (Request-URI Too Large)
# : If the URI was too long (tested to be > 8213 characters in the URI, or > 725 elements for 10 digit IDs when not specifying versions)
#
### Notes ----
# As the multi fetch call returns deleted objects it is the practical way to determine the version at which an object was deleted (useful for example for conflict resolution), the alternative to using this would be the history call that however may potentially require 1000's of version to be processed.

#' Fetch objects
#'
#' Fetch multiple objects of the same type at once.
#'
#' @param osm_type Type of the objects(`"nodes"`, `"ways"` or `"relations"`).
#' @param osm_ids Object ids represented by a numeric or a character vector.
#' @param versions Version numbers for each object may be optionally provided.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the objects are saved in a single list column `tags`
#'   containing a `data.frame` for each OSM object with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
#'
#' @note
#' For downloading data for purposes other than editing or exploring the history of the objects, perhaps is better to
#' use the Overpass API. A similar function to download OSM objects by `type` and `id` using Overpass, is implemented in
#' the \pkg{osmdata} function `opq_osm_id()`.
#'
#' @return
#' If `format = "R"`, returns a data frame with one OSM object per row. If `format = "xml"`, returns a
#' [xml2::xml_document-class] following the
#' [OSM_XML format](https://wiki.openstreetmap.org/wiki/OSM_XML#OSM_XML_file_format_notes). If `format = "json"`,
#' returns a list with a json structure following the [OSM_JSON format](https://wiki.openstreetmap.org/wiki/OSM_JSON).
#'
#' Returned data doesn't follow the same order as `osm_ids` but the order returned by the server which can differ.
#'
# @family get OSM objects' functions
#' @noRd
#'
#' @examples
#' node <- osm_fetch_objects(osm_type = "nodes", osm_ids = c(35308286, 1935675367))
#' node
#'
#' way <- osm_fetch_objects(osm_type = "ways", osm_ids = c(13073736L, 235744929L))
#' way
#'
#' # Specific versions
#' rel <- osm_fetch_objects(osm_type = "relations", osm_ids = c("40581", "341530"), versions = c(3, 1))
#' rel
osm_fetch_objects <- function(osm_type = c("nodes", "ways", "relations"), osm_ids, versions,
                              format = c("R", "xml", "json"), tags_in_columns = FALSE) {
  osm_type <- match.arg(osm_type)
  format <- match.arg(format)

  if (!missing(versions)) {
    osm_ids <- paste0(osm_ids, "v", versions)
  }

  if (format == "json") {
    ext <- paste0(osm_type, ".json")
  } else {
    ext <- osm_type
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, ext)

  ids <- paste(osm_ids, collapse = ",")

  # Avoid ERROR: ! HTTP 414 URI Too Long: tested to be > 8213 characters in the URI
  nchar_base <- nchar(req$url) + nchar(osm_type) + 2
  nchar_url <- nchar(ids) + length(osm_ids) * 2 + nchar_base # `,` in ids encoded in 3 char (%2C)
  if (nchar_url > 8213) {
    out <- fetch_objects_batches(
      osm_type = osm_type, osm_ids = osm_ids, nchar_base = nchar_base,
      format = format, tags_in_columns = tags_in_columns
    )

    return(out)
  }

  if (osm_type == "nodes") {
    req <- httr2::req_url_query(req, nodes = ids)
  } else if (osm_type == "ways") {
    req <- httr2::req_url_query(req, ways = ids)
  } else if (osm_type == "relations") {
    req <- httr2::req_url_query(req, relations = ids)
  }

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


#' Fetch objects in batches
#'
#' Called from [osm_fetch_objects()] to avoid `HTTP ERROR 414 URI Too Long` when characters in the URI > 8213.
#'
#' @inherit osm_fetch_objects
#' @param nchar_base The number of characters of the URL without the parameters `osm_ids` appended.
#'
#' @noRd
fetch_objects_batches <- function(osm_type, osm_ids, nchar_base, format, tags_in_columns) {
  ids <- paste(osm_ids, collapse = ",")
  ids_batch <- 1L
  while (ids_batch[length(ids_batch)] < length(osm_ids)) {
    mis_pos <- ids_batch[length(ids_batch)]:length(osm_ids)
    dist_maxlon <- cumsum(nchar(osm_ids[mis_pos]) + 3) + nchar_base - 3 - 8213 # `,` encoded in 3 char (%2C)
    sel_mispos <- which.min(abs(dist_maxlon))
    sel_pos <- mis_pos[sel_mispos]
    if (dist_maxlon[sel_mispos] > 0) {
      sel_pos <- sel_pos - 1
    }
    ids_batch[length(ids_batch) + 1] <- sel_pos
  }

  obj_batch <- .mapply(
    function(from, to) {
      ids <- osm_ids[from:to]
      osm_fetch_objects(osm_type = osm_type, osm_ids = ids, format = format) # version is already part of osm_ids
    },
    dots = list(
      from = ids_batch[-length(ids_batch)],
      to = c(ids_batch[-c(1, length(ids_batch))] - 1, length(osm_ids))
    ),
    MoreArgs = NULL
  )

  ## Unite batches

  if (format == "R") {
    out <- do.call(rbind, obj_batch)
    rownames(out) <- NULL

    if (tags_in_columns) {
      out <- tags_list2wide(out)
    }
  } else if (format == "xml") {
    out <- obj_batch[[1]]
    lapply(obj_batch[-1], function(x) {
      for (i in seq_len(length(xml2::xml_children(x)))) {
        xml2::xml_add_child(out, xml2::xml_child(x, search = i))
      }
    })
  } else if (format == "json") {
    out <- obj_batch[[1]][setdiff(names(obj_batch[[1]]), "elements")]
    out$elements <- do.call(c, lapply(obj_batch, function(x) x$elements))
  }

  return(out)
}


## Relations for element: `GET /api/0.6/[node|way|relation]/#id/relations` ----
# Returns a XML document containing all (not deleted) relations in which the given element is used.
#
### Notes ----
# * There is no error if the element does not exist.
# * If the element does not exist or it isn't used in any relations an empty XML document is returned (apart from the `<osm>` elements)

#' Relations of an object
#'
#' Returns all (not deleted) relations in which the given object is used.
#'
#' @param osm_type Object type (`"node"`, `"way"` or `"relation"`).
#' @param osm_id Object id represented by a numeric or a character value.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the objects are saved in a single list column `tags`
#'   containing a `data.frame` for each OSM object with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
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
#' node <- osm_relations_object(osm_type = "node", osm_id = 152364165)
#' node
#'
#' way <- osm_relations_object(osm_type = "way", osm_id = 372011578)
#' way
#'
#' rel <- osm_relations_object(osm_type = "relation", osm_id = 342792)
#' rel
osm_relations_object <- function(osm_type = c("node", "way", "relation"), osm_id,
                                 format = c("R", "xml", "json"), tags_in_columns = FALSE) {
  osm_type <- match.arg(osm_type)
  format <- match.arg(format)

  if (format == "json") {
    ext <- "relations.json"
  } else {
    ext <- "relations"
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, osm_type, osm_id, ext)

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


## Ways for node: `GET /api/0.6/node/#id/ways` ----
# Returns a XML document containing all the (not deleted) ways in which the given node is used.
#
### Notes ----
# * There is no error if the node does not exist.
# * If the node does not exist or it isn't used in any ways an empty XML document is returned (apart from the `<osm>` elements)

#' Ways of a node
#'
#' Returns all the (not deleted) ways in which the given node is used.
#'
#' @param node_id Node id represented by a numeric or a character value.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the objects are saved in a single list column `tags`
#'   containing a `data.frame` for each OSM object with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
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
#' ways_node <- osm_ways_node(node_id = 35308286)
#' ways_node
osm_ways_node <- function(node_id, format = c("R", "xml", "json"), tags_in_columns = FALSE) {
  format <- match.arg(format)

  if (format == "json") {
    ext <- "ways.json"
  } else {
    ext <- "ways"
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "node", node_id, ext)

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


## Full: `GET /api/0.6/[way|relation]/#id/full` ----
# This API call retrieves a way or relation and all other elements referenced by it
# * For a way, it will return the way specified plus the full XML of all nodes referenced by the way.
# * For a relation, it will return the following:
# ** The relation itself
# ** All nodes, ways, and relations that are members of the relation
# ** Plus all nodes used by ways from the previous step
# ** The same recursive logic is not applied to relations. This means: If relation r1 contains way w1 and relation r2, and w1 contains nodes n1 and n2, and r2 contains node n3, then a "full" request for r1 will give you r1, r2, w1, n1, and n2. Not n3.
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : When no element with the given id could be found
# ; HTTP status code 410 (Gone)
# : If the element has been deleted

#' Full object
#'
#' This API call retrieves a way or relation and all other objects referenced by it.
#'
#' @param osm_type Object type (`"way"` or `"relation"`).
#' @param osm_id Object id represented by a numeric or a character value.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the objects are saved in a single list column `tags`
#'   containing a `data.frame` for each OSM object with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
#'
#' @details
#' For a way, it will return the way specified plus all nodes referenced by the way.
#' For a relation, it will return the following:
#' * The relation itself
#' * All nodes, ways, and relations that are members of the relation
#' * Plus all nodes used by ways from the previous step
#' * The same recursive logic is not applied to relations. This means: If relation r1 contains way w1 and relation r2,
#'   and w1 contains nodes n1 and n2, and r2 contains node n3, then a "full" request for r1 will give you r1, r2, w1,
#'   n1, and n2. Not n3.
#'
#' @note
#' For downloading data for purposes other than editing or exploring the history of the objects, perhaps is better to
#' use the Overpass API. A similar function to download OSM objects by `type` and `id` using Overpass, is implemented in
#' the \pkg{osmdata} function `opq_osm_id()`.
#'
#' @return
#' If `format = "R"`, returns a data frame with one OSM object per row. If `format = "xml"`, returns a
#' [xml2::xml_document-class] following the
#' [OSM_XML format](https://wiki.openstreetmap.org/wiki/OSM_XML#OSM_XML_file_format_notes). If `format = "json"`,
#' returns a list with a json structure following the [OSM_JSON format](https://wiki.openstreetmap.org/wiki/OSM_JSON).
#'
# @family get OSM objects' functions
#' @noRd
#'
#' @examples
#' way <- osm_full_object(osm_type = "way", osm_id = 13073736)
#' way
#'
#' rel <- osm_full_object(osm_type = "relation", osm_id = "40581")
#' rel
osm_full_object <- function(osm_type = c("way", "relation"), osm_id,
                            format = c("R", "xml", "json"), tags_in_columns = FALSE) {
  osm_type <- match.arg(osm_type)
  format <- match.arg(format)

  if (format == "json") {
    ext <- "full.json"
  } else {
    ext <- "full"
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, osm_type, osm_id, ext)

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


## Redaction: `POST /api/0.6/[node|way|relation]/#id/#version/redact?redaction=#redaction_id` ----
# This is an API method originally created for the [[Open Database License|ODbL license change]] to hide contributions from users that did not accept the new CT/licence. It is now used by the [[Data working group|DWG]] to hide old versions of elements containing data privacy or copyright infringements. All API retrieval request for the element #version will return an HTTP error 403.
#
### Notes ----
# * only permitted for OSM accounts with the moderator role (DWG and server admins)
# * requires either <code>write_redactions</code> or <code>write_api</code> OAuth scope; <code>write_redactions</code> is being phased out
# * the #redaction_id is listed on https://www.openstreetmap.org/redactions
# * more information can be found in [https://git.openstreetmap.org/rails.git/blob/HEAD:/app/controllers/redactions_controller.rb the source]
# * This is an extremely specialized call
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : "Cannot redact current version of element, only historical versions may be redacted."

#' Redact an object version
#'
#' Used by the [Data Working Group](https://wiki.openstreetmap.org/wiki/Data_working_group) to hide old versions of
#' elements containing data privacy or copyright infringements. Only permitted for OSM accounts with the moderator role
#' (DWG and server admins).
#'
#' @param osm_type Object type (`"node"`, `"way"` or `"relation"`).
#' @param osm_id Object id represented by a numeric or a character value.
#' @param version Version of the object to redact.
#' @param redaction_id If missing, then this is an unredact operation. If a redaction ID was specified, then set this
#'   element to be redacted in that redaction.
#'
#' @details
#' The `redaction_id` is listed on <https://www.openstreetmap.org/redactions>. More information can be found in
#' [the source](https://git.openstreetmap.org/rails.git/blob/HEAD:/app/controllers/redactions_controller.rb).
#'
#' @return Nothing is returned upon successful redaction or unredaction of an object.
#' @family functions for moderators
#' @export
#'
#' @examples
#' \dontrun{
#' ## WARNING: this example will edit the OSM (testing) DB with your user!
#' # You will need a user with moderator role in the server to use `osm_redaction_object()`
#' set_osmapi_connection(server = "testing") # setting https://master.apis.dev.openstreetmap.org
#' x <- data.frame(type = "node", lat = 0, lon = 0, name = "Test redaction.")
#' obj <- osmapi_objects(x, tag_columns = "name")
#' changeset_id <- osm_create_changeset(
#'   comment = "Test object redaction",
#'   hashtags = "#testing;#osmapiR"
#' )
#'
#' node_id <- osm_create_object(x = obj, changeset_id = changeset_id)
#' node_osm <- osm_get_objects(osm_type = "node", osm_id = node_id)
#' deleted_version <- osm_delete_object(x = node_osm, changeset_id = changeset_id)
#' redaction <- osm_redaction_object(
#'   osm_type = node_osm$type, osm_id = node_osm$id, version = 1, redaction_id = 1
#' )
#' unredaction <- osm_redaction_object(osm_type = node_osm$type, osm_id = node_osm$id, version = 1)
#' osm_close_changeset(changeset_id = changeset_id)
#' }
osm_redaction_object <- function(osm_type = c("node", "way", "relation"), osm_id, version, redaction_id) {
  osm_type <- match.arg(osm_type)

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, osm_type, osm_id, version, "redact")

  if (!missing(redaction_id)) {
    req <- httr2::req_url_query(req, redaction = redaction_id)
  }

  httr2::req_perform(req)

  invisible()
}
