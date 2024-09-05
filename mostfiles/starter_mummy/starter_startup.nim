

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

See also the module projectprefix_loadjson.nim
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
import std/[times, json, os, tables, strutils]

import starter_loadjson, starter_logic

import jolibs/generic/[g_json_plus, g_templates, g_json2html, g_tools, g_cookie]




const 
  versionfl:float = 0.5
  project_prefikst = "starter"
  appnamebriefst = "ST"
  appnamenormalst = "Starter"
  appnamelongst = "Starter_template"
  appnamesuffikst = " showcase"
  portnumberit = 5180
  # Make sure to get/show all elements that you are referring to, 
  # or crashes may occur
  showelems = showEntryFilterRadio

  firstelems_pathst = @["all web-pages", "first web-page", "web-elements fp"]




proc showPage(par_innervarob, par_outervarob: var Context, 
              custominnerhtmlst:string=""): string = 

  var innerhtmlst:string
  if custominnerhtmlst == "":
    innerhtmlst = render(readFile(project_prefikst & "_inner.html") , par_innervarob)    
  else:
    innerhtmlst = custominnerhtmlst
  par_outervarob["controls-group"] = innerhtmlst

  return render(readFile(project_prefikst & "_outer.html"), par_outervarob)



proc runFunctionFromClient*(funcPartsta: OrderedTable[string, string], jnob: JsonNode): string = 

  # run the function
  if funcPartsta["funcname"] == "dummyPass":
    result = dummyPass(funcPartsta["newcontent"])
  #elif funcPartsta["funcname"] == "setDropDown":
  #  result = setDropDown(jnob, funcPartsta["html-elem-name"], funcPartsta["selected-value"], 
  #    parseInt(funcPartsta["dd-size"]))


#     "funcname:setDropDown++location:inner++varname:dropdown1++param2:dropdownname_01++param3:third realvalue++param4:1", 60);
# proc setDropDown*(jnob: JsonNode, dropdownnamest, selected_valuest: string, 
#                     sizeit: int):string = 



# ************************ PAGE-HANDLERS STARTING HERE ****************************************

proc getRoot(request: Request) = 
  # retrieve the json-file

  resp "Type: localhost:" & $portnumberit & "/" & project_prefikst



proc sayHello(request: Request) = 
  resp "Hello world"



proc getProject(request: Request) = 
#proc getStarter(request: Request) {.gcsafe.} = 


  var
    statustekst:string
    innervarob: Context = newContext()  # inner html insertions
    outervarob: Context = newContext()   # outer html insertions

  innervarob["statustext"] = """Status OK"""

  var initialjnob = starter_loadjson.readInitialNode(project_prefikst)

  innervarob["newtab"] = "_self"
  outervarob["version"] = $versionfl
  outervarob["loadtime"] ="Page-load: " & $now()
  outervarob["namenormal"] = appnamenormalst
  outervarob["namelong"] = appnamelongst
  outervarob["namesuffix"] = appnamesuffikst
  outervarob["pagetitle"] = appnamelongst & appnamesuffikst   
  outervarob["project_prefix"] = project_prefikst

  innervarob["project_prefix"] = project_prefikst  
  

  resp showPage(innervarob, outervarob)




proc postProject(request: Request)  = 

  # boiler-plate code
  var
    statustekst, righttekst, tempst:string
    innervarob: Context = newContext()  # inner html insertions
    outervarob: Context = newContext()   # outer html insertions
    cookievaluest, locationst, mousvarnamest: string
    funcpartsta =  initOrderedTable[string, string]()
    firstelems_pathsq: seq[string] = @["all web-pages", "first web-page", "web-elements fp", "your-element"]
    gui_jnob: JsonNode
    tabidst: string = ""


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


  # ****************** put your app-logic here *******************

  # some sample logic has been provided


  if @"curaction" == "do action 1..":
    discard()

  if @"curaction" == "do action 2..":
    discard()

  if @"curaction" == "do action 3..":
    discard()

  # ****************** end of app-logic ***************************



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




# ************** ROUTE-DEFINITIONS HERE *******************************

var router: Router

router.get("/public/" & project_prefikst & "_sheet.css", cssHandler)
router.get("/public/" & project_prefikst & "_script.js", scriptHandler)
router.get("/", getRoot)
router.get("/hello", sayHello)
router.get("/" & project_prefikst, getProject)
router.post("/" & project_prefikst, postProject)



let server = newServer(router)
echo "Serving on http://localhost:" & $portnumberit
server.serve(Port(portnumberit))


