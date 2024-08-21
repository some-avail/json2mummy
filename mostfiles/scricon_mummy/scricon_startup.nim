

#[ Sample-project "scricon" to learn how to use jester, moustachu and
g_html_json (html-elements generated from a json-definition-file).

Beware of the fact  that there are two kinds of variables:
-moustachu-variables in the html-code, in which the generated html-controls are 
substituted. Designated with {{}} or {{{}}}. Sometimes two braces are enough,
but it is saver to use three to avoid premature evaluation.
-control-variables used by jester. Jester reads control-states and puts them 
in either of two variables (i dont know if they are fully equivalent):
* variables like @"controlname"
* request.params["controlname"]


ADAP HIS
-change static_config and calls

ADAP NOW


]#

import mummy, mummy/routers, mummy_utils, moustachu
import times, json, os, tables
from scricon_loadjson import nil
from g_html_json import nil
from g_tools import nil



const 
  versionfl:float = 0.2
  project_prefikst = "scricon"
  appnamebriefst = "SC"
  appnamenormalst = "ScriCon"
  appnamelongst = "Scripted Controls"
  appnamesuffikst = " showcase"
  portnumberit = 5160


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



  # sleep 1000
  # echo "hai"
  # echo $now()


proc getScricon*(request: Request) = 

# hard code because following does not work:
  # get ("/" & project_prefikst):

  var
    statustekst:string
    innervarob: Context = newContext()  # inner html insertions
    outervarob: Context = newContext()   # outer html insertions
  innervarob["statustext"] = """Basic webserver with some controls generated from 
  a gui-definition-file in json-format. 
  The webserver-interface without cliental javascript has only one button:
  submit your request to the server. Switches (like below) indicate what you want to do."""

  var gui_jnob = scricon_loadjson.getGuiJsonNode(project_prefikst)

  innervarob["newtab"] = "_self"
  outervarob["version"] = $versionfl
  outervarob["loadtime"] ="Page-load: " & $now()
  outervarob["namenormal"] = appnamenormalst
  outervarob["namelong"] = appnamelongst
  outervarob["namesuffix"] = appnamesuffikst
  outervarob["pagetitle"] = appnamelongst & appnamesuffikst   
  outervarob["project_prefix"] = project_prefikst

  innervarob["project_prefix"] = project_prefikst  
  innervarob["dropdown1"] = g_html_json.setDropDown(gui_jnob, "dropdownname_01", "", 1)
  innervarob["dropdown2"] = g_html_json.setDropDown(gui_jnob, "dropdownname_02", "", 1)
  innervarob["dropdown3"] = g_html_json.setDropDown(gui_jnob, "dropdownname_03", "", 3)
  innervarob["radiobuttonset1"] = g_html_json.setRadioButtons(gui_jnob, 
                                          "radiosetexample", "")
  innervarob["checkboxset1"] = g_html_json.setCheckBoxSet(gui_jnob, 
                                              "checksetexample", @["default"])

  innervarob["table01"] = g_html_json.setTableBasic(gui_jnob, "table_01")

  resp showPage(innervarob, outervarob)




proc postScricon*(request: Request) = 


  var
    statustekst, righttekst:string
    innervarob: Context = newContext()  # inner html insertions
    outervarob: Context = newContext()   # outer html insertions
    cookievaluest, locationst, mousvarnamest: string
    funcpartsta =  initOrderedTable[string, string]()


  # g_static_config.project_prefikst = project_prefikst
  # g_static_config.setGuiJsonNode()
  var gui_jnob = scricon_loadjson.getGuiJsonNode(project_prefikst)


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

  innervarob["dropdown1"] = g_html_json.setDropDown(gui_jnob, "dropdownname_01", 
                                                        @"dropdownname_01", 1)
  righttekst = "The value of dropdownname_01 = " & @"dropdownname_01"

  innervarob["dropdown2"] = g_html_json.setDropDown(gui_jnob, "dropdownname_02", 
                                              request.params["dropdownname_02"], 1)

  righttekst = righttekst & "<br>" & "The value of dropdownname_02 = " & @"dropdownname_02"

  innervarob["radiobuttonset1"] = g_html_json.setRadioButtons(gui_jnob, 
                              "radiosetexample", request.params["radiosetexample"])

  innervarob["dropdown3"] = g_html_json.setDropDown(gui_jnob, "dropdownname_03", 
                                                        @"dropdownname_03", 3)

  # righttekst = righttekst & "<br>" & "The selected radiobutton = " & 
  #                                   request.params["radiosetexample"]
  righttekst = righttekst & "<br>" & "The selected radiobutton = " & @"radiosetexample"


  innervarob["checkboxset1"] = g_html_json.setCheckBoxSet(gui_jnob, 
                              "checksetexample", @[@"check1", @"check2", @"check3"])

  righttekst = righttekst & "<br>" & "The boxes that are checked are: " & 
                                @"check1" & " " & @"check2" & " " & @"check3"

  innervarob["righttext"] = righttekst


  # A server-function may have been called from client-side (browser-javascript) by
  # preparing a cookie for the server (that is here) to pick up and execute.
  # (what i call a cookie-tunnel)
  if request.cookies.haskey(project_prefikst & "_run_function"):
    cookievaluest = request.cookies[project_prefikst & "_run_function"]
    if cookievaluest != "DISABLED":
      funcpartsta = g_tools.getFuncParts(cookievaluest) 
      locationst = funcpartsta["location"]  # innerhtml-page or outerhtml-page
      mousvarnamest = funcpartsta["mousvarname"]

      if locationst == "inner":
        innervarob[mousvarnamest] = g_tools.runFunctionFromClient(funcpartsta, gui_jnob)
      elif locationst == "outer":
        outervarob[mousvarnamest] = g_tools.runFunctionFromClient(funcpartsta, gui_jnob)



  resp showPage(innervarob, outervarob)



proc getRoot(request: Request) = 
  # retrieve the json-file

  resp "Type: localhost:" & $portnumberit & "/" & project_prefikst




proc sayHello(request: Request) = 
  resp "Hello world"



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
router.get("/scricon", getScricon)
router.post("/scricon", postScricon)



let server = newServer(router)
echo "Serving on http://localhost:5160"
server.serve(Port(5160))



