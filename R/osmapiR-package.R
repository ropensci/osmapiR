#' @details
#' An R interface to [OpenStreetMap API v0.6](https://wiki.openstreetmap.org/wiki/API_v0.6) for fetching and saving raw
#' geodata from/to the OpenStreetMap database. This package allows to access OSM maps data as well as map notes, GPS
#' traces, changelogs and users data. To access the OSM map data for purposes other than editing or exploring the
#' history of the objects see
#' [Related packages](https://github.com/jmaspons/osmapiR/blob/main/README.md#related-packages).
#'
#' You are responsible for following the [API Usage Policy](https://operations.osmfoundation.org/policies/api/).
#' You can modify the user agent of the requests by setting the option `osmapir.user_agent`:
#' ```r
#' options(osmapir.user_agent = "my new user agent")
#' ```
#'
#' Respect and follow the
#' [standards and conventions](https://wiki.openstreetmap.org/wiki/Editing_Standards_and_Conventions) of the
#' OpenStreetMap community. If you plan to do automated edits, check the
#' [Automated Edits code of conduct](https://wiki.openstreetmap.org/wiki/Automated_Edits_code_of_conduct).
#'
#' # Overview of the functions
#' All function starting with `osm_*` include calls to the server.
#'
#' ## OSM objects
#'
#' ### Get OSM objects
#'
#' [osm_bbox_objects()]
#'     Retrieve map data by bounding box
#'
#' [osm_get_objects()]
#'     Get OSM objects
#'
#' [osm_history_object()]
#'     Get the history of an object
#'
#' [osm_relations_object()]
#'     Relations of an object
#'
#' [osm_ways_node()]
#'     Ways of a node
#'
#' [osmapi_objects()]
#'     osmapi_objects
#'
#' ### Edit OSM objects
#'
#' [osm_create_object()]
#'     Create an OSM object
#'
#' [osm_delete_object()]
#'     Delete an OSM object
#'
#' [osm_update_object()]
#'     Update an OSM object
#'
#' ## Changesets
#'
#' Every modification of the standard OSM elements has to reference an open changeset. A changeset may contain tags
#' just like the other elements. A recommended tag for changesets is the key ''comment=*'' with a short human readable
#' description of the changes being made in that changeset. A new changeset can be opened at any time and a changeset
#' may be referenced from multiple API calls. Because of this it can be closed manually as the server can't know when
#' one changeset ends and another should begin. To avoid stale open changesets a mechanism is implemented to
#' automatically close changesets. See [OSM wiki](https://wiki.openstreetmap.org/wiki/Changeset) for details.
#'
#' ### Get changesets
#'
#' [osm_download_changeset()]
#'     Download a changeset in OsmChange format
#'
#' [osm_get_changesets()]
#'     Get changesets
#'
#' [osm_query_changesets()]
#'     Query changesets
#'
#' ### Edit changeset
#'
#' [osm_create_changeset()] [osm_update_changeset()] [osm_close_changeset()]
#'     Create, update, or close a changeset
#'
#' [osm_diff_upload_changeset()]
#'     Diff (OsmChange format) upload to a changeset
#'
#' ### Changeset's discussion"
#'
#' [osm_comment_changeset_discussion()]
#'     Comment a changeset
#'
#' [osm_hide_comment_changeset_discussion()] [osm_unhide_comment_changeset_discussion()]
#'     Hide or unhide a changeset comment
#'
#' [osm_subscribe_changeset_discussion()] [osm_unsubscribe_changeset_discussion()]
#'     Subscribe or unsubscribe to a changeset discussion
#'
#' ## Map notes
#'
#' This functions provides access to the [notes](https://wiki.openstreetmap.org/wiki/Notes) feature, which allows users
#' to add geo-referenced textual \"post-it\" notes.
#'
#' ### Get map notes
#'
#' [osm_feed_notes()]
#'     RSS Feed of notes in a bbox
#'
#' [osm_get_notes()]
#'     Get notes
#'
#' [osm_read_bbox_notes()]
#'     Retrieve notes by bounding box
#'
#' [osm_search_notes()]
#'     Search for notes
#'
#' ### Edit map notes
#'
#' osm_close_note()] [osm_reopen_note()]
#'     Close or reopen a note
#'
#' [osm_create_comment_note()]
#'     Create a new comment in a note
#'
#' [osm_create_note()]
#'     Create a new note
#'
#' [osm_delete_note()]
#'     Delete a note
#'
#' ## GPS' traces
#'
#' In violation of the [GPX standard](https://www.topografix.com/GPX/1/1/#type_trksegType) when downloading public GPX
#' traces through the API, all waypoints of non-trackable traces are randomized (or rather sorted by lat/lon) and
#' delivered as one trackSegment for privacy reasons. Trackable traces are delivered, sorted by descending upload time,
#' before the waypoints of non-trackable traces.
#'
#' ### Get GPS traces
#'
#' [osm_get_data_gpx()]
#'     Download GPS Track Data
#'
#' [osm_get_gpx_metadata()]
#'     Download GPS Track Metadata
#'
#' [osm_get_points_gps()]
#'     Get GPS Points
#'
#' [osm_list_gpxs()]
#'     List user's GPX traces
#'
#' ### Edit GPS traces
#'
#' [osm_create_gpx()]
#'     Create GPS trace
#'
#' [osm_delete_gpx()]
#'     Delete GPS trace
#'
#' [osm_update_gpx()]
#'     Update GPS trace
#'
#' ## Users
#'
#' [osm_details_logged_user()]
#'     Details of the logged-in user
#'
#' [osm_get_preferences_user()] [osm_set_preferences_user()]
#'     Get or set preferences of the logged-in user
#'
#' [osm_get_user_details()]
#'     Details of users
#'
#' ## OsmChange
#'
#' The [OsmChange](https://wiki.openstreetmap.org/wiki/OsmChange) format can be uploaded to the server. This is
#' guaranteed to be running in a transaction. So either all the changes are applied or none. To avoid performance
#' issues when uploading multiple objects, the use of the [osm_diff_upload_changeset()] is highly recommended.
#'
#' [osm_diff_upload_changeset()]
#'     Diff (OsmChange format) upload to a changeset
#'
#' [osm_download_changeset()]
#'     Download a changeset in OsmChange format
#'
#' [osmchange_create()]
#'     osmchange to create OSM objects
#'
#' [osmchange_delete()]
#'     osmchange to delete existing OSM objects
#'
#' [osmchange_modify()]
#'     osmchange to modify existing OSM objects
#'
#' ## Methods
#'
#' [tags_list2wide()] [tags_wide2list()]
#'     Change tags from a list column <-> columns for each key in wide format
#'
#' ## API
#'
#' [set_osmapi_connection()] [get_osmapi_url()] [set_osmapi_url()]
#'     Configure connections from osmapiR
#'
#' [authenticate_osmapi()] [logout_osmapi()]
#'     Authenticate or logout osmapiR
#'
#' [osm_api_versions()]
#'     Available API versions
#'
#' [osm_capabilities()]
#'     Capabilities of the API
#'
#' [osm_permissions()]
#'     Retrieving permissions
#'
#' ## For moderators
#'
#' [osm_delete_note()]
#'     Delete a note
#'
#' [osm_hide_comment_changeset_discussion()] [osm_unhide_comment_changeset_discussion()]
#'     Hide or unhide a changeset comment
#'
#' [osm_redaction_object()]
#'     Redact an object version
#'
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
