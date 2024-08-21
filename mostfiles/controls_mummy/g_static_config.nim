
#[ Precompilational config. (g_static_config.nim)

  
  3 config-files can be used in nimwebbie-projects:
  -precompilational configuration: static_config.nim
  -on-start-configuration: project_onstart_config.json of .conf ?
  -post-start-configuration: project_dynamic_config.json of .conf ?

  This module is currently used as generic module, that is not 
  project-specific. The other two configs are project-specific (future).
  ]#



import json

var versionfl: float = 0.2


proc getGuiJsonNode*(proj_prefikst: string): JsonNode = 
  var filest = "../controls_mummy/" & proj_prefikst & "_gui.json"
  result = parseFile(filest)
