# osmapiR 0.2.1

* Update CITATION with the JOSS article (<https://doi.org/10.21105/joss.07151>).
* Test and fix `tags_list2wide()` with only 1 tag per object ([0368f1b](https://github.com/ropensci/osmapiR/commit/0368f1bf5ea9a0ba670d4dbd356846873460e96c)).


# osmapiR 0.2.0 
*(published at <https://doi.org/10.5281/zenodo.13627998>)*

## New features

* Add `format = "sf"` for functions returning objects of class `osmapi_map_notes` (#36).
* Add `format = "sf"` for functions returning objects of class `osmapi_changesets` (#37).
* Add `format = "sf"` for `osm_get_gpx_metadata()` (#38).
* Add `format = "sf"` for `osm_list_gpxs()` (#42).
* Add `format = "sf"` for functions returning objects of class `osmapi_gps_track` (#44).
* Add `format = "sf"` for functions returning objects of class `osmapi_gpx` (#45).
* Set encoding to UTF-8 for tags and user names in returned data.frames (#54).
* Parse `<TrackPointExtension>` data from gpx if available (#49).

## Minor improvements
  
* Upgrade logo by @atarom.
* Add inst/CITATION.
* Updated links to the new osmapiR home at rOpenSci (#40).
* Split functions to parse gpx data from different API endpoints and different properties (#43).
* Implement NA bboxes in `st_as_sf.osmapi_chagesets()` ([7ea4f5d7](https://github.com/ropensci/osmapiR/commit/7ea4f5d7f412ef8cf7691741b836cf45ddeb61f2)).
* Remove dontrun in examples that don't require authentication (#47).
* Improve performance when parsing gpx data to data.frame (#48).
* Tweaks in DESCRIPTION and CITATION files by @Maelle (#50, #51).
* Sort OSM objects in `osm_get_objects(..., full_objects = TRUE)` and optimize (#52).

## Bug fixes

* Improve tests and fix bugs (#35, [08fb4b1](https://github.com/ropensci/osmapiR/commit/08fb4b10abf0270d8bea2473b02b2520ba341521)).
* Fix miscalculation of the nchar_url that trigger errors when many ids are requested in `osm_fetch_objects()`.
* Fix changesets' bbox in `st_as_sf.osmapi_chagesets()` ([84f16e7a](https://github.com/ropensci/osmapiR/commit/84f16e7adda087ab707cc2644c79ff1590cf307e)). 


# osmapiR 0.1.0

* Initial CRAN submission implementing calls to all the API endpoints.
* Server responses are returned as R objects, xml_documents or json lists.
* Authentication when needed with OAuth2.
* Pagination in server responses handled internally (#20, #23 & #29).
* Vectorization of atomic API calls (#18).
