# Vectorized version of .osm_delete_gpx()

#' Delete GPS traces
#'
#' Use this to delete GPX files. Only usable by the owner account. Requires authentication.
#'
#' @param gpx_id The track ids represented by a numeric or a character vector.
#'
#' @return Returns `NULL` invisibly.
#' @family edit GPS traces' functions
#' @export
#'
#' @examples
#' vignette("how_to_edit_gps_traces", package = "osmapiR")
osm_delete_gpx <- function(gpx_id) {
  lapply(gpx_id, .osm_delete_gpx)

  invisible()
}
