#' Details of users
#'
#' @param user_id The ids of the users to retrieve the details for, represented by a numeric or a character value (not
#'   the display names).
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
#' @family users' functions
#' @export
#'
#' @examples
#' usrs <- osm_get_user_details(user_id = c(1, 24, 44, 45, 46, 48, 49, 50))
#' usrs
osm_get_user_details <- function(user_id, format = c("R", "xml", "json")) {
  format <- match.arg(format)

  if (length(user_id) == 1) {
    out <- tryCatch( # ! HTTP 404 Not Found. Different from .osm_details_users()
      .osm_details_user(user_id = user_id, format = format),
      error = function(e) {
        switch(format,
          R = empty_user(),
          xml = empty_usr_xml(),
          json = empty_usr_json()
        )
      }
    )
  } else {
    out <- .osm_details_users(user_ids = user_id, format = format)
  }

  return(out)
}


empty_usr_xml <- function() {
  out <- xml2::xml_new_root(
    "osm",
    version = "0.6", generator = "OpenStreetMap server", copyright = "OpenStreetMap and contributors",
    attribution = "http://www.openstreetmap.org/copyright", license = "http://opendatacommons.org/licenses/odbl/1-0/"
  )

  return(out)
}


empty_usr_json <- function() {
  out <- list(
    version = "0.6", generator = "OpenStreetMap server", copyright = "OpenStreetMap and contributors",
    attribution = "http://www.openstreetmap.org/copyright", license = "http://opendatacommons.org/licenses/odbl/1-0/",
    users = list()
  )

  return(out)
}
