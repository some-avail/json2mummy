import std/[random]

#[ Not yet used ]#

randomize()


proc genTabId*(): string = 
  # 9 zeros is maximal int size, otherwise use int64
  let idst = $rand(1000000000)
  result = idst




when isMainModule:
  echo genTabId()

