# Vectorized version of .osm_delete_note()

#' Delete notes
#'
#' Hide (delete) notes. This request needs to be done as an authenticated user with moderator role.
#'
#' @param note_id Note ids represented by a numeric or a character vector.
#' @param text A non-mandatory comment as text.
#'
#' @details Use [osm_reopen_note()] to make the note visible again.
#'
#' @return Returns a data frame with the hided map notes (same format as [osm_get_notes()] with `format = "R"`).
#' @family edit notes' functions
#' @family functions for moderators
#' @export
#'
#' @examples
#' \dontrun{
#' set_osmapi_connection("testing") # use the testing server
#' note <- osm_create_note(lat = "40.7327375", lon = "0.1702526", text = "Test note to delete.")
#' del_note <- osm_delete_note(note_id = note$id, text = "Hide note")
#' del_note
#' }
osm_delete_note <- function(note_id, text) { # TODO: , format = c("R", "xml", "json")
  if (missing(text)) {
    out <- lapply(note_id, function(id) .osm_delete_note(note_id = id))
  } else {
    if (length(text) != 1 || length(text) != length(note_id)) {
      stop("`text` must have the same length as `note_id` or a length of 1 (the same message for all notes).")
    }
    out <- .mapply(.osm_delete_note, dots = list(note_id = note_id, text = text), MoreArgs = NULL)
  }

  out <- do.call(rbind, out)

  return(out)
}
