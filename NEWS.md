# osmapiR (development version)

* Upgrade logo by @atarom
* Add inst/CITATION
* Improve tests and fix bugs (#35, [08fb4b1](https://github.com/ropensci/osmapiR/commit/08fb4b10abf0270d8bea2473b02b2520ba341521)).
* Add format = "sf" for functions returning objects of class `osmapi_map_notes` (#36).
* Add format = "sf" for functions returning objects of class `osmapi_changesets` (#37).
* Add format = "sf" for `osm_get_gpx_metadata()` (#38).
* Updated links to the new osmapiR home at rOpenSci (#40).
* Add format = "sf" for `osm_list_gpxs()` (#42).
* Split functions to parse gpx data from different API endpoints and different properties (#43).
* Add format = "sf" for functions returning objects of class `osmapi_gps_track` (#44).
* Add format = "sf" for functions returning objects of class `osmapi_gpx` (#45).
* Fix miscalculation of the nchar_url that trigger errors when many ids are requested in osm_fetch_objects().
* Fix changesets' bbox in `st_as_sf.osmapi_chagesets()` ([84f16e7a](https://github.com/ropensci/osmapiR/commit/84f16e7adda087ab707cc2644c79ff1590cf307e)). 
* Implement NA bboxes in `st_as_sf.osmapi_chagesets()` ([7ea4f5d7](https://github.com/ropensci/osmapiR/commit/7ea4f5d7f412ef8cf7691741b836cf45ddeb61f2)).
* Remove dontrun in examples that don't require authentication (#47).
* Improve performance when parsing gpx data to data.frame (#48)
* Parse TrackPointExtension data from gpx if available (#49)


# osmapiR 0.1.0

* Initial CRAN submission implementing calls to all the API endpoints.
* Server responses are returned as R objects, xml_documents or json lists.
* Authentication when needed with OAuth2.
* Pagination in server responses handled internally (#20, #23 & #29).
* Vectorization of atomic API calls (#18).
