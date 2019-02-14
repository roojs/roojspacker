project("roojspacker" C)

cmake_minimum_required(VERSION 2.6)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)

include(FindVala)

find_package(Vala REQUIRED)
ensure_vala_version("0.36.0" MINIMUM)

find_package(PkgConfig)
pkg_check_modules(GTK REQUIRED gtk+-2.0)
add_definitions(${GTK_CFLAGS} ${GTK_CFLAGS_OTHER})
link_libraries(${GTK_LIBRARIES})
link_directories(${GTK_LIBRARY_DIRS})

  
add_subdirectory(src)
add_subdirectory(main)