tags_xml2DF <- function(xml_nodeset) {
  tags <- xml2::xml_find_all(xml_nodeset, xpath = ".//tag", flatten = FALSE)
  tags_u <- xml2::xml_find_all(xml_nodeset, xpath = ".//tag")
  col_names <- sort(unique(xml2::xml_attr(tags_u, attr = "k")))
  m <- matrix(nrow = length(tags), ncol = length(col_names), dimnames = list(NULL, col_names))
  has_tags <- which(vapply(tags, length, FUN.VALUE = integer(1)) > 0)
  for (i in has_tags) {
    tag <- xml2::xml_attrs(tags[[i]])
    tagV <- vapply(tag, function(x) x, FUN.VALUE = character(2))
    m[i, tagV[1, ]] <- tagV[2, ]
  }

  return(m)
}


## Changesets ----

# osm_download_changeset() in osmChange xml format. Not related

changeset_xml2DF <- function(xml) {
  changesets <- xml2::xml_children(xml)

  changeset_attrs <- do.call(rbind, xml2::xml_attrs(changesets))

  # read & query changeset calls have different order in attributes.
  ord_cols <- c(
    "id", "created_at", "closed_at", "open", "user", "uid",
    "min_lat", "min_lon", "max_lat", "max_lon", "comments_count", "changes_count"
  )
  out <- data.frame(changeset_attrs[, ord_cols, drop = FALSE])

  out$open <- ifelse(out$open == "true", TRUE, FALSE)
  out$comments_count <- as.integer(out$comments_count)
  out$changes_count <- as.integer(out$changes_count)
  out$created_at <- as.POSIXct(out$created_at)
  out$closed_at <- as.POSIXct(out$closed_at)

  discussion <- xml2::xml_child(changesets, "discussion")

  if (!all(is.na(discussion))) {
    discussionL <- lapply(xml2::xml_find_all(discussion, xpath = ".//comment", flatten = FALSE), function(x) {
      if (length(x) == 0) {
        return(NA)
      }
      comment_attrs <- do.call(rbind, xml2::xml_attrs(x))
      comment_text <- xml2::xml_text(xml2::xml_child(x, "text"))
      dis <- data.frame(comment_attrs, comment_text)
      dis$date <- as.POSIXct(dis$date)

      return(dis)
    })

    out$discussion <- discussionL
  }

  tags <- tags_xml2DF(changesets)
  out <- cbind(out, tags)

  # out$discussion ## TODO: improve print. class?

  return(out)
}


## Elements ----
## TODO: warning in  osm_bbox_objects(bbox = c(3.2164192, 42.0389667, 3.2317829, 42.0547099))

object_xml2DF <- function(xml) {
  objects <- xml2::xml_children(xml)

  if (length(objects) == 0) {
    out <- data.frame(
      type = character(), id = character(), visible = character(), version = character(), changeset = character(),
      timestamp = character(), user = character(), uid = character(), lat = character(), lon = character()
    )
    return(out)
  }

  object_type <- xml2::xml_name(objects)

  if (object_type[1] == "bounds") { # osm_bbox_objects()

    bbox <- xml2::xml_attrs(objects[[1]])
    objects <- objects[-1]
    object_type <- object_type[-1]

    if (length(objects) == 0) {
      out <- data.frame(
        type = character(), id = character(), visible = character(), version = character(), changeset = character(),
        timestamp = character(), user = character(), uid = character(), lat = character(), lon = character()
      )
      attr(out, "bbox") <- bbox

      return(out)
    }
  } else {
    bbox <- NULL
  }

  object_attrs <- do.call(rbind, xml2::xml_attrs(objects))
  tags <- tags_xml2DF(objects)

  members <- vector("list", length = length(objects))
  members[object_type == "way"] <- lapply(objects[object_type == "way"], function(x) {
    xml2::xml_attr(xml2::xml_find_all(x, ".//nd"), "ref")
  })

  members[object_type == "relation"] <- lapply(objects[object_type == "relation"], function(x) {
    do.call(rbind, xml2::xml_attrs(xml2::xml_find_all(x, ".//member")))
  })

  out <- data.frame(type = object_type, object_attrs)
  out$visible <- ifelse(out$visible == "true", TRUE, FALSE)
  out$version <- as.integer(out$version)
  out$timestamp <- as.POSIXct(out$timestamp)

  out$members <- members

  out <- cbind(out, tags)

  if (!is.null(bbox)) {
    attr(out, "bbox") <- bbox
  }

  # out$members ## TODO: improve print. class?

  return(out)
}


## GPS traces ----

gpx_meta_xml2DF <- function(xml) {
  gpx_files <- xml2::xml_children(xml)

  gpx_attrs <- do.call(rbind, xml2::xml_attrs(gpx_files))
  description <- xml2::xml_text(xml2::xml_child(gpx_files, "description"))
  tags <- lapply(xml2::xml_find_all(gpx_files, ".//tag", flatten = FALSE), xml2::xml_text)

  out <- data.frame(gpx_attrs, description)
  out$timestamp <- as.POSIXct(out$timestamp)
  out$pending <- ifelse(out$pending == "true", TRUE, FALSE)

  out$tags <- tags

  return(out)
}


# GPX files----

gpx_xml2DF <- function(xml) {
  # xml_attrs <- xml2::xml_attrs(xml)

  gpx <- xml2::xml_children(xml)

  trk <- gpx[xml2::xml_name(gpx) == "trk"]
  # xml_find_all(trk, xpath = ".//name") ## TODO: doesn't work :(

  trkL <- lapply(trk, function(x) {
    x_ch <- xml2::xml_children(x)
    x_names <- xml2::xml_name(x_ch)

    trk_details <- structure(xml2::xml_text(x_ch[x_names != "trkseg"]), names = x_names[x_names != "trkseg"])

    trkseg <- x_ch[x_names == "trkseg"]
    trkpt <- xml2::xml_children(trkseg)
    lat_lon <- do.call(rbind, xml2::xml_attrs(trkpt))
    # xml2::xml_find_all(trkpt, ".//time") ## TODO: doesn't work :(

    elem_points <- lapply(trkpt, function(y) {
      pt <- xml2::xml_children(y)
      elem_name <- sapply(pt, xml2::xml_name)
      vals <- structure(
        sapply(pt[elem_name %in% c("ele", "time")], xml2::xml_text),
        names = elem_name[elem_name %in% c("ele", "time")]
      )
    })
    point_data <- do.call(rbind, elem_points)

    trkpt <- data.frame(lat_lon, point_data)
    if ("time" %in% names(trkpt)) {
      trkpt$time <- as.POSIXct(trkpt$time, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT")
    }

    out <- trkpt
    attributes(out) <- c(attributes(out), trk_details)

    return(out)
  })

  if ("metadata" %in% xml2::xml_name(gpx)) {
    metaL <- xml2::as_list(gpx[xml2::xml_name(gpx) == "metadata"])

    meta <- xml2::xml_children(gpx[xml2::xml_name(gpx) == "metadata"])
    meta_attrs <- xml2::xml_attrs(meta)
    names(meta_attrs) <- xml2::xml_name(meta)
    meta_attrs <- meta_attrs[sapply(meta_attrs, length) > 0]

    attributes(trkL) <- c(attributes(trkL), meta_attrs, unlist(metaL, recursive = FALSE))
  }

  return(trkL)
}


## user_details ----

user_details_xml2DF <- function(xml) {
  users <- xml2::xml_children(xml)

  user_attrs <- do.call(rbind, xml2::xml_attrs(users))
  description <- xml2::xml_text(xml2::xml_child(users, "description"))
  img <- xml2::xml_attr(xml2::xml_child(users, "img"), "href")
  contributor_terms <- ifelse(xml2::xml_attrs(xml2::xml_child(users, "contributor-terms")) == "true", TRUE, FALSE)

  roles <- xml2::xml_name(xml2::xml_contents(xml2::xml_child(users, "roles")))
  roles <- ifelse(roles == "text", NA_character_, roles)

  changesets_count <- as.character(xml2::xml_attrs(xml2::xml_child(users, "changesets")))
  traces_count <- as.character(xml2::xml_attrs(xml2::xml_child(users, "traces")))


  blocks <- xml2::xml_child(users, "blocks")

  blocks_received <- do.call(rbind, xml2::xml_attrs(xml2::xml_child(blocks, "received")))
  colnames(blocks_received) <- c("blocks_received.count", "blocks_received.active")

  blocks_issued <- do.call(rbind, xml2::xml_attrs(xml2::xml_child(blocks, "issued")))
  if (ncol(blocks_issued) == 1) { # No users have issued blocks
    blocks_issued <- matrix(
      data = NA_character_, nrow = length(users), ncol = 2,
      dimnames = list(NULL, c("blocks_issued.count", "blocks_issued.active"))
    )
  } else {
    colnames(blocks_issued) <- c("blocks_issued.count", "blocks_issued.active")
  }

  ## For osm_details_logged_user() TODO: return a list (current implementation) or a data.frame?
  # home <- xml2::xml_attrs(xml2::xml_child(users, "home")),
  # languages <- xml2::xml_text(xml2::xml_children(xml2::xml_child(users, "languages"))),
  # messages <- list(
  #   received = xml2::xml_attrs(xml2::xml_child(xml2::xml_child(users, "messages"), "received")),
  #   sent = xml2::xml_attrs(xml2::xml_child(xml2::xml_child(users, "messages"), "sent"))

  out <- data.frame(
    user_attrs, description, img, contributor_terms, roles,
    changesets_count, traces_count, blocks_received, blocks_issued
  )

  int_cols <- c(
    "changesets_count", "traces_count", "blocks_received.count", "blocks_received.active",
    "blocks_issued.count", "blocks_issued.active"
  )
  out[, int_cols] <- lapply(out[, int_cols], as.integer)

  out$account_created <- as.POSIXct(out$account_created)

  return(out)
}


## Map notes ----

note_xml2DF <- function(xml) {
  notes <- xml2::xml_children(xml)

  note_attrs <- do.call(rbind, xml2::xml_attrs(notes))
  id <- xml2::xml_text(xml2::xml_child(notes, "id"))
  url <- xml2::xml_text(xml2::xml_child(notes, "url"))
  comment_url <- xml2::xml_text(xml2::xml_child(notes, "comment_url"))
  close_url <- xml2::xml_text(xml2::xml_child(notes, "close_url"))
  date_created <- xml2::xml_text(xml2::xml_child(notes, "date_created"))
  status <- xml2::xml_text(xml2::xml_child(notes, "status"))

  comments <- xml2::xml_child(notes, "comments")
  commentsL <- lapply(xml2::xml_find_all(comments, xpath = ".//comment", flatten = FALSE), function(x) {
    if (length(x) == 0) {
      return(NA)
    }
    date <- xml2::xml_text(xml2::xml_child(x, "date"))
    uid <- xml2::xml_text(xml2::xml_child(x, "uid"))
    user <- xml2::xml_text(xml2::xml_child(x, "user"))
    user_url <- xml2::xml_text(xml2::xml_child(x, "user_url"))
    action <- xml2::xml_text(xml2::xml_child(x, "action"))
    text <- xml2::xml_text(xml2::xml_child(x, "text"))
    html <- xml2::xml_text(xml2::xml_child(x, "html"))

    comm <- data.frame(date, uid, user, user_url, action, text, html)
    comm$date <- as.POSIXct(comm$date)

    return(comm)
  })

  out <- data.frame(note_attrs, id, url, comment_url, close_url, date_created, status)
  out$date_created <- as.POSIXct(out$date_created)

  out$comments <- commentsL

  # out$comments ## TODO: improve print. class? Hide or omit non informative columns ".*url$" (derived from id)

  return(out)
}
