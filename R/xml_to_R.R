tags_xml2mat_wide <- function(xml_nodeset) {
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
  m <- enc2utf8(m)

  return(m)
}


tags_xml2list_df <- function(xml_nodeset) {
  out <- lapply(xml2::xml_find_all(xml_nodeset, xpath = ".//tag", flatten = FALSE), function(x) {
    tag <- xml2::xml_attrs(x)
    tags_df <- structure(
      as.data.frame(t(
        vapply(tag, function(y) y, FUN.VALUE = character(2))
      )),
      names = c("key", "value")
    )
    tags_df$key <- enc2utf8(tags_df$key)
    tags_df$value <- enc2utf8(tags_df$value)

    class(tags_df) <- c("tags_df", "data.frame")

    return(tags_df)
  })

  return(out)
}


## Changesets ----

# For osm_get_changesets() & osm_query_changesets().
# osm_download_changeset() in osmChange xml format not related

changeset_xml2DF <- function(xml, tags_in_columns = FALSE) {
  changesets <- xml2::xml_children(xml)

  if (length(changesets) == 0) {
    return(empty_changeset())
  }

  # read & query changeset calls have different order in attributes
  ord_cols <- c(
    "id", "created_at", "closed_at", "open", "user", "uid",
    "min_lat", "min_lon", "max_lat", "max_lon", "comments_count", "changes_count"
  )

  changeset_attrs <- lapply(xml2::xml_attrs(changesets), function(x) {
    # Open and empty changesets lack some attributes
    mis_attrs <- setdiff(ord_cols, names(x))
    if (length(mis_attrs)) {
      x <- c(x, stats::setNames(rep(NA_character_, length(mis_attrs)), mis_attrs))
    }

    x[ord_cols]
  })

  out <- data.frame(do.call(rbind, changeset_attrs))

  out$open <- ifelse(out$open == "true", TRUE, FALSE)
  out$comments_count <- as.integer(out$comments_count)
  out$changes_count <- as.integer(out$changes_count)
  out$created_at <- as.POSIXct(out$created_at, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT")
  out$closed_at <- as.POSIXct(out$closed_at, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT")
  out$user <- enc2utf8(out$user)

  discussion <- xml2::xml_child(changesets, "discussion")

  if (!all(is.na(discussion))) {
    discussionL <- lapply(xml2::xml_find_all(discussion, xpath = ".//comment", flatten = FALSE), function(x) {
      if (length(x) == 0) {
        return(NA)
      }
      comment_attrs <- do.call(rbind, xml2::xml_attrs(x))
      comment_text <- xml2::xml_text(xml2::xml_child(x, "text"))
      dis <- data.frame(comment_attrs, comment_text)
      dis$date <- as.POSIXct(dis$date, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT")
      dis$user <- enc2utf8(dis$user)
      dis$comment_text <- enc2utf8(dis$comment_text)

      class(dis) <- c("changeset_comments", "data.frame")

      return(dis)
    })

    out$discussion <- discussionL
  }

  if (tags_in_columns) {
    tags <- tags_xml2mat_wide(changesets)
    out <- cbind(out, tags)

    out <- fix_duplicated_columns(out)

    attr(out, "tag_columns") <- structure((ncol(out) - ncol(tags) + 1):ncol(out), names = colnames(tags))
    class(out) <- c("osmapi_changesets", "tags_wide", "data.frame")
  } else {
    out$tags <- tags_xml2list_df(changesets)
    class(out) <- c("osmapi_changesets", "data.frame")
  }

  return(out)
}


empty_changeset <- function() {
  out <- data.frame(
    id = character(), created_at = as.POSIXct(Sys.time())[-1], closed_at = as.POSIXct(Sys.time())[-1],
    open = logical(), user = character(), uid = character(), min_lat = character(), min_lon = character(),
    max_lat = character(), max_lon = character(), comments_count = integer(), changes_count = integer()
  )

  out$tags <- list()

  class(out) <- c("osmapi_changesets", "data.frame")

  return(out)
}


changeset_comments_xml2DF <- function(xml) {
  changeset_comments <- xml2::xml_children(xml)

  if (length(changeset_comments) == 0) {
    return(empty_changeset_comments())
  }

  comment_attrs <- do.call(rbind, xml2::xml_attrs(changeset_comments))
  comment_text <- xml2::xml_text(xml2::xml_child(changeset_comments, "text"))
  out <- data.frame(comment_attrs, comment_text)

  out$date <- as.POSIXct(out$date, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT")
  out$visible <- ifelse(out$visible == "true", TRUE, FALSE)
  out$user <- enc2utf8(out$user)
  out$comment_text <- enc2utf8(out$comment_text)

  class(out) <- c("changeset_comments", "data.frame")

  return(out)
}


empty_changeset_comments <- function() {
  out <- data.frame(
    id = character(), date = as.POSIXct(Sys.time())[-1], visible = logical(),
    uid = character(), user = character(), comment_text = character()
  )

  class(out) <- c("changeset_comments", "data.frame")

  return(out)
}


osmchange_xml2DF <- function(xml) {
  actions <- xml2::xml_children(xml)

  action_type <- xml2::xml_name(actions)
  objects <- object_xml2DF(actions)

  out <- cbind(action_type, objects)

  class(out) <- c("osmapi_OsmChange", "data.frame")

  return(out)
}


osmchange_upload_response_xml2DF <- function(xml) {
  actions <- xml2::xml_children(xml)

  if (length(actions) == 0) {
    return(data.frame(type = character(), old_id = character(), new_id = character(), new_version = integer()))
  }

  object_type <- xml2::xml_name(actions)
  action_attrs <- do.call(rbind, xml2::xml_attrs(actions))

  out <- cbind(type = object_type, action_attrs)
  out <- data.frame(out)
  if ("new_version" %in% names(out)) {
    out$new_version <- as.integer(out$new_version)
  }

  return(out)
}


## Elements ----

object_xml2DF <- function(xml, tags_in_columns = FALSE) {
  objects <- xml2::xml_children(xml)

  if (length(objects) == 0) {
    return(empty_object())
  }

  object_type <- xml2::xml_name(objects)

  if (object_type[1] == "bounds") { # osm_bbox_objects()

    bbox <- xml2::xml_attrs(objects[[1]])
    objects <- objects[-1]
    object_type <- object_type[-1]

    if (length(objects) == 0) {
      out <- empty_object()
      attr(out, "bbox") <- bbox

      return(out)
    }
  } else {
    bbox <- NULL
  }

  object_attrsL <- xml2::xml_attrs(objects)

  col_names <- c("id", "visible", "version", "changeset", "timestamp", "user", "uid", "lat", "lon")

  object_attrs <- structure(
    t(vapply(object_attrsL, function(x) x[col_names], FUN.VALUE = character(length(col_names)))),
    dimnames = list(NULL, col_names)
  )

  out <- cbind(type = object_type, object_attrs)

  # columns only for nodes (+ lat lon)
  if (any(no_coords <- out[, "type"] != "node")) {
    out[no_coords, c("lat", "lon")] <- NA_character_
  }

  out <- as.data.frame(out)

  out$visible <- ifelse(out$visible == "true", TRUE, FALSE)
  out$version <- as.integer(out$version)
  out$timestamp <- as.POSIXct(out$timestamp, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT")
  out$user <- enc2utf8(out$user)

  members <- vector("list", length = length(objects))
  members[object_type == "way"] <- lapply(objects[object_type == "way"], function(x) {
    nd <- xml2::xml_attr(xml2::xml_find_all(x, ".//nd"), "ref")

    if (!is.null(nd)) {
      class(nd) <- "way_members"
    }

    nd
  })

  members[object_type == "relation"] <- lapply(objects[object_type == "relation"], function(x) {
    member <- do.call(rbind, xml2::xml_attrs(xml2::xml_find_all(x, ".//member")))

    if (!is.null(member)) {
      class(member) <- "relation_members"
    }

    member
  })

  out$members <- members

  if (tags_in_columns) {
    tags <- tags_xml2mat_wide(objects)
    names(out) <- gsub("^(type|id)$", "osm_\\1", names(out))
    out <- cbind(out, tags)

    out <- fix_duplicated_columns(out)

    attr(out, "tag_columns") <- structure((ncol(out) - ncol(tags) + 1):ncol(out), names = colnames(tags))
    class(out) <- c("osmapi_objects", "tags_wide", "data.frame")
  } else {
    out$tags <- tags_xml2list_df(objects)
    class(out) <- c("osmapi_objects", "data.frame")
  }

  if (!is.null(bbox)) {
    attr(out, "bbox") <- bbox
  }

  return(out)
}


empty_object <- function() {
  out <- data.frame(
    type = character(), id = character(), visible = logical(), version = integer(), changeset = character(),
    timestamp = as.POSIXct(Sys.time())[-1], user = character(), uid = character(),
    lat = character(), lon = character()
  )
  out$members <- list()
  out$tags <- list()

  class(out) <- c("osmapi_objects", "data.frame")

  return(out)
}


## GPS traces ----

gpx_meta_xml2DF <- function(xml) {
  gpx_files <- xml2::xml_children(xml)

  gpx_attrs <- do.call(rbind, xml2::xml_attrs(gpx_files))
  description <- xml2::xml_text(xml2::xml_child(gpx_files, "description"))
  tags <- lapply(xml2::xml_find_all(gpx_files, ".//tag", flatten = FALSE), function(x) {
    x <- xml2::xml_text(x)
    enc2utf8(x)
  })

  out <- data.frame(gpx_attrs, description)
  out$timestamp <- as.POSIXct(out$timestamp, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT")
  out$pending <- ifelse(out$pending == "true", TRUE, FALSE)
  out$name <- enc2utf8(out$name)
  out$user <- enc2utf8(out$user)
  out$description <- enc2utf8(out$description)

  out$tags <- tags

  return(out)
}


# GPX files----

# https://www.topografix.com/GPX/1/1/
# https://www.topografix.com/GPX/1/0/
# https://wiki.openstreetmap.org/wiki/GPX The importer doesn't import waypoints
# https://github.com/openstreetmap/openstreetmap-website/blob/master/app/controllers/traces_controller.rb
# https://github.com/openstreetmap/openstreetmap-website/blob/master/app/models/trace.rb only track points imported


gpx_xml2df <- function(xml) {
  xml_attrs <- xml2::xml_attrs(xml)
  gpx_ns_prefix <- get_xns_prefix(xml, ns = c("http://www.topografix.com/GPX/1/1", "http://www.topografix.com/GPX/1/0"))

  metadata <- xml2::xml_find_first(xml, paste0("./", gpx_ns_prefix, ":metadata"))
  gpx_metadata <- xml2::as_list(metadata)
  # For bounds as vector when creator="JOSM GPX export"
  if (xml_attrs["creator"] == "JOSM GPX export") {
    metadata_nodes <- xml2::xml_children(metadata)
    metadata_attrs <- xml2::xml_attrs(metadata_nodes)
    names(metadata_attrs) <- xml2::xml_name(metadata_nodes)
    metadata_attrs <- metadata_attrs[vapply(metadata_attrs, length, FUN.VALUE = integer(1)) > 0]
    gpx_metadata <- c(unlist(gpx_metadata, recursive = FALSE), metadata_attrs)
  }

  trk <- xml2::xml_find_all(xml, paste0(".//", gpx_ns_prefix, ":trk"))
  if (length(trk) == 0) {
    out <- empty_gpx_df()
    attributes(out) <- c(attributes(out), list(gpx_attributes = xml_attrs), gpx_metadata)
  } else if (length(trk) == 1) {
    out <- trk_xml2df(trk = trk)
    attributes(out) <- c(attributes(out), list(gpx_attributes = xml_attrs), gpx_metadata)
    class(out) <- c("osmapi_gps_track", "data.frame")
  } else if (length(trk) > 1) {
    warning(
      "GPX with more than one track. The result will be a list of class `osmapi_gpx`.",
      "Please, open and issue with the `gpx_id` or the original file if the gpx is not public ",
      "at https://github.com/ropensci/osmapiR/issues"
    )
    out <- gpx_xml2list(xml = xml)
  }

  return(out)
}


empty_gpx_df <- function() {
  out <- data.frame(lon = character(), lat = character(), ele = character(), time = as.POSIXct(Sys.time())[-1])
  class(out) <- c("osmapi_gps_track", "data.frame")

  return(out)
}


gpx_xml2list <- function(xml) {
  xml_attrs <- xml2::xml_attrs(xml)
  gpx_ns_prefix <- get_xns_prefix(xml, ns = c("http://www.topografix.com/GPX/1/1", "http://www.topografix.com/GPX/1/0"))

  metadata <- xml2::xml_find_first(xml, paste0("./", gpx_ns_prefix, ":metadata"))
  gpx_metadata <- xml2::as_list(metadata)

  trk <- xml2::xml_find_all(xml, paste0(".//", gpx_ns_prefix, ":trk"))

  if (length(trk) == 0) {
    out <- empty_gpx_list()
    attributes(out) <- c(attributes(out), list(gpx_attributes = xml_attrs), gpx_metadata)

    return(out)
  }

  out <- lapply(trk, trk_xml2df)
  names(out) <- vapply(out, function(x) {
    url <- attr(x, "track")["track_url"]
    if (is.na(url)) { # for private traces
      url <- ""
    }
    url
  }, FUN.VALUE = character(1))

  attributes(out) <- c(attributes(out), list(gpx_attributes = xml_attrs), gpx_metadata)
  class(out) <- c("osmapi_gpx", class(out))

  return(out)
}


empty_gpx_list <- function() {
  out <- list()
  class(out) <- c("osmapi_gpx", "list")

  return(out)
}


trk_xml2df <- function(trk) {
  gpx_ns_prefix <- get_xns_prefix(trk, ns = c("http://www.topografix.com/GPX/1/1", "http://www.topografix.com/GPX/1/0"))

  details <- xml2::xml_find_all(trk, "./*[not(name() = 'trkseg')]") # no trkseg nodes
  trk_details <- stats::setNames(xml2::xml_text(details), nm = xml2::xml_name(details))
  trk_details <- enc2utf8(trk_details)
  if (length(trk_details)) {
    names(trk_details) <- paste0("track_", names(trk_details))
  }

  ## TODO: extract and group points by segments?
  # trkseg <- xml2::xml_find_all(trk, paste0(gpx_ns_prefix, "trkseg"))
  # if (length(trkseg) > 1) warning("More than one gpx segment)

  trkpt <- xml2::xml_find_all(trk, paste0(".//", gpx_ns_prefix, ":trkpt"))
  lat_lon <- do.call(rbind, xml2::xml_attrs(trkpt)) # lat lon
  out <- as.data.frame(lat_lon)

  ele <- xml2::xml_text(xml2::xml_find_all(trkpt, paste0(".//", gpx_ns_prefix, ":ele")))
  if (length(ele) > 0) {
    out$ele <- ele
  }
  time <- xml2::xml_text(xml2::xml_find_all(trkpt, paste0(".//", gpx_ns_prefix, ":time")))
  if (length(time) > 0) {
    out$time <- as.POSIXct(time, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT")
  }


  ## Extensions (https://www8.garmin.com/xmlschemas/GpxExtensions/v3/GpxExtensionsv3.xsd)
  namespaces <- xml2::xml_ns(trk)
  if ("http://www.garmin.com/xmlschemas/TrackPointExtension/v1" %in% namespaces) {
    trkpt_ext_ns_prefix <- get_xns_prefix(trk, ns = "http://www.garmin.com/xmlschemas/TrackPointExtension/v1")
    tpe <- xml2::xml_find_all(trk, paste0(".//", trkpt_ext_ns_prefix, ":TrackPointExtension"))
    ext <- lapply(tpe, function(x) {
      out <- xml2::xml_children(x)
      stats::setNames(xml2::xml_text(out), nm = xml2::xml_name(out))
    })
    ext <- do.call(rbind, ext)
    out <- cbind(out, ext)
  }
  # other_extensions_ns <- c(
  #   "http://www.garmin.com/xmlschemas/GpxExtensions/v3",
  #   "http://www.garmin.com/xmlschemas/ActivityExtension/v2",
  #   "http://www.garmin.com/xmlschemas/FitnessExtension/v1",
  #   "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
  # )

  attributes(out) <- c(attributes(out), list(track = trk_details))

  return(out)
}


## user_details ----

user_details_xml2DF <- function(xml) {
  users <- xml2::xml_children(xml)

  if (length(users) == 0) {
    return(empty_user())
  }

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

  out <- data.frame(
    user_attrs, description, img, contributor_terms, roles,
    changesets_count, traces_count, blocks_received, blocks_issued
  )

  int_cols <- c(
    "changesets_count", "traces_count", "blocks_received.count", "blocks_received.active",
    "blocks_issued.count", "blocks_issued.active"
  )
  out[, int_cols] <- lapply(out[, int_cols], as.integer)

  out$account_created <- as.POSIXct(out$account_created, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT")

  out$display_name <- enc2utf8(out$display_name)
  out$description <- enc2utf8(out$description)

  return(out)
}


empty_user <- function() {
  out <- data.frame(
    id = character(), display_name = character(), account_created = as.POSIXct(Sys.time())[-1],
    description = character(), img = character(), contributor_terms = logical(), roles = character(),
    changesets_count = integer(), traces_count = integer(), blocks_received.count = integer(),
    blocks_received.active = integer(), blocks_issued.count = integer(), blocks_issued.active = integer()
  )

  return(out)
}


logged_user_details_xml2list <- function(xml) {
  user <- xml2::xml_child(xml)

  out <- list(
    user = xml2::xml_attrs(user),
    description = xml2::xml_text(xml2::xml_child(user, "description")),
    img = xml2::xml_attr(xml2::xml_child(user, "img"), "href"),
    contributor_terms = ifelse(xml2::xml_attrs(xml2::xml_child(user, "contributor-terms")) == "true", TRUE, FALSE),
    roles = xml2::xml_name(xml2::xml_children(xml2::xml_child(user, "roles"))), # WARNING: not tested
    changesets = xml2::xml_attrs(xml2::xml_child(user, "changesets")),
    traces = xml2::xml_attrs(xml2::xml_child(user, "traces")),
    blocks = list(
      received = xml2::xml_attrs(xml2::xml_child(xml2::xml_child(user, "blocks"), "received")),
      issued = xml2::xml_attrs(xml2::xml_child(xml2::xml_child(user, "blocks"), "issued"))
    ),
    home = xml2::xml_attrs(xml2::xml_child(user, "home")),
    languages = xml2::xml_text(xml2::xml_children(xml2::xml_child(user, "languages"))),
    messages = list(
      received = xml2::xml_attrs(xml2::xml_child(xml2::xml_child(user, "messages"), "received")),
      sent = xml2::xml_attrs(xml2::xml_child(xml2::xml_child(user, "messages"), "sent"))
    )
  )

  out$user["display_name"] <- enc2utf8(out$user["display_name"])
  out$description <- enc2utf8(out$description)

  return(out)
}


## user preferences ----

user_preferences_xml2DF <- function(xml) {
  preferences <- xml2::xml_child(xml)
  preference <- xml2::xml_children(preferences)

  out <- structure(
    as.data.frame(do.call(rbind, xml2::xml_attrs(preference))),
    names = c("key", "value")
  )
  out$key <- enc2utf8(out$key)
  out$value <- enc2utf8(out$value)

  return(out)
}


## Map notes ----

note_xml2DF <- function(xml) {
  notes <- xml2::xml_children(xml)

  if (length(notes) == 0) {
    return(empty_notes())
  }

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
    comm$date <- as.POSIXct(comm$date, format = "%Y-%m-%d %H:%M:%OS", tz = "GMT")
    comm$user <- enc2utf8(comm$user)
    comm$text <- enc2utf8(comm$text)
    comm$html <- enc2utf8(comm$html)

    class(comm) <- c("note_comments", "data.frame")

    return(comm)
  })

  out <- data.frame(note_attrs, id, url, comment_url, close_url, date_created, status)
  out$date_created <- as.POSIXct(out$date_created, format = "%Y-%m-%d %H:%M:%OS", tz = "GMT")

  out$comments <- commentsL

  class(out) <- c("osmapi_map_notes", "data.frame")

  return(out)
}


empty_notes <- function() {
  out <- data.frame(
    lon = character(), lat = character(), id = character(), url = character(),
    comment_url = character(), close_url = character(), date_created = as.POSIXct(Sys.time())[-1], status = character()
  )
  out$comments <- list()

  class(out) <- c("osmapi_map_notes", "data.frame")

  return(out)
}


## User Blocks ----

user_blocks_xml2DF <- function(xml) {
  user_blocks <- xml2::xml_children(xml)

  if (length(user_blocks) == 0) {
    return(empty_user_blocks())
  }

  user_blocks_attrs <- do.call(rbind, xml2::xml_attrs(user_blocks))

  user <- xml2::xml_child(user_blocks, "user")
  user_attrs <- do.call(rbind, xml2::xml_attrs(user))
  colnames(user_attrs)[1] <- "user_uid"

  creator <- xml2::xml_child(user_blocks, "creator")
  creator_attrs <- do.call(rbind, xml2::xml_attrs(creator))
  colnames(creator_attrs) <- c("creator_uid", "creator")

  revoker <- xml2::xml_child(user_blocks, "revoker")
  if (!all(is.na(revoker))) {
    revoker_attrs <- do.call(rbind, xml2::xml_attrs(revoker))
  } else {
    revoker_attrs <- matrix(NA_character_, nrow = length(user_blocks), ncol = 2)
  }
  colnames(revoker_attrs) <- c("revoker_uid", "revoker")

  reason <- xml2::xml_text(xml2::xml_child(user_blocks, "reason"))

  out <- data.frame(user_blocks_attrs, user_attrs, creator_attrs, revoker_attrs, reason)

  out$created_at <- as.POSIXct(out$created_at, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT")
  out$updated_at <- as.POSIXct(out$updated_at, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT")
  out$ends_at <- as.POSIXct(out$ends_at, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT")
  out$needs_view <- ifelse(out$needs_view == "true", TRUE, FALSE)
  out$user <- enc2utf8(out$user)
  out$creator <- enc2utf8(out$creator)
  out$revoker <- enc2utf8(out$revoker)
  out$reason <- enc2utf8(reason)

  return(out)
}


empty_user_blocks <- function() {
  out <- data.frame(
    id = character(), created_at = as.POSIXct(Sys.time())[-1], updated_at = as.POSIXct(Sys.time())[-1],
    ends_at = as.POSIXct(Sys.time())[-1], needs_view = logical(),
    user_uid = character(), user = character(), creator_uid = character(), creator = character()
  )

  return(out)
}


## Utils ----

get_xns_prefix <- function(xml, ns) {
  namespaces <- xml2::xml_ns(xml)
  ns_prefix <- names(namespaces)[namespaces %in% ns]

  if (length(ns_prefix) == 1) {
    xpath_prefix <- ns_prefix
  } else {
    xpath_prefix <- ""
    if (length(ns_prefix) > 1) {
      warning("More than one namespace: ", paste(namespaces[namespaces %in% ns], collapse = ", "))
    }
  }

  return(xpath_prefix)
}
