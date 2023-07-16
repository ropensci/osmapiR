## OSM objects ----
# see sf_print_notes.R
#
# node.xml <- osm_fetch_objects(osm_type = "nodes", osm_ids = c(35308286, 1935675367), format = "xml")
# node <- osm_fetch_objects(osm_type = "nodes", osm_ids = c(35308286, 1935675367))
#
# way.xml <- osm_fetch_objects(osm_type = "ways", osm_ids = c(13073736L, 235744929L), format = "xml")
# way <- osm_fetch_objects(osm_type = "ways", osm_ids = c(13073736L, 235744929L))
#
# # Specific versions
# rel.xml <- osm_fetch_objects(osm_type = "relations", osm_ids = c("40581", "341530"), versions = c(3, 1), format = "xml")
# rel <- osm_fetch_objects(osm_type = "relations", osm_ids = c("40581", "341530"), versions = c(3, 1))


members_as_text <- function(x) UseMethod("members_as_text")

#' @export
members_as_text.way_members <- function(x) {
  paste(length(x), "nodes:", paste(x, collapse = ", "))
}

#' @export
members_as_text.relation_members <- function(x) {
  paste(nrow(x), "members:", paste(apply(x, 1, function(m) paste(m, collapse = "/")), collapse = ", "))
}

#' @export
members_as_text.default <- function(x) {
  ""
}

#' @export
print.osmapi_objects <- function(x, nchar_members = 60, ...) {
  members <- vapply(x$members, members_as_text, FUN.VALUE = "")
  members <- ifelse(nchar(members) > nchar_members, paste0(substr(members, 1, nchar_members), "..."), members)

  y <- x
  x$members <- members
  NextMethod()

  invisible(y)
}


# TODO: rbind.osmapi_objects <- function(...) dbTools::rbind_addColumns(...)


## Comments in changesets and notes ----

comments_as_text <- function(x) UseMethod("comments_as_text")

#' @export
comments_as_text.changeset_comments <- function(x) {
  comments_as_text.comments(x)
}

#' @export
comments_as_text.note_comments <- function(x) {
  comments_as_text.comments(x)
}

comments_as_text.comments <- function(x) {
  users <- paste(unique(x$user), collapse = ", ")
  date_range <- paste(unique(as.Date(range(x$date))), collapse = " to ")
  paste(nrow(x), "comments from", date_range, "by", users)
}

#' @export
comments_as_text.default <- function(x) {
  ""
}


## Changesets ----

#' @export
print.osmapi_changesets <- function(x, nchar_comments = 60, ...) {
  if ("discussion" %in% names(x)) {
    discussion <- vapply(x$discussion, comments_as_text, FUN.VALUE = "")
    discussion <- ifelse(nchar(discussion) > nchar_comments, paste0(substr(discussion, 1, nchar_comments - 3), "..."), discussion)

    y <- x
    x$discussion <- discussion
    NextMethod()

    invisible(y)
  } else {
    NextMethod()
  }
}


## Notes ----

#' @export
print.osmapi_map_notes <- function(x, nchar_comments = 60, ...) {
  comments <- vapply(x$comments, comments_as_text, FUN.VALUE = "")
  comments <- ifelse(nchar(comments) > nchar_comments, paste0(substr(comments, 1, nchar_comments), "..."), comments)

  y <- x
  x$comments <- comments
  NextMethod()

  invisible(y)
}


## GPX traces ----

#' @export
summary.osmapi_gpx <- function(object, ...) {
  if (length(object) == 0) {
    out <- data.frame(n_points = 0L)
    out$variables <- list("")
    out$attributes <- list("")
    return(out)
  }

  out <- lapply(object, function(x) {
    df <- data.frame(n_points = nrow(x))
    df$variables <- list(colnames(x))

    attrs <- attributes(x)
    attrs <- attrs[setdiff(names(attrs), c("names", "row.names", "class"))]
    df$attributes <- list(structure(as.character(attrs), names = names(attrs)))

    return(df)
  })

  df <- do.call(rbind, out)
  df <- cbind(id = gsub("/user/.+/traces/", "", names(out)), df)
  rownames(df) <- NULL

  return(df)
}
