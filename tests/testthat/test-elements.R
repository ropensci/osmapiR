node_id <- 35308286 # Canigó
way_id <- 13073736 # Torres de Quart
rel_id <- 40581 # l'Alguer

## Create: `PUT /api/0.6/[node|way|relation]/create` ----
test_that("osm_create_object works", {
  # osm_create_object(osm_type = c("node", "way", "relation"), ...)
})

## Read: `GET /api/0.6/[node|way|relation]/#id` ----
test_that("osm_read_object works", {
  node <- osm_read_object(osm_type = "node", osm_id = node_id)
  way <- osm_read_object(osm_type = "way", osm_id = way_id)
  rel <- osm_read_object(osm_type = "relation", osm_id = rel_id)

  osmdata:::xml_to_df(node)
  osmdata::osmdata_sf(doc = node)$osm_points
  cat(as.character(node))

  osmdata:::xml_to_df(way)
  osmdata::osmdata_sf(doc = way)$osm_polygons
  cat(as.character(way))

  osmdata:::xml_to_df(rel)
  osmdata::osmdata_sf(doc = rel)$osm_polygons
  cat(as.character(rel))
})

## Update: `PUT /api/0.6/[node|way|relation]/#id` ----
test_that("osm_update_object works", {
  osm_update_object(osm_type = c("node", "way", "relation"), osm_id)
})


## Delete: `DELETE /api/0.6/[node|way|relation]/#id` ----
test_that("osm_delete_object works", {
  osm_delete_object(osm_type = c("node", "way", "relation"), osm_id)
})


## History: `GET /api/0.6/[node|way|relation]/#id/history` ----
test_that("osm_history_object works", {
  node <- osm_history_object(osm_type = "node", osm_id = node_id)
  way <- osm_history_object(osm_type = "way", osm_id = way_id)
  rel <- osm_history_object(osm_type = "relation", osm_id = rel_id)

  osmdata:::xml_to_df(node)
  cat(as.character(node))

  osmdata:::xml_to_df(way)
  cat(as.character(way))

  osmdata:::xml_to_df(rel)
  cat(as.character(rel))
})


## Version: `GET /api/0.6/[node|way|relation]/#id/#version` ----
test_that("osm_version_object works", {
  node <- osm_version_object(osm_type = "node", osm_id = node_id, version = 1)
  way <- osm_version_object(osm_type = "way", osm_id = way_id, version = 3)
  rel <- osm_version_object(osm_type = "relation", osm_id = rel_id, version = 2)

  osmdata:::xml_to_df(node)
  cat(as.character(node))

  osmdata:::xml_to_df(way)
  cat(as.character(way))

  osmdata:::xml_to_df(rel)
  cat(as.character(rel))
})


## Multi fetch: `GET /api/0.6/[nodes|ways|relations]?#parameters` ----
test_that("osm_fetch_objects works", {
  node <- osm_fetch_objects(osm_type = "nodes", osm_ids = c(node_id, 1935675367))
  way <- osm_fetch_objects(osm_type = "ways", osm_ids = c(way_id, 235744929))
  rel <- osm_fetch_objects(osm_type = "relations", osm_ids = c(rel_id, "341530"))

  osmdata:::xml_to_df(node)
  cat(as.character(node))

  osmdata:::xml_to_df(way)
  cat(as.character(way))

  osmdata:::xml_to_df(rel)
  cat(as.character(rel))
})


## Relations for element: `GET /api/0.6/[node|way|relation]/#id/relations` ----
test_that("osm_relations_object works", {
  node <- osm_relations_object(osm_type = "node", osm_id = node_id)
  way <- osm_relations_object(osm_type = "way", osm_id = way_id)
  rel <- osm_relations_object(osm_type = "relation", osm_id = rel_id)

  osmdata:::xml_to_df(node)
  cat(as.character(node))

  osmdata:::xml_to_df(way)
  cat(as.character(way))

  osmdata:::xml_to_df(rel)
  cat(as.character(rel))
})


## Ways for node: `GET /api/0.6/node/#id/ways` ----
test_that("osm_ways_node works", {
  node <- osm_ways_node(node_id = node_id)

  osmdata:::xml_to_df(node)
  cat(as.character(node))
})


## Full: `GET /api/0.6/[way|relation]/#id/full` ----
test_that("osm_full_object works", {
  way <- osm_full_object(osm_type = "way", osm_id = way_id)
  rel <- osm_full_object(osm_type = "relation", osm_id = rel_id)

  osmdata:::xml_to_df(way)
  osmdata::osmdata_sf(doc = way)$osm_points
  cat(as.character(way))

  osmdata:::xml_to_df(rel)
  osm_sf <- osmdata::osmdata_sf(doc = rel)
  do.call(dbTools::rbind_addColumns, osm_sf[grep("^osm_", names(osm_sf))])
  cat(as.character(rel))
})


## Redaction: `POST /api/0.6/[node|way|relation]/#id/#version/redact?redaction=#redaction_id` ----
test_that("osm_redaction_object works", {
  # osm_redaction_object(osm_type = c("node", "way", "relation"), osm_id, version, redaction_id)
})
