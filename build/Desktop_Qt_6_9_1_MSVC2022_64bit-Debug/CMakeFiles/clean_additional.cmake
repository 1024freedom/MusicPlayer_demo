# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appMusicPlayer_demo_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appMusicPlayer_demo_autogen.dir\\ParseCache.txt"
  "appMusicPlayer_demo_autogen"
  )
endif()
