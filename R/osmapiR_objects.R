#' osmapi_objects
#'
#' @param x `data.frame` representing OSM objects as rows. At least it has a `type` column with `node`, `way` or
#'   `relation`.
#' @param tag_columns A vector indicating the name or position of the columns representing tags. If missing, it's
#'   assumed that `tags` column contain the tags (see details).
#'
# @details
# TODO
#'
#' @return An `osmapi_objects`
#' @family get OSM objects' functions
#' @export
#'
#' @examples
#' x <- data.frame(
#'   type = c("node", "node", "way"), id = 1:3, name = c(NA, NA, "My way")
#' )
#' x$members <- list(NULL, NULL, 1:2)
#' obj <- osmapi_objects(x, tag_columns = "name")
#' obj
osmapi_objects <- function(x, tag_columns) {
  stopifnot(is.data.frame(x))
  stopifnot("type" %in% names(x))

  char_cols <- c("type", "id", "version", "changeset", "user", "uid", "lat", "lon")
  char_cols <- intersect(names(x), char_cols)
  x[, char_cols] <- lapply(x[, char_cols], as.character)

  if ("members" %in% names(x)) {
    x$members[x$type == "node"] <- lapply(x$members[x$type == "node"], function(m) NULL)
    x$members[x$type == "way"] <- lapply(x$members[x$type == "way"], new_way_members)
    x$members[x$type == "relation"] <- lapply(x$members[x$type == "relation"], new_relation_members)
  }

  if (!missing(tag_columns)) {
    if (is.character(tag_columns)) {
      if (!is.null(names(tag_columns))) {
        keys <- names(tag_columns)
      } else {
        keys <- tag_columns
      }
      tag_columns <- which(names(x) %in% tag_columns)
      names(tag_columns) <- keys
    } else if (is.logical(tag_columns)) {
      if (!is.null(names(tag_columns))) {
        keys <- names(tag_columns)[tag_columns]
      } else {
        keys <- names(x)[tag_columns]
      }
      tag_columns <- which(tag_columns)
      names(tag_columns) <- keys
    }
    if (is.null(names(tag_columns))) {
      names(tag_columns) <- names(x)[tag_columns]
    }

    tags_list <- apply(x[, tag_columns, drop = FALSE], 1, function(y) {
      out <- stats::na.omit(data.frame(key = names(tag_columns), value = y, row.names = NULL))

      attr(out, "na.action") <- NULL
      rownames(out) <- NULL
      class(out) <- c("tags_df", "data.frame")

      return(out)
    }, simplify = FALSE)

    x <- x[, -tag_columns]
    x$tags <- tags_list
  } else if ("tags" %in% names(x)) {
    x$tags <- lapply(x$tags, new_tags_df)
  }

  obj <- new_osmapi_objects(x)

  return(obj)
}


new_osmapi_objects <- function(x) {
  obj <- x
  class(obj) <- c("osmapi_objects", "data.frame")

  return(obj)
}


validate_osmapi_objects <- function(x) {
  stopifnot(inherits(x, "osmapi_objects"))
  stopifnot(is.data.frame(x))

  col_name <- c(
    "type", "id", "visible", "version", "changeset", "timestamp", "user", "uid", "lat", "lon", "members", "tags"
  )
  names_ok <- setequal(names(x), col_name)
  if (!names_ok) {
    stop("Missing columns: ", paste(setdiff(col_name, names(x)), collapse = ", "))
  }

  class_columns <- list(
    type = "character", id = "character", visible = "logical", version = "integer",
    changeset = "character", timestamp = "POSIXct", user = "character", uid = "character",
    lat = "character", lon = "character", members = "list", tags = "list"
  )
  sel_cols <- intersect(names(x), names(class_columns))
  mapply(
    function(col, cl, col_name) {
      if (!inherits(col, cl)) {
        stop("Column `", col_name, "` is not of `", cl, "` type.")
      }
    },
    col = x[sel_cols], cl = class_columns[sel_cols], col_name = sel_cols
  )

  ok_members <- sapply(x$members, function(y) is.null(y) | inherits(y, "way_members") | inherits(y, "relation_members"))
  if (any(!ok_members)) {
    stop("`members` column must be a list of `NULL`, `way_members` o `relation_members` objects.")
  }

  if (any(!sapply(x$tags, inherits, what = "tags_df"))) {
    stop("`tag` column must be a list of `tags_df` objects, data.frames with `key` and `value` columns.")
  }

  x
}


## members ----

new_way_members <- function(x) {
  stopifnot(is.atomic(x))
  x <- as.character(x)
  class(x) <- "way_members"
  x
}

new_relation_members <- function(x) {
  stopifnot(is.matrix(x))
  stopifnot(is.character(x))
  stopifnot(c("type", "ref") %in% colnames(x))
  class(x) <- "relation_members"
  x
}


## tags_df ----

new_tags_df <- function(x) {
  stopifnot(is.data.frame(x))
  stopifnot(c("key", "value") %in% colnames(x))
  x$key <- as.character(x$key)
  x$value <- as.character(x$value)

  class(x) <- "tags_df"
  x
}
