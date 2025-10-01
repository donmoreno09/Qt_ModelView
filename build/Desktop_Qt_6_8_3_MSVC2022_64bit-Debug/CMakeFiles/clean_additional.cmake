# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\ContactApp_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\ContactApp_autogen.dir\\ParseCache.txt"
  "ContactApp_autogen"
  )
endif()
