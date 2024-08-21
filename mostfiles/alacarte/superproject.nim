
#[
In this module it is showcased to create a super-project based on allready existing, siblingal projects, that can keep on functioning independently. However, selectable sibling-projects must be adapted for use in other projects. Currently only controls_mummy has been adapted and is showcased here. Look there for the needed adapts.

The superproject must be parallel (or siblingal) to the projects to select from ("alacarte")
For now only controls_mummy has been parentized.
]#



import mummy, mummy/routers, mummy_utils, moustachu
import times, json, os


import ../controls_mummy/controls_startup

from ../controls_mummy/g_static_config import nil
from ../controls_mummy/g_html_json import nil




# you can add your superproject-html here to create a subproject-selection-menu




var router: Router
const portit = 5300


# you can add the superproject-routes here:



#from controls
router.get("/public/controls.css", cssControls)
router.get("/", getRoot)
router.get("/controls", getControls)
router.post("/controls", postControls)


let server = newServer(router)
echo "Serving on http://localhost:" & $portit
server.serve(Port(portit))

