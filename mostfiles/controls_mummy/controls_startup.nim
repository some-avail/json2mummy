

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


-to mummify a jester-project
  - import needed mummy modules (3) and remove jester
  - move the route-parts to separate procs like 
    - getProject(request: Request)
    - postProject(request: Request)
  - remove the routes-macro
  - update the paths in project_outer.html (prefix "/public/")
  - add the cssHandler and the scriptHandler to enable the loading of respective files
  - add the mummy-routes
  - in mummy you set persistence to persistOnDisk because in mummy you must compile for with multi-threading
  - make sure no addons (like ublock) limit your view 


- to enable call by a sibling project (see the alacarte/superproject.nim) you must do some non-trivial adaptations to the code:
  - parentization of paths applied 
    - add prefixes like: ../subproject
    - for all project-modules
  - add: when isMainModule
  - create constants for project and sibling-prefix
  - publicize constants and procs with a *


ADAP HIS
-change static_config and calls
-enable siblingal call (see above)

ADAP NOW


]#


#import jester, moustachu, times, json, os
import mummy, mummy/routers, mummy_utils, moustachu
import times, json, os


from ../controls_mummy/g_static_config import nil
from ../controls_mummy/g_html_json import nil


const 
  versionfl*:float = 0.2
  appnamebriefst*:string = "CT"
  appnamenormalst* = "Controls"
  appnamesuffikst* = "Controls-showcase"
  project_prefikst* = "controls"


#settings:
#  port = Port(5160)


# the siblingprefix enables calling from a sibling-project-location (sibling-directory)
const projectdirst* = "controls_mummy"
const siblingprefikst* = "../" & projectdirst & "/"



proc showPage*(par_innervarob, par_outervarob: var Context, 
              custominnerhtmlst:string=""): string = 

  var innerhtmlst:string
  if custominnerhtmlst == "":
    innerhtmlst = render(readFile(siblingprefikst & "controls_inner.html") , par_innervarob)    
  else:
    innerhtmlst = custominnerhtmlst
  par_outervarob["controls-group"] = innerhtmlst

  return render(readFile(siblingprefikst & "controls_outer.html") , par_outervarob)





proc getRoot*(request: Request) = 
  # retrieve the json-file

  resp "Type: localhost:5160/controls"


proc sayHello*(request: Request) = 

  resp "Hello world"



proc getControls*(request: Request) =

  var
    statustekst:string
    innervarob: Context = newContext()  # inner html insertions
    outervarob: Context = newContext()   # outer html insertions
  innervarob["statustext"] = """Basic webserver with some controls generated from 
  a gui-definition-file in json-format. 
  The webserver-interface without cliental javascript has only one button:
  submit your request to the server. Switches (like below) indicate what you want to do."""

  var gui_jnob = g_static_config.getGuiJsonNode(project_prefikst)

  innervarob["newtab"] = "_self"
  outervarob["version"] = $versionfl
  outervarob["loadtime"] ="Page-load: " & $now()
  outervarob["pagetitle"] = appnamenormalst
  outervarob["namesuffix"] = appnamesuffikst
  innervarob["dropdown1"] = g_html_json.setDropDown(gui_jnob, "dropdownname_01", "", 1)
  innervarob["dropdown2"] = g_html_json.setDropDown(gui_jnob, "dropdownname_02", "", 1)
  innervarob["radiobuttonset1"] = g_html_json.setRadioButtons(gui_jnob, 
                                          "radio-set-example", "")
  innervarob["checkboxset1"] = g_html_json.setCheckBoxSet(gui_jnob, 
                                              "check-set-example", @["default"])

  resp showPage(innervarob, outervarob)



proc postControls*(request: Request) =

  var
    statustekst, righttekst:string
    innervarob: Context = newContext()  # inner html insertions
    outervarob: Context = newContext()   # outer html insertions

  # g_static_config.project_prefikst = project_prefikst
  # g_static_config.setGuiJsonNode()
  var gui_jnob = g_static_config.getGuiJsonNode(project_prefikst)


  innervarob["newtab"] = "_self"
  outervarob["version"] = $versionfl
  outervarob["loadtime"] ="Page-load: " & $now()
  outervarob["pagetitle"] = appnamenormalst
  outervarob["namesuffix"] = appnamesuffikst

  innervarob["linkcolor"] = "red"

  innervarob["dropdown1"] = g_html_json.setDropDown(gui_jnob, "dropdownname_01", 
                                                        @"dropdownname_01", 1)
  righttekst = "The value of dropdownname_01 = " & @"dropdownname_01"

  innervarob["dropdown2"] = g_html_json.setDropDown(gui_jnob, "dropdownname_02", 
                                              request.params["dropdownname_02"], 1)

  righttekst = righttekst & "<br>" & "The value of dropdownname_02 = " & @"dropdownname_02"

  innervarob["radiobuttonset1"] = g_html_json.setRadioButtons(gui_jnob, 
                              "radio-set-example", request.params["radio-set-example"])

  # righttekst = righttekst & "<br>" & "The selected radiobutton = " & 
  #                                   request.params["radio-set-example"]
  righttekst = righttekst & "<br>" & "The selected radiobutton = " & @"radio-set-example"


  innervarob["checkboxset1"] = g_html_json.setCheckBoxSet(gui_jnob, 
                              "check-set-example", @[@"check1", @"check2", @"check3"])

  righttekst = righttekst & "<br>" & "The boxes that are checked are: " & 
                                @"check1" & " " & @"check2" & " " & @"check3"

  innervarob["righttext"] = righttekst

  resp showPage(innervarob, outervarob)




proc cssControls*(request: Request) =
  var headers: HttpHeaders
  headers["Content-Type"] = "text/css"
  #request.respond(200, headers, readFile("public/controls.css"))
  request.respond(200, headers, readFile(siblingprefikst & "public/controls.css"))



when isMainModule:

  var router: Router

  # no sibling-prefix here because this concerns the webaddresses which have no parent
  router.get("/public/controls.css", cssControls)
  router.get("/", getRoot)
  router.get("/hello", sayHello)
  router.get("/controls", getControls)
  router.post("/controls", postControls)


  let server = newServer(router)
  echo "Serving on http://localhost:5160"
  server.serve(Port(5160))



