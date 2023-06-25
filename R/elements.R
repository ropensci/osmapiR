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
#
### Notes ----
# * This updates the bounding box of the changeset.
# * The ''role'' attribute for relations is optional. An empty string is the default.
# * To avoid performance issues when uploading multiple objects, the use of the [[API v0.6#Diff upload: POST /api/0.6/changeset/#id/upload|Diff upload]] endpoint is highly recommended.

## TODO ----
osm_create_object <- function(osm_type = c("node", "way", "relation"), ...) {
  osm_type <- match.arg(osm_type)

  req <- osmapi_request()
  req <- httr2::req_method(req, "PUT")
  req <- httr2::req_url_path_append(req, osm_type, "create")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
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

osm_read_object <- function(osm_type = c("node", "way", "relation"), osm_id) {
  osm_type <- match.arg(osm_type)

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, osm_type, osm_id)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
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
#
### Notes ----
# * This updates the bounding box of the changeset.
# * To avoid performance issues when updating multiple objects, the use of the [[API v0.6#Diff upload: POST /api/0.6/changeset/#id/upload|Diff upload]] endpoint is highly recommended. This is also the only way to ensure that multiple objects are updated in a single database transaction.

osm_update_object <- function(osm_type = c("node", "way", "relation"), osm_id) {
  osm_type <- match.arg(osm_type)

  req <- osmapi_request()
  req <- httr2::req_method(req, "PUT")
  req <- httr2::req_url_path_append(req, osm_type, osm_id)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
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
#
### Notes ----
# * In earlier API versions no payload was required. It is needed now because of the need for changeset IDs and version numbers.
# * To avoid performance issues when updating multiple objects, the use of the Diff upload endpoint is highly recommended. This is also the only way to ensure that multiple objects are updated in a single database transaction.

osm_delete_object <- function(osm_type = c("node", "way", "relation"), osm_id) {
  osm_type <- match.arg(osm_type)

  req <- osmapi_request()
  req <- httr2::req_method(req, "DELETE")
  req <- httr2::req_url_path_append(req, osm_type, osm_id)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}


## History: `GET /api/0.6/[node|way|relation]/#id/history` ----
# Retrieves all old versions of an element. ([https://api.openstreetmap.org/api/0.6/way/250066046/history example])
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : When no element with the given id could be found

osm_history_object <- function(osm_type = c("node", "way", "relation"), osm_id) {
  osm_type <- match.arg(osm_type)

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, osm_type, osm_id, "history")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}


## Version: `GET /api/0.6/[node|way|relation]/#id/#version` ----
# Retrieves a specific version of the element.
#
### Error codes ----
# ; HTTP status code 403 (Forbidden)
# : When the version of the element is not available (due to redaction)
# ; HTTP status code 404 (Not Found)
# : When no element with the given id could be found

osm_read_object <- function(osm_type = c("node", "way", "relation"), osm_id, osm_version) {
  osm_type <- match.arg(osm_type)

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, osm_type, osm_id, osm_version)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
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

osm_read_object <- function(osm_type = c("nodes", "ways", "relations"), osm_ids) {
  osm_type <- match.arg(osm_type)

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, osm_type)

  if (osm_type == "nodes") {
    req <- httr2::req_url_query(req, nodes = paste(osm_ids, collapse = ","))
  } else if (osm_type == "ways") {
    req <- httr2::req_url_query(req, ways = paste(osm_ids, collapse = ","))
  } else if (osm_type == "relations") {
    req <- httr2::req_url_query(req, relations = paste(osm_ids, collapse = ","))
  }

  # TODO: Error in `resp_abort()`: ! HTTP 404 Not Found. ----

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}


## Relations for element: `GET /api/0.6/[node|way|relation]/#id/relations` ----
# Returns a XML document containing all (not deleted) relations in which the given element is used.
#
### Notes ----
# * There is no error if the element does not exist.
# * If the element does not exist or it isn't used in any relations an empty XML document is returned (apart from the `<osm>` elements)

osm_relations_object <- function(osm_type = c("node", "way", "relation"), osm_id) {
  osm_type <- match.arg(osm_type)

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, osm_type, osm_id, "relations")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}


## Ways for node: `GET /api/0.6/node/#id/ways` ----
# Returns a XML document containing all the (not deleted) ways in which the given node is used.
#
### Notes ----
# * There is no error if the node does not exist.
# * If the node does not exist or it isn't used in any ways an empty XML document is returned (apart from the `<osm>` elements)

osm_ways_node <- function(osm_id) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "node", osm_id, "ways")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
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

osm_full_object <- function(osm_type = c("node", "way", "relation"), osm_id) {
  osm_type <- match.arg(osm_type)

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, osm_type, osm_id, "full")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}


## Redaction: `POST /api/0.6/[node|way|relation]/#id/#version/redact?redaction=#redaction_id` ----
# This is an API method originally created for the [[Open Database License|ODbL license change]] to hide contributions from users that did not accept the new CT/licence. It is now used by the [[Data working group|DWG]] to hide old versions of elements containing data privacy or copyright infringements. All API retrieval request for the element #version will return an HTTP error 403.
#
### Notes ----
# * only permitted for OSM accounts with the moderator role (DWG and server admins)
# * the #redaction_id is listed on https://www.openstreetmap.org/redactions
# * more information can be found in [https://git.openstreetmap.org/rails.git/blob/HEAD:/app/controllers/old_controller.rb the source]
# * This is an extremely specialized call
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : "Cannot redact current version of element, only historical versions may be redacted."

osm_read_object <- function(osm_type = c("node", "way", "relation"), osm_id, osm_version, redaction_id) {
  osm_type <- match.arg(osm_type)

  req <- osmapi_request()
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, osm_type, osm_id, osm_version)
  req <- httr2::req_url_query(redaction = redaction_id)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}
