# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appQT_QUICK_LEARNING_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appQT_QUICK_LEARNING_autogen.dir\\ParseCache.txt"
  "appQT_QUICK_LEARNING_autogen"
  )
endif()
