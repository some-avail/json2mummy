#[ Extra procs for json to easily retrieve and  write data from/to file 
-getDeepNodeFromKey() - get the node from anywhere in the json-exp by recursing
-calcDoubleKeys() - build a sequence of keys with multiple occurences,
                    so that they can be avoided.
]#


import json, tables

var versionfl: float = 0.2


var filest: string
# filest = "testedit.json"
filest = "scricon_gui.json"
# filest = "test-scricon_gui.json"
var jnob = parseFile(filest)
var arrjnob = %*[{"naam":"knakkie", "leeftijd": 89}]
# var jnob = %*{"naam":"knakkie", "leeftijd": 89, "naam": "bizon"}
var tempjnob: JsonNode = %*{}



proc testIter01(jnob:JsonNode)=
  # for testing only

  # walk thru keys
  #   check the kind of their values
  #   if their kind is JObject
  #     print that value
  #     recurse for that object (if recurbo = true)
  var it = 0
  var indentst = ""

  if jnob.kind == JObject:
    for key in jnob.keys:
      echo key
      # echo jnob[key].kind

      if jnob[key].kind == JObject:
        it += 1
        indentst = indentst & "  "
        testIter01(jnob[key])
      else:
        # echo indentst, $jnob[key]
        discard


proc testDeepNodeFromKey(keyst:string, depthcountit: int = 0, 
                  jnob:JsonNode, foundjnob:var JsonNode) = 

  # deprecated; for testing

  # Get the node from anywhere in the json-exp by recursing 
  # the jnob and finding the key.
  # The foundjnob must externally be existing and initilized,
  # and will be overwritten. If the key is not found nothing will 
  # be overwritten. If multiple are found the latest will 
  # written.

  var 
    tbo = false
    keycountit: int = 0
    depthit: int = depthcountit

  if tbo: echo "================================="
  if jnob.kind == JObject:
    # walk thru the keys
    for key in jnob.keys:
      keycountit += 1
      if tbo: echo keycountit
      if tbo: echo key
      if tbo: echo jnob[key].kind

      if key == keyst:
        foundjnob = jnob[key]

      if jnob[key].kind == JObject:
        depthit += 1
        if tbo: echo "depthit = ", $depthit
        testDeepNodeFromKey(keyst, depthit, jnob[key], foundjnob)
  else:
    echo "Original JsonNode is no JObject, but a ", $jnob.kind


proc getDeepNodeFromKey*(keyst:string, jnob:JsonNode, parfoundjnob:var JsonNode) = 

  # Get the node from anywhere in the json-exp of original 
  # json-node-object jnob by recursing the jnob and finding the key.
  # The original jnob must be of type / kind: JObject.
  # The parfoundjnob must externally be existing and initilized,
  # and will be overwritten. If the key is not found nothing will 
  # be overwritten. If multiple keys are found the latest will 
  # written.

  var 
    tbo = false
    keycountit: int = 0

  if tbo: echo "================================="
  if jnob.kind == JObject:
    # walk thru the keys
    for key in jnob.keys:
      keycountit += 1
      if tbo: echo keycountit
      if tbo: echo key
      if tbo: echo jnob[key].kind

      if key == keyst:
        parfoundjnob = jnob[key]

      if jnob[key].kind == JObject:
        getDeepNodeFromKey(keyst, jnob[key], parfoundjnob)
  else:
    echo "Error: original JsonNode is no JObject, but a ", $jnob.kind



proc listKeysFromNode(jnob:JsonNode, allkeyssq: var seq[string]) =

  # -walk thru all keys from a jnob, and put them in allkeyssq
  # -an empty seq must be pre-initalized externally and given as param.


  # walk thru keys
  #   check the kind of their values
  #   if their kind is JObject
  #     recurse for that object (if recurbo = true)

  if jnob.kind == JObject:
    for key in jnob.keys:
      # echo key
      # echo jnob[key].kind
      allkeyssq.add(key)
      if jnob[key].kind == JObject:
        listKeysFromNode(jnob[key], allkeyssq)



proc findDoubleKeys(keylistsq: seq[string]): seq[string] =

  # -find the non-unique keys in a keylist and return them as 
  # a (sub)sequence

  var countta = toCountTable(keylistsq)

  result = @[]
  for keyst,valit in countta.pairs:
    if valit > 1:
      result.add(keyst)
  




when isMainModule:

  # echo tempjnob
  # getDeepNodeFromKey("web-elements fp", jnob, tempjnob)
  # echo tempjnob.kind
  # echo tempjnob

  # =============================================
  # var keylistsq: seq[string] = @[]
  # listKeysFromNode(jnob, keylistsq)
  # echo keylistsq
  # echo findDoubleKeys(keylistsq)
  # ==========================================
  echo "----------------------------"
  echo jnob

  testIter01(jnob)


