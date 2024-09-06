

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

import jolibs/generic/[g_json_plus, g_templates, g_json2html, g_tools]




const 
  versionfl:float = 0.51
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

  innervarob["text01"] = @"text01"
  innervarob["text02"] = @"text02"
  innervarob["text03"] = @"text03"
  
  # some sample logic has been provided


  if @"curaction" == "do action 1..":
    # reverseString done by javascript; no action needed here
    discard()

  if @"curaction" == "do action 2..":
    # calling a similar function from the nim server-side
    innervarob["text02"] = reverseString(@"text02")

  if @"curaction" == "do action 3..":
    var wordsq: seq[string] = 
      @["One sheep", "two sheep", "three sheep"]
    innervarob["text03"] = cycleSequence(wordsq, @"text03")
    

  # ****************** end of app-logic ***************************



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


