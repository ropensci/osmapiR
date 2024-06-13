# Vectorized version of .osm_close_note() & .osm_reopen_note()

#' Close or reopen notes
#'
#' Requires authentication.
#'
#' @describeIn osm_close_note Close notes as fixed.
#'
#' @param note_id Note ids represented by a numeric or character vector.
#'
#' @return Returns a data frame with the closed map notes (same format as [osm_get_notes()] with `format = "R"`).
#' @family edit notes' functions
#' @export
#'
#' @examples
#' \dontrun{
#' set_osmapi_connection("testing") # use the testing server
#' note <- osm_create_note(lat = 41.38373, lon = 2.18233, text = "Testing osmapiR")
#' closed_note <- osm_close_note(note$id)
#' closed_note
#' reopened_note <- osm_reopen_note(note$id)
#' reopened_note
#' closed_note <- osm_close_note(note$id) # leave it closed
#' }
osm_close_note <- function(note_id) { # TODO: , format = c("R", "xml", "json")
  out <- lapply(note_id, .osm_close_note)
  out <- do.call(rbind, out)

  return(out)
}


#' @describeIn osm_close_note Reopen closed notes.
#'
#' @export
osm_reopen_note <- function(note_id) { # TODO: , format = c("R", "xml", "json")
  out <- lapply(note_id, .osm_reopen_note)
  out <- do.call(rbind, out)

  return(out)
}
