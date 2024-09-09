

#[ Sample-project "controls" to learn how to use mummy, moustachu and
my json-modules (html-elements generated from a json-definition-file).

Beware of the fact  that there are two kinds of variables:
-moustachu-variables in the html-code, in which the generated html-controls are 
substituted. Designated with {{}} or {{{}}}. Sometimes two braces are enough,
but it is saver to use three to avoid premature evaluation.
-control-variables used by jester / mummy. Jester/mummy reads control-states and puts them 
in either of two variables (i dont know if they are fully equivalent):
* variables like @"controlname"
* request.params["controlname"]

Do not use global vars because the are not "gc-safe". GC stands for garbage-collection.
My (layman-) theory is that all threads have there own garbage-collection.
When the main thread has nothing to do with other threads globals can gc-ed allright, 
but when extra threads have been spawned, the gc of different threads gets mixed up 
concerning the globals, and therefore in that case globals have been forbidden.
(Allthoe i kinda understand it, i find it a pretty big drawback..)

Without globals you can compile for multi-threading
with switch --threads:on which is mandatory in mummy (but not in jester)

See also the module projectprefix_loadjson.nim
Currently --threads :on compiles and runs succesfully under  
persistence-mode = persistOnDisk in projectprefix_loadjson.nim. 
See that module for further info.

The cookie-tunnel code has been removed because one can easily run server-code thru
the cur-action variable . This is a textarea element that can be set from javascript,
and after a form-submit can be read on the server to execute the needed server-code.


ADAP HIS
-change static_config and calls

ADAP NOW

ADAP FUT
- implement persistInBrowser to avoid server-load

]#

import mummy, mummy/routers, mummy_utils, moustachu
import std/[times, json, tables, strutils]

import starter_loadjson, starter_logic

import jolibs/generic/[g_json_plus, g_json2html]

#import jolibs/generic/[g_json_plus, g_templates, g_json2html, g_tools]



const 
  versionfl:float = 1.0
  project_prefikst = "starter"
  appnamebriefst = "ST"
  appnamenormalst = "Starter"
  appnamelongst = "Starter_template"
  appnamesuffikst = " showcase"
  portnumberit = 5180





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

#to understand why a project is not gcsafe, add the pragma {.gcsafe.} to get more info
#proc getProject(request: Request) {.gcsafe.} = 


  var
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
    innervarob: Context = newContext()  # inner html insertions
    outervarob: Context = newContext()   # outer html insertions
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
    # reverseString done by javascript; no action needed here; see project_script.js
    discard()

  if @"curaction" == "do action 2..":
    # calling a similar function from the nim server-side
    innervarob["text02"] = reverseString(@"text02")

  if @"curaction" == "do action 3..":
    # cycle thru words
    var wordsq: seq[string] = @["One sheep", "two sheep", "three sheep"]
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


