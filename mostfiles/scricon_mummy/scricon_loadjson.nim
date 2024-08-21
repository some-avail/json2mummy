
#[ Module-function: 
  Read the json-file, convert it to a jnob,
  load additional public data to the jnob, and 
  expose it as function.

  Public in this context means unchangable data
  relevant to all users.
  User-data must be loaded from the routes-location
  in project_startup.nim to avoid shared data.
 ]#



import json

var versionfl: float = 0.2



proc dummyLoad(parjnob: JsonNode): JsonNode = 
  # custom - load extra public data to the json-object
  result = parjnob


proc getGuiJsonNode*(proj_prefikst: string): JsonNode = 
  var 
    filest: string
    jnob, secondjnob: JsonNode

  filest = proj_prefikst & "_gui.json"
  jnob = parseFile(filest)
  secondjnob = dummyLoad(jnob)

  result = secondjnob


