## OSM objects ----

#' @export
print.osmapi_objects <- function(x, nchar_members = 60, nchar_tags = 80, ...) {
  y <- x

  if ("members" %in% names(x)) {
    members <- vapply(x$members, members_as_text, FUN.VALUE = "")
    members <- ifelse(nchar(members) > nchar_members, paste0(substr(members, 1, nchar_members), "..."), members)
    x$members <- members
  }

  if ("tags" %in% names(x)) {
    tags <- vapply(x$tags, tags_as_text, FUN.VALUE = "")
    tags <- ifelse(nchar(tags) > nchar_tags, paste0(substr(tags, 1, nchar_tags), "..."), tags)
    x$tags <- tags
  }

  NextMethod()

  invisible(y)
}


# TODO: rbind.osmapi_objects <- function(...) dbTools::rbind_addColumns(...) fot tags in wide format


## OsmChange ----

#' @export
print.osmapi_OsmChange <- function(x, nchar_members = 60, nchar_tags = 80, ...) {
  if (inherits(x, "osmapi_objects")) {
    NextMethod()
  } else {
    y <- x

    if ("members" %in% names(x)) {
      members <- vapply(x$members, members_as_text, FUN.VALUE = "")
      members <- ifelse(nchar(members) > nchar_members, paste0(substr(members, 1, nchar_members), "..."), members)
      x$members <- members
    }

    if ("tags" %in% names(x)) {
      tags <- vapply(x$tags, tags_as_text, FUN.VALUE = "")
      tags <- ifelse(nchar(tags) > nchar_tags, paste0(substr(tags, 1, nchar_tags), "..."), tags)
      x$tags <- tags
    }

    NextMethod()

    invisible(y)
  }
}


## Changesets ----

#' @export
print.osmapi_changesets <- function(x, nchar_comments = 60, nchar_tags = 80, ...) {
  y <- x

  if ("discussion" %in% names(x)) {
    disc <- vapply(x$discussion, comments_as_text, FUN.VALUE = "")
    disc <- ifelse(nchar(disc) > nchar_comments, paste0(substr(disc, 1, nchar_comments - 3), "..."), disc)
    x$discussion <- disc
  }

  if ("tags" %in% names(x)) {
    tags <- vapply(x$tags, tags_as_text, FUN.VALUE = "")
    tags <- ifelse(nchar(tags) > nchar_tags, paste0(substr(tags, 1, nchar_tags), "..."), tags)
    x$tags <- tags
  }

  NextMethod()

  invisible(y)
}


## Notes ----

#' @export
print.osmapi_map_notes <- function(x, nchar_comments = 60, ...) {
  if ("comments" %in% names(x)) {
    comments <- vapply(x$comments, comments_as_text, FUN.VALUE = "")
    comments <- ifelse(nchar(comments) > nchar_comments, paste0(substr(comments, 1, nchar_comments), "..."), comments)
  }

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


## Object members ----

members_as_text <- function(x) UseMethod("members_as_text")

#' @export
members_as_text.way_members <- function(x) {
  intro <- paste(length(x), if (length(x) == 1) "node:" else "nodes:")
  paste(intro, paste(x, collapse = ", "))
}

#' @export
members_as_text.relation_members <- function(x) {
  paste(nrow(x), "members:", paste(apply(x, 1, function(m) paste(m, collapse = "/")), collapse = ", "))
}

#' @export
members_as_text.default <- function(x) {
  "NULL"
}


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

#' @export
comments_as_text.comments <- function(x) {
  intro <- paste(nrow(x), if (nrow(x) == 1) "comment" else "comments", "from")
  users <- paste(unique(x$user), collapse = ", ")
  if (all(is.na(unique(x$user)))) {
    users <- "anonymous user"
  }
  date_range <- paste(unique(as.Date(range(x$date))), collapse = " to ")
  paste(intro, date_range, "by", users)
}

#' @export
comments_as_text.default <- function(x) {
  "NULL"
}


## Tags ----

tags_as_text <- function(x) UseMethod("tags_as_text")

#' @export
tags_as_text.tags_df <- function(x) {
  if (nrow(x) > 0) {
    tags <- paste0(x$key, "=", x$value)
    intro <- paste(nrow(x), if (nrow(x) == 1) "tag:" else "tags:")
    out <- paste(intro, paste(tags, collapse = " | "))
  } else {
    out <- "No tags"
  }

  return(out)
}

#' @export
tags_as_text.default <- function(x) {
  "NULL"
}
