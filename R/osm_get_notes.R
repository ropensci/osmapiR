# Vectorized version of osm_read_note

#' Get notes
#'
#' Returns the existing note with the given ID.
#'
#' @param note_id Note id represented by a numeric or a character value.
#' @param format Format of the output. Can be `R` (default), `xml`, `rss`, `json` or `gpx`.
#'
#' @return
#' If `format = "R"`, returns a data frame with one map note per row. If `format = "json"`, returns a list with the json
#' structure. For `format` in `xml`, `rss`, and `gpx`, a [xml2::xml_document-class] with the corresponding format.
#' @family get notes' functions
#' @export
#'
#' @examples
#' \dontrun{
#' note <- osm_get_notes(note_id = "2067786")
#' note
#' }
osm_get_notes <- function(note_id, format = c("R", "xml", "rss", "json", "gpx")) {
  format <- match.arg(format)

  if (length(note_id) == 1) {
    out <- osm_read_note(note_id = note_id, format = format)
  } else {
    outL <- lapply(note_id, function(id) {
      osm_read_note(note_id = id, format = format)
    })

    if (format == "R") {
      out <- do.call(rbind, outL)
    } else if (format %in% c("xml", "rss", "gpx")) {
      out <- xml2::xml_new_root(outL[[1]])
      for (i in seq_len(length(outL) - 1)) {
        xml2::xml_add_child(out, xml2::xml_child(outL[[i + 1]]))
      }
# TODO: remove namespaces for format %in% c("rss", "gpx"). xml2::xml_structure(out) [<wpt [lon, lat]> VS <wpt [lon, lat, xmlns]>]
      # xml namespace https://community.rstudio.com/t/adding-nodes-in-xml2-how-to-avoid-duplicate-default-namespaces/84870/
    } else if (format == "json") {
      out <- outL
    }
  }

  return(out)
}

