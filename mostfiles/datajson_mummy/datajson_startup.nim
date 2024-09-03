

#[ Sample-project "controls" to learn how to use jester, moustachu and
g_html_json (html-elements generated from a json-definition-file).

Beware of the fact  that there are two kinds of variables:
-moustachu-variables in the html-code, in which the generated html-controls are 
substituted. Designated with {{}} or {{{}}}. Sometimes two braces are enough,
but it is saver to use three to avoid premature evaluation.
-control-variables used by jester. Jester reads control-states and puts them 
in either of two variables (i dont know if they are fully equivalent):
* variables like @"controlname"
* request.params["controlname"]

Do not use global vars  or otherwise you can not compile for multi-threading
with switch --threads:on which is mandatory in mummy (but not in jester)

See also the module datajson_loadjson.nim
Currently --threads :on compiles and runs succesfully under  
persistence-mode = persistOnDisk in datajson_loadjson.nim. 
See that module for further info.




ADAP HIS
-change static_config and calls

ADAP NOW

ADAP FUT
- implement persistInBrowser to avoid server-load

]#

import mummy, mummy/routers, mummy_utils, moustachu
import std/[times, json, os, tables]
import db_connector/db_sqlite

import datajson_loadjson, datajson_logic

import jolibs/generic/[g_db2json, g_json_plus, g_database, g_templates, g_json2html, g_tools, g_cookie]




const 
  versionfl:float = 11.0
  project_prefikst = "datajson"
  appnamebriefst = "DJ"
  appnamenormalst = "DataJson"
  appnamelongst = "Database thru json"
  appnamesuffikst = " showcase"
  portnumberit = 5170
  # Make sure to get/show all elements that you are referring to, 
  # or crashes may occur
  showelems = showEntryFilterRadio

  firstelems_pathst = @["all web-pages", "first web-page", "web-elements fp"]


#settings:
#  port = Port(portnumberit)



proc showPage(par_innervarob, par_outervarob: var Context, 
              custominnerhtmlst:string=""): string = 

  var innerhtmlst:string
  if custominnerhtmlst == "":
    innerhtmlst = render(readFile(project_prefikst & "_inner.html") , par_innervarob)    
  else:
    innerhtmlst = custominnerhtmlst
  par_outervarob["controls-group"] = innerhtmlst

  return render(readFile(project_prefikst & "_outer.html"), par_outervarob)




proc getRoot(request: Request) = 
  # retrieve the json-file

  resp "Type: localhost:" & $portnumberit & "/" & project_prefikst



proc sayHello(request: Request) = 
  resp "Hello world"



proc getDatajson(request: Request) {.gcsafe.} = 
  # hard code because following does not work:
  # get ("/" & project_prefikst):

  var
    statustekst:string
    innervarob: Context = newContext()  # inner html insertions
    outervarob: Context = newContext()   # outer html insertions

  innervarob["statustext"] = """Status OK"""

  var initialjnob = datajson_loadjson.readInitialNode(project_prefikst)

  innervarob["newtab"] = "_self"
  outervarob["version"] = $versionfl
  outervarob["loadtime"] ="Page-load: " & $now()
  outervarob["namenormal"] = appnamenormalst
  outervarob["namelong"] = appnamelongst
  outervarob["namesuffix"] = appnamesuffikst
  outervarob["pagetitle"] = appnamelongst & appnamesuffikst   
  outervarob["project_prefix"] = project_prefikst

  innervarob["project_prefix"] = project_prefikst  
  #innervarob["dropdown1"] = setDropDown(initialjnob, "dropdownname_01", "", 1)
  innervarob["dropdown1"] = setDropDown(initialjnob, "All_tables", "", 1)

  innervarob["table01"] = setTableBasic(initialjnob, "table_01")

  resp showPage(innervarob, outervarob)






proc postDatajson(request: Request)  = 

  var
    statustekst, righttekst, tempst:string
    innervarob: Context = newContext()  # inner html insertions
    outervarob: Context = newContext()   # outer html insertions
    cookievaluest, locationst, mousvarnamest: string
    funcpartsta =  initOrderedTable[string, string]()
    firstelems_pathsq: seq[string] = @["all web-pages", "first web-page", "web-elements fp", "your-element"]
    gui_jnob: JsonNode
    recordsq: seq[Row] = @[]
    id_fieldst, fieldnamest, id_valuest, id_typest, tabidst, filternamest, filtervaluest: string
    colcountit, countit, addcountit: int
    fieldtypesq, fieldvaluesq, filtersq: seq[array[2, string]] = @[]
    filtervaluesq: seq[string] = @[]
    tablechangedbo: bool = false


  when persisttype == persistNot:
    gui_jnob = readInitialNode(project_prefikst)
  else:
    when persisttype == persistOnDisk: 
      if theTimeIsRight():
        deleteExpiredFromAccessBook()
    if len(@"tab_ID") == 0:
      tabidst = genTabId()
    else:
      tabidst = @"tab_ID"

    gui_jnob = readStoredNode(tabidst, project_prefikst)
    innervarob["tab_id"] = tabidst



  innervarob["newtab"] = "_self"
  outervarob["version"] = $versionfl
  outervarob["loadtime"] ="Page-load: " & $now()

  outervarob["namenormal"] = appnamenormalst
  outervarob["namelong"] = appnamelongst
  outervarob["namesuffix"] = appnamesuffikst
  outervarob["pagetitle"] = appnamelongst & appnamesuffikst   
  outervarob["project_prefix"] = project_prefikst     


  innervarob["project_prefix"] = project_prefikst  
  innervarob["linkcolor"] = "red"

  #echo gui_jnob
  innervarob["dropdown1"] = setDropDown(gui_jnob, "All_tables", 
                                                        @"All_tables", 1)

  firstelems_pathsq = replaceLastItemOfSeq(firstelems_pathsq, "basic tables fp")

  #delete old table-data from jsonnode
  when persisttype != persistNot:
    pruneJnodesFromTree(gui_jnob, firstelems_pathsq, getAllUserTables())


  #echo @"All_tables"
  fieldtypesq = getFieldAndTypeList(@"All_tables")
  id_fieldst = fieldtypesq[0][0]
  id_typest = fieldtypesq[0][1]
  fieldvaluesq = fieldtypesq
  #echo id_fieldst



  if @"curaction" == "new table..":
    innervarob["statustext"] = readFromParams("sqlite_master", @["sql"], compString, 
                                        @[["name", @"All_tables"]])[0][0]
    tablechangedbo = true

  #echo "~~~~~~~~~~~~~~~"
  addcountit = 0
  # Collect filter-values
  # Sample the var fieldtypesq to create filtersq for the filter-values
  # to (re)query thru createHtmlTableNodeFromDB
  if not tablechangedbo:   # only in the second pass when stuff has been created
    colcountit = getColumnCount(@"All_tables")
    #echo "colcountit: ", colcountit
    for countit in 1..colcountit:
      filternamest = "filter_" & $countit
      if request.params.haskey(filternamest):     # needy for colcount-changes with new table-load
        filtervaluest = request.params[filternamest]

        if filtervaluest.len > 0:
          filtersq.add(["",""])
          filtersq[addcountit][0] = fieldtypesq[countit - 1][0]
          filtersq[addcountit][1] = filtervaluest
          addcountit += 1

          #echo filtersq
          #echo filternamest
          #echo filtervaluesq
          #echo "countit: ", countit
          #echo "addcountit: ", addcountit
          #echo "============"

        # also needy for setTable to restore the filter-values
        filtervaluesq.add(filtervaluest)


  if @"curaction" in ["saving..", "deleting.."]:
    # Reuse the var fieldvaluesq and overwrite the second field 'type' for the data-values
    colcountit = getColumnCount(@"All_tables")
    for countit in 1..colcountit:
      fieldnamest = "field_" & $countit
      if request.params.haskey(fieldnamest):
        #echo request.params[fieldnamest]
        #echo @fieldnamest

        if countit == 1:
          id_valuest = request.params[fieldnamest]

        # Reuse the var and overwrite the second field 'type' for the values
        fieldvaluesq[countit - 1][1] = request.params[fieldnamest]



  # table loading starts here
  if not tablechangedbo:
    graftJObjectToTree(@"All_tables", firstelems_pathsq, gui_jnob, 
              createHtmlTableNodeFromDB(@"All_tables", compSub, filtersq))
  else:
    graftJObjectToTree(@"All_tables", firstelems_pathsq, gui_jnob, 
                        createHtmlTableNodeFromDB(@"All_tables"))



  #echo @"radiorecord"
  if @"radiorecord" == "":
    if not tablechangedbo:
      innervarob["table01"] = setTableDbOpt(gui_jnob, @"All_tables", 
                                                       showelems, filtersq = filtervaluesq)
    else:
      innervarob["table01"] = setTableDbOpt(gui_jnob, @"All_tables", showelems)
  else:
    if not tablechangedbo:
      recordsq = readFromParams(@"All_tables", @[], compString, @[[id_fieldst, @"radiorecord"]])
      #echo recordsq
      if len(recordsq) > 0:
        if len(recordsq[0]) > 0:    # the record exist?
          innervarob["table01"] = setTableDbOpt(gui_jnob, @"All_tables", showelems,
                                  @"radiorecord" , recordsq[0], filtervaluesq)
      else:
        innervarob["table01"] = setTableDbOpt(gui_jnob, @"All_tables", showelems, 
                                                            filtersq = filtervaluesq)
    else:
      innervarob["table01"] = setTableDbOpt(gui_jnob, @"All_tables", showelems)





  if @"curaction" == "saving..":

    try:
      if len(id_valuest) == 0:    # empty-idfield 
        # must become new record if db-generated
        if getKeyFieldStatus(@"All_tables") == genIntegerByDb:
          #remove the id-field:
          fieldvaluesq.delete(0)
          addNewFromParams(@"All_tables", fieldvaluesq)
        else:
          innervarob["statustext"] = """Cannot save the record because 
            the ID-field has been left empty and the ID-value is not 
            automatically generated for this table."""

      else:   # filled id-field
        if idValueExists(@"All_tables", id_fieldst, id_valuest):
          # record exists allready; perform an update of the values only.
          fieldvaluesq.delete(0)
          updateFromParams(@"All_tables", fieldvaluesq, compString, @[[id_fieldst, id_valuest]])
        else:     # a new record will be entered with the given id-value
          # id-data must be kept in var fieldvaluesq

          addNewFromParams(@"All_tables", fieldvaluesq)


      # requery including the new record
      graftJObjectToTree(@"All_tables", firstelems_pathsq, gui_jnob, 
                           createHtmlTableNodeFromDB(@"All_tables", compSub, filtersq))

      innervarob["table01"] = setTableDbOpt(gui_jnob, @"All_tables", showelems, 
                                                        filtersq = filtervaluesq)


    except DbError:
      innervarob["statustext"] = getCurrentExceptionMsg()


    except:
      let errob = getCurrentException()
      echo "\p******* Unanticipated error ******* \p" 
      echo repr(errob) & "\p****End exception****\p"



  if @"curaction" == "deleting..":
    if len(id_valuest) > 0:    # idfield must present
      deleteFromParams(@"All_tables", compString, @[[id_fieldst, id_valuest]])

      # requery - deletion gone well?
      graftJObjectToTree(@"All_tables", firstelems_pathsq, gui_jnob, 
                           createHtmlTableNodeFromDB(@"All_tables", compSub, filtersq))
      innervarob["table01"] = setTableDbOpt(gui_jnob, @"All_tables", showelems, 
                                                          filtersq = filtervaluesq)
    else:
      innervarob["statustext"] = "Only records with ID-field can be deleted.."



  # A server-function may have been called from client-side (browser-javascript) by
  # preparing a cookie for the server (that is here) to pick up and execute.
  # (what i call a cookie-tunnel)
  if request.cookies.haskey(project_prefikst & "_run_function"):
    cookievaluest = request.cookies[project_prefikst & "_run_function"]
    if cookievaluest != "DISABLED":
      funcpartsta = getFuncParts(cookievaluest) 
      locationst = funcpartsta["location"]  # innerhtml-page or outerhtml-page
      mousvarnamest = funcpartsta["mousvarname"]

      if locationst == "inner":
        innervarob[mousvarnamest] = runFunctionFromClient(funcpartsta, gui_jnob)
      elif locationst == "outer":
        outervarob[mousvarnamest] = runFunctionFromClient(funcpartsta, gui_jnob)



  when persisttype != persistNot:
    writeStoredNode(tabidst, gui_jnob)

  resp showPage(innervarob, outervarob)




proc cssHandler*(request: Request) =
  var headers: HttpHeaders
  headers["Content-Type"] = "text/css"
  request.respond(200, headers, readFile("public/" & project_prefikst & "_sheet.css"))


proc scriptHandler*(request: Request) =
  var headers: HttpHeaders
  headers["Content-Type"] = "text/javascript"
  request.respond(200, headers, readFile("public/" & project_prefikst & "_script.js"))



var router: Router

router.get("/public/" & project_prefikst & "_sheet.css", cssHandler)
router.get("/public/" & project_prefikst & "_script.js", scriptHandler)
router.get("/", getRoot)
router.get("/hello", sayHello)
router.get("/datajson", getDatajson)
router.post("/datajson", postDatajson)



let server = newServer(router)
echo "Serving on http://localhost:" & $portnumberit
server.serve(Port(portnumberit))


