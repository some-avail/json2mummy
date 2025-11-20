#[
	Since multithreaded nim does not like globals,
	here I will give methodical ways to write to / read off disk,
  for certain vars
]#


import std/[tables]
import g_templates


#var
#  datasqta = initTable[string, seq[array[5, string]]]()
#  globwordsqta = initTable[string, seq[string]]()


proc writeToDisk(varnameta: Table[string; seq[string]; separ: array[2, string], filepathst: string) = 
	
  var linest: string
	# write the var to disk
	withFileAdvanced(fob, filepathst, fmWrite):
		for keyst, valsq in varnameta:
      linest = keyst & separ[0]
      for it, itemst in valsq:
        if it < valsq.len - 1:
          linest & = itemst & separ[1]
        elif it == valsq.len - 1:
          linest &= itemst

    fob.writeLine(linest)


when isMainModule:
  var sqta = initTable[string, seq[string]]()
  writeToDisk(sqta, ["~~~", "___"])

