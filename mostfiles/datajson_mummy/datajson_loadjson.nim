
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

  Stored node (in mem or on disk):
  In this all tab-specific changes are stored, so 
  that the state of the tab's gui is saved. 
  When saved in memory this breaks multi-threading 
  because of a global var.
  When saved on disk the global var is omitted and 
  you can compile with multi-threading.

  The below constant "persisttype" determines the 
  behaviour.

 ]#



import std/[json, tables, os, times, strutils]
import jolibs/generic/[g_database, g_db2json, g_json_plus]


const storednodesdir = "stored_gui_nodes"

let durob = initDuration(hours = 6)
#let durob = initDuration(minutes = 30)

let versionfl: float = 0.3



type
  PersistModeJson* = enum
    persistNot        # use only initial node without storage-needs
    persistInMem
    persistOnDisk

#const persisttype* = persistInMem    # see enum above and module-info
const persisttype* = persistOnDisk    # see enum above and module-info



# create a table with jnobs, one for every tab
# (futural multi-user-approach)
#var jsondefta* {.threadvar.} = initTable[string, JsonNode]()
when persisttype == persistInMem:
  var jsondefta* = initTable[string, JsonNode]()



proc initialLoading(parjnob: JsonNode): JsonNode = 
  # custom - load extra public data to the json-object
  # this is a dummy function for now
  var 
    tablesq: seq[string]
    firstelems_pathsq: seq[string] = @["all web-pages", "first web-page", "web-elements fp", "your-elem-type"]
    newjnob: JsonNode = parjnob

  firstelems_pathsq = replaceLastItemOfSeq(firstelems_pathsq, "dropdowns fp")
  #graftJObjectToTree("All_tables", firstelems_pathsq, newjnob, 
  #                  createDropdownNodeFromDb("All_tables", "sqlite_master", @["name", "name"], 
  #                      compString, @[["type", "table"]], @["name"], "ASC"))
  graftJObjectToTree("All_tables", firstelems_pathsq, newjnob, 
                    createDropdownNodeFromDb("All_tables", "sqlite_master", @["name", "name"], 
                        compNotSub, @[["type", "index"],["name", "sqlite"]], @["name"], "ASC"))

  result = parjnob




proc readInitialNode*(proj_prefikst: string): JsonNode = 
  var 
    filest: string
    jnob, secondjnob: JsonNode

  filest = proj_prefikst & "_gui.json"
  jnob = parseFile(filest)
  secondjnob = initialLoading(jnob)

  result = secondjnob





proc readStoredNode*(tabIDst, project_prefikst: string): JsonNode = 

  var filepathst: string


  when persisttype == persistInMem:
    if not jsondefta.hasKey(tabIDst):
        jsondefta.add(tabIDst, readInitialNode(project_prefikst))
        #echo "====*******========************======="
    result = jsondefta[tabIDst]

  elif persisttype == persistOnDisk:
    filepathst = storednodesdir / tabIDst & ".json"
    if existsOrCreateDir(storednodesdir):
      if fileExists(filepathst):
        result = parseFile(filepathst)
      else:
        result = readInitialNode(project_prefikst)
    else:
      result = readInitialNode(project_prefikst)




proc backupFile(filepathst:string): string =
  # copy the given file to one with the suffix .bak
  
  var 
    fulldirst: string
    filest:string
    bakfilest:string
    bakfilepathst:string
  
  (fulldirst, filest) = splitPath(filepathst)
  bakfilest = filest & ".bak"
  bakfilepathst = joinPath(fulldirst, bakfilest)
  copyFile(filepathst,bakfilepathst)
  return bakfilepathst



proc updateAccessBook(tabIDst: string) =   
  #[ 
  Find tabidst in file and update the corresponding
  time-stamp.
   ]#

  var filepathst, bakfilepathst: string

  filepathst = storednodesdir / "node_access_book.txt"
  
  if not fileExists(filepathst):
    writeFile(filepathst, "")

  bakfilepathst = backupFile(filepathst)

  var
    bob = open(bakfilepathst, fmRead)
    fob = open(filepathst, fmWrite)

  for line in bob.lines:
    if not (tabIDst in line):
      fob.writeLine(line)

  fob.writeLine(tabIDst & "__" & format(now(), "yyyy-MM-dd'T'HH-mm-ss"))

  bob.close()
  fob.close()

  removeFile(bakfilepathst)




proc writeStoredNode*(tabIDst: string, storedjnob: JsonNode) = 
  
  var filepathst: string

  when persisttype == persistInMem:
    # store in table of json-nodes
    jsondefta[tabIDst] = storedjnob
  elif persisttype == persistOnDisk:
    #then serialize with pretty and write to file
    filepathst = storednodesdir / tabIDst & ".json"
    writeFile(filepathst, pretty(storedjnob))
    updateAccessBook(tabIDst)
    



proc deleteExpiredFromAccessBook*() =
  #[
  pseudocode:
  for every line in access-book:
    get the time-stamp
    see it time-stamp has been expired
      (meaning time-now > time-stamp plus predefined duration)
      if yes:
        remove json-file
        remove the line from the access-book
  ]#

  var 
    filepathst, bakfilepathst, tabIDst: string
    linesq: seq[string] = @[]
    timeob: DateTime


  filepathst = storednodesdir / "node_access_book.txt"
  
  if fileExists(filepathst):

    bakfilepathst = backupFile(filepathst)

    var
      bob = open(bakfilepathst, fmRead)
      fob = open(filepathst, fmWrite)

    for line in bob.lines:
      linesq = line.split("__")
      timeob = parse(linesq[1], "yyyy-MM-dd'T'HH-mm-ss")
      tabIDst = linesq[0]

      if now() > timeob + durob:
        # file-expiration-time reached
        removeFile(storednodesdir / tabIDst & ".json" )
      else:
        # keep file-line in access-book
        fob.writeLine(line)


    bob.close()
    fob.close()

    removeFile(bakfilepathst)



proc theTimeIsRight*(): bool = 
  
  #[ 
    look if a certain time-element is reached 
    in order to perform an operation only a certain
    percentage of the time.
    e.g. [4,14,24,34,44,54] returns true 10 % of the time.
   ]#

  if minute(now()) in [4,14,24,34,44,54]:
    result = true
  else:
    result = false






when isMainModule:
  #deleteExpiredFromAccessBook()
  echo ifTheTimeIsRight()

