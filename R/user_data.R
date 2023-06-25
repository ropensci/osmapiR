## Methods for user data
#
## Details of a user: `GET /api/0.6/user/#id` ----
# This API method was added in September 2012 ([https://github.com/openstreetmap/openstreetmap-website/commit/3ce4de1295ecec082313740a3cdf25c2831164f7 code]).
#
# You can get the home location and the displayname of the user, by using
#
### Response XML ----
#  GET /api/0.6/user/#id
# this returns for example
# <syntaxhighlight lang="xml">
# <osm version="0.6" generator="OpenStreetMap server">
# 	<user id="12023" display_name="jbpbis" account_created="2007-08-16T01:35:56Z">
# 		<description></description>
# 		<contributor-terms agreed="false"/>
# 		<img href="http://www.gravatar.com/avatar/c8c86cd15f60ecca66ce2b10cb6b9a00.jpg?s=256&amp;d=http%3A%2F%2Fwww.openstreetmap.org%2Fassets%2Fusers%2Fimages%2Flarge-39c3a9dc4e778311af6b70ddcf447b58.png"/>
#         <roles>
#             <moderator/>
#         </roles>
# 		<changesets count="1"/>
# 		<traces count="0"/>
# 		<blocks>
# 			<received count="0" active="0"/>
# 		    <issued count="68" active="45"/>
# 		</blocks>
# 	</user>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/user/#id.json
# <syntaxhighlight lang="json">
# {
#  "version": "0.6",
#  "generator": "OpenStreetMap server",
#  "user": {"id": 12023, "display_name": "jbpbis", "account_created": "2007-08-16T01:35:56Z", "description": "", "contributor_terms": {"agreed": False}, "roles": [], "changesets": {"count": 1}, "traces": {"count": 0}, "blocks": {"received": {"count": 0, "active": 0}}}
# }
# </syntaxhighlight>
#
# or an empty file if no user found for given identifier.
#
# Note that user accounts which made edits may be deleted. Such users are listed at https://planet.osm.org/users_deleted/users_deleted.txt
#
#
## Details of multiple users: `GET /api/0.6/users?users=#id1,#id2,...,#idn` ----
# This API method was added in July 2018 ([https://github.com/openstreetmap/openstreetmap-website/commit/b4106383d99ccbf152d79b0f2c9deca95df9fb61 code]).
#
# You can get the details of a number of users via
#
### Response XML ----
#  GET /api/0.6/users?users=#id1,#id2,...,#idn
# this returns for example
# <syntaxhighlight lang="xml">
# <osm version="0.6" generator="OpenStreetMap server">
# 	<user id="12023" display_name="jbpbis" account_created="2007-08-16T01:35:56Z">
# 		<description></description>
# 		<contributor-terms agreed="false"/>
# 		<img href="http://www.gravatar.com/avatar/c8c86cd15f60ecca66ce2b10cb6b9a00.jpg?s=256&amp;d=http%3A%2F%2Fwww.openstreetmap.org%2Fassets%2Fusers%2Fimages%2Flarge-39c3a9dc4e778311af6b70ddcf447b58.png"/>
# 		<roles>
# 		</roles>
# 		<changesets count="1"/>
# 		<traces count="0"/>
# 		<blocks>
# 			<received count="0" active="0"/>
# 		</blocks>
# 	</user>
# 	<user id="210447" display_name="siebh" account_created="2009-12-20T10:11:42Z">
# 		<description></description>
# 		<contributor-terms agreed="true"/>
# 		<roles>
# 		</roles>
# 		<changesets count="267"/>
# 		<traces count="1"/>
# 		<blocks>
# 			<received count="0" active="0"/>
# 		</blocks>
# 	</user>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/users.json?users=#id1,#id2,...,#idn
# <syntaxhighlight lang="json">
# {
#  "version": "0.6",
#  "generator": "OpenStreetMap server",
#  "users": [
#   {"user": {"id": 12023, "display_name": "jbpbis", "account_created": "2007-08-16T01:35:56Z", "description": "", "contributor_terms": {"agreed": False}, "roles": [], "changesets": {"count": 1}, "traces": {"count": 0}, "blocks": {"received": {"count": 0, "active": 0}}}},
#   {"user": {"id": 210447, "display_name": "siebh", "account_created": "2009-12-20T10:11:42Z", "description": "", "contributor_terms": {"agreed": True}, "roles": [], "changesets": {"count": 363}, "traces": {"count": 1}, "blocks": {"received": {"count": 0, "active": 0}}}}
#  ]
# }
# </syntaxhighlight>
#
# or an empty file if no user found for given identifier.
#
#
## Details of the logged-in user: `GET /api/0.6/user/details` ----
# You can get the home location and the displayname of the user, by using
#
### Response XML ----
#  GET /api/0.6/user/details
# this returns an XML document of the from
# <syntaxhighlight lang="xml">
# <osm version="0.6" generator="OpenStreetMap server">
# 	<user display_name="Max Muster" account_created="2006-07-21T19:28:26Z" id="1234">
# 		<contributor-terms agreed="true" pd="true"/>
# 		<img href="https://www.openstreetmap.org/attachments/users/images/000/000/1234/original/someLongURLOrOther.JPG"/>
# 		<roles></roles>
# 		<changesets count="4182"/>
# 		<traces count="513"/>
# 		<blocks>
# 			<received count="0" active="0"/>
# 		</blocks>
# 		<home lat="49.4733718952806" lon="8.89285988577866" zoom="3"/>
# 		<description>The description of your profile</description>
# 		<languages>
# 			<lang>de-DE</lang>
# 			<lang>de</lang>
# 			<lang>en-US</lang>
# 			<lang>en</lang>
# 		</languages>
# 		<messages>
# 			<received count="1" unread="0"/>
# 			<sent count="0"/>
# 		</messages>
# 	</user>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/user/details.json
# this returns an JSON document of the from
# <syntaxhighlight lang="json">
# {
#  "version": "0.6",
#  "generator": "OpenStreetMap server",
#  "user": {
#   "id": 1234,
#   "display_name": "Max Muster",
#   "account_created": "2006-07-21T19:28:26Z",
#   "description": "The description of your profile",
#   "contributor_terms": {"agreed": True, "pd": True},
#   "img": {"href": "https://www.openstreetmap.org/attachments/users/images/000/000/1234/original/someLongURLOrOther.JPG"},
#   "roles": [],
#   "changesets": {"count": 4182},
#   "traces": {"count": 513},
#   "blocks": {"received": {"count": 0, "active": 0}},
#   "home": {"lat": 49.4733718952806, "lon": 8.89285988577866, "zoom": 3},
#   "languages": ["de-DE", "de", "en-US", "en"],
#   "messages": {"received": {"count": 1, "unread": 0},
#   "sent": {"count": 0}}
#  }
# }
# </syntaxhighlight>
#
# The messages section has been available since mid-2013. It provides a basic counts of received, sent, and unread osm [[Web front end#User messaging|messages]].
#
#
## Preferences of the logged-in user: `GET /api/0.6/user/preferences` ----
# The OSM server supports storing arbitrary user preferences. This can be used by editors, for example, to offer the same configuration wherever the user logs in, instead of a locally-stored configuration. For an overview of applications using the preferences-API and which key-schemes they use, see [[preferences|this wiki page]].
#
# You can retrieve the list of current preferences using
#
### Response XML ----
#  GET /api/0.6/user/preferences
# this returns an XML document of the form
# <syntaxhighlight lang="xml">
# <osm version="0.6" generator="OpenStreetMap server">
# 	<preferences>
# 		<preference k="somekey" v="somevalue" />
# 		...
# 	</preferences>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/user/preferences.json
# this returns an JSON document of the form
# <syntaxhighlight lang="json">
# {
#  "version": "0.6",
#  "generator": "OpenStreetMap server",
#  "preferences": {"somekey": "somevalue, ...}
# }
# </syntaxhighlight>
#
#  PUT /api/0.6/user/preferences
#
# The same structure in the body of the a PUT will upload preferences. All existing preferences are replaced by the newly uploaded set.
#
#  GET /api/0.6/user/preferences/[your_key] (without the brackets)
#
# Returns a string with that preference's value.
#
#  PUT /api/0.6/user/preferences/[your_key] (without the brackets)
#
# Will set a single preference's value to a string passed as the content of the request.
#
#  PUT /api/0.6/user/preferences/[your_key]
#
# in this instance, the payload of the request should only contain the value of the preference, i.e. not XML formatted.
#
# The PUT call returns HTTP response code 406 (not acceptable) if the same key occurs more than once, and code 413 (request entity too large) if you try to upload more than 150 preferences at once. The sizes of the key and value are limited to 255 characters.
#
# A single preference entry can be deleted with
#
#  DELETE /api/0.6/user/preferences/[your_key]
