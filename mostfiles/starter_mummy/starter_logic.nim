import std/[random]

#[ Not yet used ]#

randomize()


proc genTabId*(): string = 
  # 9 zeros is maximal int size, otherwise use int64
  let idst = $rand(1000000000)
  result = idst



proc reverseString*(inputst: string): string =
  # reverse the order of the string
  var outputst: string
  for it in 0..(inputst.len - 1):
    outputst = inputst[it..it] & outputst
  result = outputst





proc cycleSequence*(listsq: seq[string], currentitemst: string): string = 

  #[
    - return the next item in the sequence listsq, starting from currentitemst
    - at the last item return to the first one
  ]#


  result = listsq[0]
  for it, itemst in listsq:
    #echo $it
    if itemst == currentitemst:
      if it < listsq.len - 1:
        result = listsq[it + 1]
      else:
        result = listsq[0]




when isMainModule:
  #echo genTabId()

  #echo reverseString("opa")

  echo cycleSequence(@["aap","noot","mies"], "aap")


