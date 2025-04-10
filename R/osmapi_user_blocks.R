# User Blocks

## Create: `POST /api/0.6/user_blocks` ----
#
### Parameters ----
#
# {| class="wikitable"
# |-
# ! Parameter
# ! Description
# ! Allowed values
# ! Default value
# |-
# | <code>user</code>
# | Blocked user id
# | Integer; User id
# | No default, needs to be specified
# |-
# | <code>reason</code>
# | Reason for block shown to the blocked user
# | Markdown text
# | No default, needs to be specified
# |-
# | <code>period</code>
# | Block duration in hours
# | Integer between 0 and maximum block period, currently 87660
# | No default, needs to be specified
# |-
# | <code>needs_view</code>
# | Whether the user is required to view the block page for the block to be lifted
# | <code>true</code>
# | None, optional parameter
# |}
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : When any of the required parameters is missing or has invalid value
# ; HTTP status code 404 (Not found)
# : When blocked user is not found


## Read: `GET /api/0.6/user_blocks/#id` ----
#
### Response XML ----
#  GET /api/0.6/user_blocks/#id
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="http://www.openstreetmap.org/copyright" license="http://opendatacommons.org/licenses/odbl/1-0/">
#   <user_block id="96" created_at="2025-01-21T23:23:50Z" updated_at="2025-01-21T23:24:16Z" ends_at="2025-01-21T23:24:16Z" needs_view="false">
#     <user uid="3" user="fakeuser1"/>
#     <creator uid="5" user="fakemod1"/>
#     <revoker uid="5" user="fakemod1"/>
#     <reason>reason text
#
# more reason text</reason>
#   </user_block>
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/user_blocks/#id.json
# <syntaxhighlight lang="json">
# {
#   "version":"0.6",
#   "generator":"OpenStreetMap server",
#   "copyright":"OpenStreetMap and contributors",
#   "attribution":"http://www.openstreetmap.org/copyright",
#   "license":"http://opendatacommons.org/licenses/odbl/1-0/",
#   "user_block":{
#     "id":96,
#     "created_at":"2025-01-21T23:23:50Z",
#     "updated_at":"2025-01-21T23:24:16Z",
#     "ends_at":"2025-01-21T23:24:16Z",
#     "needs_view":false,
#     "user":{"uid":3,"user":"fakeuser1"},
#     "creator":{"uid":5,"user":"fakemod1"},
#     "revoker":{"uid":5,"user":"fakemod1"},
#     "reason":"reason text\r\n\r\nmore reason text"
#   }
# }
# </syntaxhighlight>


## List active blocks: `GET /api/0.6/user/blocks/active` ----
#
# Allows the applications to check if the currently authorized user is blocked.
# This endpoint is accessible even with an active block, unlike some other endpoints requiring authorization.
#
### Response XML ----
#  GET /user/blocks/active
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="http://www.openstreetmap.org/copyright" license="http://opendatacommons.org/licenses/odbl/1-0/">
#   <user_block id="101" created_at="2025-02-22T02:11:55Z" updated_at="2025-02-22T02:11:55Z" ends_at="2025-02-22T03:11:55Z" needs_view="true">
#     <user uid="5" user="fakemod1"/>
#     <creator uid="115" user="fakemod2"/>
#   </user_block>
#   <user_block id="100" created_at="2025-02-22T02:11:10Z" updated_at="2025-02-22T02:11:10Z" ends_at="2025-02-22T02:11:10Z" needs_view="true">
#     <user uid="5" user="fakemod1"/>
#     <creator uid="115" user="fakemod2"/>
#   </user_block>
#   ...
# </osm>
# </syntaxhighlight>
#
# Empty <osm> element indicates no active blocks.
#
### Response JSON ----
# GET /user/blocks/active.json
# <syntaxhighlight lang="json">
# {
#   "version":"0.6","generator":"OpenStreetMap server","copyright":"OpenStreetMap and contributors","attribution":"http://www.openstreetmap.org/copyright","license":"http://opendatacommons.org/licenses/odbl/1-0/",
#   "user_blocks":[
#     {
#       "id":101,
#       "created_at":"2025-02-22T02:11:55Z",
#       "updated_at":"2025-02-22T02:11:55Z",
#       "ends_at":"2025-02-22T03:11:55Z",
#       "needs_view":true,
#       "user":{"uid":5,"user":"fakemod1"},
#       "creator":{"uid":115,"user":"fakemod2"}
#     },
#     {
#       "id":100,
#       "created_at":"2025-02-22T02:11:10Z",
#       "updated_at":"2025-02-22T02:11:10Z",
#       "ends_at":"2025-02-22T02:11:10Z",
#       "needs_view":true,
#       "user":{"uid":5,"user":"fakemod1"},
#       "creator":{"uid":115,"user":"fakemod2"}
#     },
#     ...
#   ]
# }
# </syntaxhighlight>
#
# Empty <code>user_blocks</code> array indicates no active blocks.
