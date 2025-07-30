# Vectorized version of .osm_read_user_blocks

#' Read user block
#'
#' @param user_block_id The id of the user block to retrieve represented by a numeric or a character value.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#'
#' @returns
#' If `format = "R"`, returns a data frame with one row with the details of the block.
#'
#' ## `format = "xml"`
#' Returns a [xml2::xml_document-class] with the following format:
#' ``` xml
#' <?xml version="1.0" encoding="UTF-8"?>
#' <osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="http://www.openstreetmap.org/copyright" license="http://opendatacommons.org/licenses/odbl/1-0/">
#'   <user_block id="101" created_at="2025-02-22T02:11:55Z" updated_at="2025-02-22T02:11:55Z" ends_at="2025-02-22T03:11:55Z" needs_view="true">
#'     <user uid="5" user="fakemod1"/>
#'     <creator uid="115" user="fakemod2"/>
#'   </user_block>
#'   <user_block id="100" created_at="2025-02-22T02:11:10Z" updated_at="2025-02-22T02:11:10Z" ends_at="2025-02-22T02:11:10Z" needs_view="true">
#'     <user uid="5" user="fakemod1"/>
#'     <creator uid="115" user="fakemod2"/>
#'   </user_block>
#'   ...
#' </osm>
#' ```
#'
#' ## `format = "json"`
#' Returns a list with the following json structure:
#' ``` json
#' {
#'   "version":"0.6",
#'   "generator":"OpenStreetMap server",
#'   "copyright":"OpenStreetMap and contributors",
#'   "attribution":"http://www.openstreetmap.org/copyright",
#'   "license":"http://opendatacommons.org/licenses/odbl/1-0/",
#'   "user_blocks":[
#'     {
#'       "id":101,
#'       "created_at":"2025-02-22T02:11:55Z",
#'       "updated_at":"2025-02-22T02:11:55Z",
#'       "ends_at":"2025-02-22T03:11:55Z",
#'       "needs_view":true,
#'       "user":{"uid":5,"user":"fakemod1"},
#'       "creator":{"uid":115,"user":"fakemod2"},
#'       "revoker":{"uid":115,"user":"fakemod2"},
#'       "reason":"reason text\r\n\r\nmore reason text"
#'     },
#'     {
#'       "id":100,
#'       "created_at":"2025-02-22T02:11:10Z",
#'       "updated_at":"2025-02-22T02:11:10Z",
#'       "ends_at":"2025-02-22T02:11:10Z",
#'       "needs_view":true,
#'       "user":{"uid":5,"user":"fakemod1"},
#'       "creator":{"uid":115,"user":"fakemod2"},
#'       "revoker":{"uid":115,"user":"fakemod2"},
#'       "reason":"reason text\r\n\r\nmore reason text"
#'     },
#'     ...
#'   ]
#' }
#' ```
#'
#' @family user blocks' functions
#' @export
#'
#' @examples
#' osm_get_user_blocks(1:2)
osm_get_user_blocks <- function(user_block_id, format = c("R", "xml", "json")) {
  format <- match.arg(format)

  if (length(user_block_id) == 1) {
    out <- .osm_read_user_block(user_block_id = user_block_id, format = format)
    if (format == "json") {
      out$user_blocks <- list(out$user_block)
      out$user_block <- NULL
    }
  } else {
    outL <- lapply(user_block_id, function(id) {
      .osm_read_user_block(user_block_id = id, format = format)
    })

    if (format == "R") {
      out <- do.call(rbind, outL)
    } else if (format == "xml") {
      out <- xml2::xml_new_root(outL[[1]])
      for (i in seq_along(outL[-1]) + 1) {
        lapply(xml2::xml_children(outL[[i]]), function(node) {
          xml2::xml_add_child(out, node)
        })
      }
    } else if (format == "json") {
      out <- outL[[1]]
      out$user_blocks <- lapply(outL, function(x) x$user_block)
      out$user_block <- NULL
    }
  }

  return(out)
}
