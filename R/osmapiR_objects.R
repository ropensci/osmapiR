#' osmapi_objects constructor
#'
#' @param x `data.frame` representing OSM objects as rows. At least it has a `type` column with `node`, `way` or
#'   `relation`.
#' @param tag_columns A vector indicating the name or position of the columns representing tags. If missing, it's
#'   assumed that `tags` column contain the tags (see details).
#' @param keep_na_tags If `TRUE`, don't drop the empty tags specified in `tag_columns` and add `NA` as a value.
#'   Useful to remove specific tags with [osmchange_modify()] and specific `tag_keys`.
#'
# TODO: @details
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
osmapi_objects <- function(x, tag_columns, keep_na_tags = FALSE) {
  stopifnot(is.data.frame(x))
  stopifnot("type" %in% names(x))

  char_cols <- c("type", "id", "version", "changeset", "user", "uid", "lat", "lon")
  char_cols <- intersect(names(x), char_cols)
  x[, char_cols] <- lapply(x[, char_cols], as.character)

  if ("members" %in% names(x)) {
    x$members[x$type == "node"] <- lapply(x$members[x$type == "node"], function(m) NULL)
    x$members[x$type == "way"] <- lapply(x$members[x$type == "way"], new_way_members)
    x$members[x$type == "relation"] <- lapply(x$members[x$type == "relation"], new_relation_members)
  } else {
    x$members[x$type == "node"] <- lapply(seq_len(sum(x$type == "node")), function(m) NULL)
    x$members[x$type == "way"] <- lapply(seq_len(sum(x$type == "way")), function(m) new_way_members())
    x$members[x$type == "relation"] <- lapply(
      seq_len(sum(x$type == "relation")), function(m) new_relation_members()
    )
  }

  if (!missing(tag_columns)) {
    if (is.character(tag_columns)) {
      if (!is.null(names(tag_columns))) {
        keys <- names(tag_columns)
      } else {
        keys <- tag_columns
      }
      tag_columns <- match(tag_columns, names(x))
      names(tag_columns) <- keys
      tag_columns <- sort(tag_columns)
    } else if (is.logical(tag_columns)) {
      stopifnot(length(tag_columns) == ncol(x))
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

    if (nrow(x) == 0) {
      x <- x[, -tag_columns]
      x$tags <- list()
      return(new_osmapi_objects(x))
    }

    tags_list <- apply(x[, tag_columns, drop = FALSE], 1, function(y) {
      out <- data.frame(key = names(tag_columns), value = y, row.names = NULL)
      if (!keep_na_tags) {
        out <- stats::na.omit(out)
      }

      attr(out, "na.action") <- NULL
      rownames(out) <- NULL
      class(out) <- c("tags_df", "data.frame")

      return(out)
    }, simplify = FALSE)

    x <- x[, -tag_columns]
    x$tags <- tags_list
  } else if ("tags" %in% names(x)) {
    x$tags <- lapply(x$tags, new_tags_df)
  } else {
    x$tags <- lapply(seq_len(nrow(x)), function(i) new_tags_df())
  }

  obj <- new_osmapi_objects(x)

  return(obj)
}


new_osmapi_objects <- function(x) {
  obj <- x
  class(obj) <- c("osmapi_objects", "data.frame")

  return(obj)
}


#' Validate `osmapi_objects`
#'
#' @param x An `osmapi_objects`
#' @param commited If `TRUE`, `x` must have columns `visible`, `version`, `changeset`, `timestamp`, `user` & `uid`.
#'
#' @return `x`
#' @noRd
validate_osmapi_objects <- function(x, commited = TRUE) {
  stopifnot(inherits(x, "osmapi_objects"))
  stopifnot(is.data.frame(x))

  col_name <- c("type", "id", "lat", "lon", "members", "tags")
  if (commited) {
    col_name <- c(col_name, "visible", "version", "changeset", "timestamp", "user", "uid")
  }
  names_ok <- all(col_name %in% names(x))

  if (!names_ok) {
    stop("Missing columns: ", paste(setdiff(col_name, names(x)), collapse = ", "))
  }

  class_columns <- list(
    type = "character", id = "character", visible = "logical", version = "integer",
    changeset = "character", timestamp = "POSIXct", user = "character", uid = "character",
    lat = "character", lon = "character", members = "list", tags = "list"
  )
  sel_cols <- intersect(names(x), names(class_columns))
  .mapply(
    function(col, cl, col_name) {
      if (!inherits(col, cl)) {
        stop("Column `", col_name, "` is not of `", cl, "` type.")
      }
    },
    dots = list(col = x[sel_cols], cl = class_columns[sel_cols], col_name = sel_cols),
    MoreArgs = NULL
  )

  ok_members <- vapply(
    x$members,
    function(y) is.null(y) | inherits(y, "way_members") | inherits(y, "relation_members"),
    logical(1)
  )
  if (any(!ok_members)) {
    stop("`members` column must be a list of `NULL`, `way_members` o `relation_members` objects.")
  }

  if (any(!vapply(x$tags, function(y) inherits(y, what = "tags_df"), logical(1)))) {
    stop("`tag` column must be a list of `tags_df` objects, data.frames with `key` and `value` columns.")
  }

  x
}


## members ----

new_way_members <- function(x = character()) {
  stopifnot(is.atomic(x))
  x <- as.character(x)
  class(x) <- "way_members"
  x
}

new_relation_members <- function(x = matrix(character(), nrow = 0, ncol = 2, dimnames = list(NULL, c("type", "ref")))) {
  stopifnot(is.matrix(x))
  stopifnot(is.character(x))
  stopifnot(c("type", "ref") %in% colnames(x))
  class(x) <- "relation_members"
  x
}


## tags_df ----

new_tags_df <- function(x = data.frame(key = character(), value = character())) {
  stopifnot(is.data.frame(x))
  stopifnot(c("key", "value") %in% colnames(x))
  x$key <- as.character(x$key)
  x$value <- as.character(x$value)

  class(x) <- c("tags_df", "data.frame")
  x
}
