#' Change `tags` from a list column <-> columns for each key in wide format
#'
#' Objects of classes `osmapi_objects` and `osmapi_changesets` can represent the tags in a column with a list with
#' a data.frame for each row with 2 columns for keys and values, or by columns for each key. These functions allow
#' to change the format of the tags.
#'
#' @rdname tags_list-wide
#' @param x An `osmapi_objects` or `osmapi_changesets` objects as returned by, for example, [osm_get_objects()] or
#'   [osm_get_changesets()].
#'
#' @details
#' Both formats have advantages. Tags in a list of data.frames is a more compact representation and there is no risk of
#' clashes of column names and tag keys. Tags in columns make it easier to select rows by tags as in a regular
#' data.frame. Column name clashes are resolved and the original key names restored when transformed to tags list
#' format.
#'
#' By default, functions returning `osmapi_objects` or `osmapi_changesets` objects, use the the tags in a list column,
#' but can return the results in a wide format using the parameter `tags_in_columns = TRUE`.
#'
#' @return
#' A data frame with the same class and data than the original (`osmapi_objects` or `osmapi_changesets`) but with the
#' specified tags' format.
#'
#' @family methods
#' @export
#'
#' @examples
#' \dontrun{
#' peaks_wide <- osm_get_objects(
#'   osm_type = "nodes", osm_id = c(35308286, 1935675367), tags_in_columns = TRUE
#' )
#' peaks_list <- tags_wide2list(peaks_wide)
#'
#' # tags in list format
#' peaks_list$tags
#'
#' # Select peaks with `prominence` tag
#' peaks_wide[!is.na(peaks_wide$prominence), ]
#' peaks_list[sapply(peaks_list$tags, function(x) any(x$key == "prominence")), ]
#'
#' cities_list <- osm_get_objects(osm_type = "relations", osm_id = c("40581", "341530"))
#' # Column name clash:
#' cities_wide <- tags_list2wide(cities_list)
#' }
tags_list2wide <- function(x) {
  if (!inherits(x, "osmapi_objects") && !inherits(x, "osmapi_changesets")) {
    stop("x must be an `osmapi_objects` or `osmapi_changesets` object.")
  }

  if (inherits(x, "tags_wide")) {
    message("x is already in a tags wide format.")

    return(x)
  }

  cols <- sort(unique(unlist(lapply(x$tags, function(y) y$key))))
  # WARNING: sort different than API ([A-Z][a-z][0-9] vs [0-9][a-z][A-Z])

  tags_wide <- structure(
    t(vapply(x$tags, function(y) structure(y$value, names = y$key)[cols], FUN.VALUE = character(length(cols)))),
    dimnames = list(NULL, cols)
  )

  out <- x[, setdiff(names(x), "tags")]
  if (inherits(x, "osmapi_objects")) {
    names(out) <- gsub("^(type|id)$", "osm_\\1", names(out))
  }
  out <- cbind(out, tags_wide)
  out <- fix_duplicated_columns(out)

  attr(out, "tag_columns") <- structure(ncol(x):ncol(out), names = cols)

  class(out) <- c(setdiff(class(x), "data.frame"), "tags_wide", "data.frame")

  return(out)
}


#' @rdname tags_list-wide
#' @export
tags_wide2list <- function(x) {
  if (!inherits(x, "osmapi_objects") && !inherits(x, "osmapi_changesets")) {
    stop("x must be an `osmapi_objects` or `osmapi_changesets` object.")
  }

  if (!inherits(x, "tags_wide")) {
    message("x is already in a tags list column format.")

    return(x)
  }

  keys <- attr(x, "tag_columns")
  tags_list <- apply(x[, keys], 1, function(y) {
    out <- stats::na.omit(data.frame(key = names(keys), value = y, row.names = NULL))

    attr(out, "na.action") <- NULL
    rownames(out) <- NULL
    class(out) <- c("tags_df", "data.frame")

    return(out)
  }, simplify = FALSE)

  out <- x[, -keys]
  out$tags <- tags_list

  if (inherits(x, "osmapi_objects")) {
    names(out) <- gsub("^osm_(type|id)$", "\\1", names(out))
  }

  class(out) <- setdiff(class(x), "tags_wide")

  return(out)
}


fix_duplicated_columns <- function(x) {
  cols_ori <- names(x)

  dup <- duplicated(names(x))
  i <- 1
  while (any(dup)) {
    names(x)[dup] <- paste0(names(x)[dup], ".", i)
    i <- i + 1
    dup <- duplicated(names(x))
  }

  if (!identical(names(x), cols_ori)) {
    warning(
      "Tag's keys clash with other columns and will be renamed by appending `.n`:\n\t",
      paste(setdiff(names(x), cols_ori), collapse = ", ")
    )
  }

  return(x)
}
