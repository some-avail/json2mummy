
#[ Module-function: 
  This module concerns both the initial json-node
  and the stored json-node that is bound to a tab-ID.


  Initial node:
  Read the json-file, convert it to a jnob,
  load additional public data to the jnob, and 
  expose it as function.

  Public in this context means unchangable data
  relevant to all users.
  User-data must be loaded from the routes-location
  in project_startup.nim to avoid shared data.

  Stored node in memory:
  In this all tab-specific changes are stored, so 
  that the state of the tab's gui is saved. 
  When saved in memory this breaks no longer 
  multi-threading because of a global var,
  since now official locking-mechanisms are used.
  (always use withlock for all global heap-structure-ops, 
  preferably use pre-made operations to minimize errors).

  When you want to use this code in production (website) you 
  must add code to remove unused IDs from jsondefta. (see adap fut)

  ADAP HIS:
  - alternate persistance to disk has been deprecated / removed

  ADAP FUT:
  -implement periodical clearance of jsondefta to avoid 
  out-of-memory-situation
  -refactor this module by:
    -leaving the project-specific code in projprefix_loadjson
    -moving the generic code to g_loadjson.nim
 ]#


import std/[json, tables, os, times, strutils, locks]

# only import g_json_plus and g_db2json when needed
#import jolibs/generic/[g_json_plus]
#import jolibs/generic/[g_db2json]


let versionfl: float = 0.53


var liblock: Lock
initLock(liblock)


# create a table with jnobs, one for every tab
#when persisttype == persistInMem:
var jsondefta = initTable[string, JsonNode]()


proc addOrUpdateDefTable(jsondefta: var Table[string, JsonNode]; nodeob: JsonNode; tabidst: string) = 
  # gc-safe operations; add or update
  # do it present or not
  withLock liblock:
    jsondefta[tabidst] = nodeob

proc addDefTable(jsondefta: var Table[string, JsonNode]; nodeob: JsonNode; tabidst: string) = 
  # gc-safe operations; add
  # only if not yet present
  withLock liblock:
    if not jsondefta.hasKey(tabidst):
      jsondefta[tabidst] = nodeob

proc readDefTable*(jsondefta: var Table[string, JsonNode]; tabidst: string): JsonNode =
# gc-safe operations; read
  withLock liblock:
    if jsondefta.hasKey(tabidst):
      result = jsondefta[tabidst]
    else:
      result = newJNull()



#[
#  BELOW PROCS ARE NOT YET USED

proc updateDefTable*(jsondefta: var Table[string, JsonNode]; nodeob: JsonNode; tabidst: string) = 
  # gc-safe operations; update
  # only if present
  withLock liblock:
    if jsondefta.hasKey(tabidst):
      jsondefta[tabidst] = nodeob

proc deleteDefTable*(jsondefta: var Table[string, JsonNode]; tabidst: string) =
  # gc-safe operations; delete
  withLock liblock:
    if jsondefta.hasKey(tabidst):
      jsondefta.del(tabidst)
]#


proc initialLoading(parjnob: JsonNode): JsonNode = 
  #[
  custom - load extra public data to the json-object (for example a user-list from a database)
  This is the only custom / project-specific function in this module.
  Currently not used; it passes the jnob thru.
  ]#


  #var 
  #  tablesq: seq[string]
  #  firstelems_pathsq: seq[string] = @["all web-pages", "first web-page", "web-elements fp", "your-elem-type"]
  #  newjnob: JsonNode = parjnob

  #firstelems_pathsq = replaceLastItemOfSeq(firstelems_pathsq, "dropdowns fp")
  #graftJObjectToTree("All_tables", firstelems_pathsq, newjnob, 
  #                  createDropdownNodeFromDb("All_tables", "sqlite_master", @["name", "name"], 
  #                      compNotSub, @[["type", "index"],["name", "sqlite"]], @["name"], "ASC"))

  result = parjnob




proc readInitialNode*(proj_prefikst: string): JsonNode = 

  # read a stored json-file and use it as the initial gui-config

  var 
    filest: string
    jnob, secondjnob: JsonNode

  filest = proj_prefikst & "_gui.json"
  jnob = parseFile(filest)
  # optionally add data below
  secondjnob = initialLoading(jnob)

  result = secondjnob



proc readStoredNode*(tabIDst, project_prefikst: string): JsonNode  = 

  # read the memory-stored json-config belonging to this webpage-id

  {.gcsafe.}:
    addDefTable(jsondefta, readInitialNode(project_prefikst), tabIDst)  #   only if not present
    result = jsondefta[tabIDst]




proc copyStoredNode*(oldtabIDst, newtabIDst: string) = 

  # copy a stored node and link it a new ID (usefull after cloning a tab)

  var 
    oldstoredjnob: JsonNode

  {.gcsafe.}:
    oldstoredjnob = readDefTable(jsondefta, oldtabIDst)
    # store in table of json-nodes
    addDefTable(jsondefta, oldstoredjnob, newtabIDst) 



proc writeStoredNode*(tabIDst: string, storedjnob: JsonNode) = 

  # when a page has changed config you must write a to the ID-linked json-node

  {.gcsafe.}:
    # store in table of json-nodes
    addOrUpdateDefTable(jsondefta, storedjnob, tabIDst)   # existing or not

    



when isMainModule:
  #deleteExpiredFromAccessBook()
  echo "hi"

