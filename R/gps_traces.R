## GPS traces
#
# In violation of the [https://www.topografix.com/GPX/1/1/#type_trksegType GPX standard] when downloading public GPX traces through the API, all waypoints of non-trackable traces are randomized (or rather sorted by lat/lon) and delivered as one trackSegment for privacy reasons. Trackable traces are delivered, sorted by descending upload time, before the waypoints of non-trackable traces.
#
#
## Get GPS Points: Get /api/0.6/trackpoints?bbox=<span style="border:thin solid black">''left''</span>,<span style="border:thin solid black">''bottom''</span>,<span style="border:thin solid black">''right''</span>,<span style="border:thin solid black">''top''</span>&page=<span style="border:thin solid black">''pageNumber''</span> ----
# Use this to retrieve the GPS track points that are inside a given bounding box (formatted in a GPX format).
#
# where:
# * <code><span style="border:thin solid black">''left''</span></code> is the longitude of the left (westernmost) side of the bounding box.
# * <code><span style="border:thin solid black">''bottom''</span></code> is the latitude of the bottom (southernmost) side of the bounding box.
# * <code><span style="border:thin solid black">''right''</span></code> is the longitude of the right (easternmost) side of the bounding box.
# * <code><span style="border:thin solid black">''top''</span></code> is the latitude of the top (northernmost) side of the bounding box.
# * <code><span style="border:thin solid black">''pageNumber''</span></code> specifies which group of 5,000 points, or ''page'', to return. Since the command does not return more than 5,000 points at a time, this parameter must be incremented&mdash;and the command sent again (using the same bounding box)&mdash;in order to retrieve all of the points for a bounding box that contains more than 5,000 points. When this parameter is 0 (zero), the command returns the first 5,000 points; when it is 1, the command returns points 5,001&ndash;10,000, etc.
# The maximal width (right - left) and height (top - bottom) of the bounding box is 0.25 degree.
#
### Examples ----
# Retrieve the first 5,000 points for a bounding box:
#  https://api.openstreetmap.org/api/0.6/trackpoints?bbox=0,51.5,0.25,51.75&page=0
# Retrieve the next 5,000 points (points 5,001&ndash;10,000) for the same bounding box:
#  https://api.openstreetmap.org/api/0.6/trackpoints?bbox=0,51.5,0.25,51.75&page=1
#
### Response ----
#
# * This response is NOT wrapped in an OSM xml parent element.
# * The file format is GPX Version 1.0 which is not the current version. Verify that your tools support it.
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <gpx version="1.0" creator="OpenStreetMap.org" xmlns="http://www.topografix.com/GPX/1/0">
# 	<trk>
# 		<name>20190626.gpx</name>
# 		<desc>Footpaths near Blackweir Pond, Epping Forest</desc>
# 		<url>https://api.openstreetmap.org/user/John%20Leeming/traces/3031013</url>
# 		<trkseg>
# 			<trkpt lat="51.6616100" lon="0.0534560">
# 				<time>2019-06-26T14:27:58Z</time>
# 			</trkpt>
# 			...
# 		</trkseg>
# 		...
# 	</trk>
# 	...
# </gpx>
# </syntaxhighlight>
#
#
## Create: `POST /api/0.6/gpx/create` ----
#
# Use this to upload a GPX file or archive of GPX files. Requires authentication.
#
# The following parameters are required in a multipart/form-data HTTP message:
#
# {| class=wikitable
# !parameter
# !description
# |-
# |file
# |The GPX file containing the track points. Note that for successful processing, the file must contain trackpoints (<code><trkpt></code>), not only waypoints, and the trackpoints must have a valid timestamp. Since the file is processed asynchronously, the call will complete successfully even if the file cannot be processed. The file may also be a .tar, .tar.gz or .zip containing multiple gpx files, although it will appear as a single entry in the upload log.
# |-
# |description
# |The trace description. Cannot be empty.
# |-
# |tags
# |A string containing tags for the trace. Can be empty.
# |-
# |public
# |1 if the trace is public, 0 if not. This exists for backwards compatibility only - the visibility parameter should now be used instead. This value will be ignored if visibility is also provided.
# |-
# |visibility
# |One of the following: private, public, trackable, identifiable (for explanations see [https://www.openstreetmap.org/traces/mine OSM trace upload page] or [[Visibility of GPS traces]])
# |}Response:
#
# A number representing the ID of the new gpx
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : When the description is empty
#
#
## Update: `PUT /api/0.6/gpx/#id` ----
# Use this to update a GPX file. Only usable by the owner account. Requires authentication.<br />The response body will be empty.
#
#
## Delete: `DELETE /api/0.6/gpx/#id` ----
# Use this to delete a GPX file. Only usable by the owner account. Requires authentication.<br />The response body will be empty.
#
#
## Download Metadata: `GET /api/0.6/gpx/#id/details` ----
# Use this to access the metadata about a GPX file. Available without authentication if the file is marked public. Otherwise only usable by the owner account and requires authentication.
#
# Example "details" response:
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <osm version="0.6" generator="OpenStreetMap server">
# 	<gpx_file id="836619" name="track.gpx" lat="52.0194" lon="8.51807" user="Hartmut Holzgraefe" visibility="public" pending="false" timestamp="2010-10-09T09:24:19Z">
# 		<description>PHP upload test</description>
# 		<tag>test</tag>
# 		<tag>php</tag>
# 	</gpx_file>
# </osm>
# </syntaxhighlight>
#
#
## Download Data: `GET /api/0.6/gpx/#id/data` ----
#
# Use this to download the full GPX file. Available without authentication if the file is marked public. Otherwise only usable by the owner account and requires authentication.
# '
# The response will always be a GPX format file if you use a '''.gpx''' URL suffix, a XML file in an undocumented format if you use a '''.xml''' URL suffix, otherwise the response will be the exact file that was uploaded.
#
# NOTE: if you request refers to a multi-file archive the response when you force gpx or xml format will consist of a non-standard simple concatenation of the files.
#
#
## List: `GET /api/0.6/user/gpx_files` ----
# Use this to get a list of GPX traces owned by the authenticated user: Requires authentication.
#
# Note that '''/user/''' is a literal part of the URL, not a user's display name or user id. (This call always returns GPX traces for the current authenticated user ''only''.)
#
# Example "details" response:
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <osm version="0.6" generator="OpenStreetMap server">
# 	<gpx_file id="836619" name="track.gpx" lat="52.0194" lon="8.51807" user="Hartmut Holzgraefe" visibility="public" pending="false" timestamp="2010-10-09T09:24:19Z">
# 		<description>PHP upload test</description>
# 		<tag>test</tag>
# 		<tag>php</tag>
# 	</gpx_file>
# </osm>
# </syntaxhighlight>
