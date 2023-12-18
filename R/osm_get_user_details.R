#' Details of users
#'
#' @param user_id The ids of the users to retrieve the details for, represented by a numeric or a character value (not
#'   the display names).
#' @param format Format of the output. Can be `R` (default), `xml`, or `json`.
#'
#' @return
#' @family users' functions
#' @export
#'
#' @examples
#' \dontrun{
#' usrs <- osm_details_users(user_ids = c(1, 24, 44, 45, 46, 48, 49, 50))
#' usrs
#' }
osm_get_user_details <- function(user_id, format = c("R", "xml", "json")) {
  format <- match.arg(format)

  if (length(user_id) == 1) {
    out <- osm_details_user(user_id = user_id, format = format)
  } else {
    out <- osm_details_users(user_ids = user_id, format = format)
  }

  return(out)
}
