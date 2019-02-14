project("roojspacker" C)

cmake_minimum_required(VERSION 3.2)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

include(FindVala)
include(AddCompilerFlags)

find_package(GLib "2.38" REQUIRED) 
find_package(Vala "0.36.0" MINIMUM)

   

find_package(PkgConfig)
pkg_check_modules(GOBJECT REQUIRED gobject-2.0)
pkg_check_modules(GIO REQUIRED gio-2.0)
pkg_check_modules(GEE REQUIRED gee-0.8)
pkg_check_modules(GTHREAD REQUIRED gthread-2.0)
# this was optional??
pkg_check_modules(JSON REQUIRED json-glib-1.0)


set(CFLAGS
	${GOBJECT_CFLAGS} ${GOBJECT_CFLAGS_OTHER}
	${GIO_CFLAGS} ${GIO_CFLAGS_OTHER}
 	${GTHREAD_CFLAGS} ${GTHREAD_CFLAGS_OTHER}
        ${GEE_CFLAGS} ${GEE_CFLAGS_OTHER}
        ${JSON_CFLAGS} ${JSON_CFLAGS_OTHER}
)
add_definitions(${CFLAGS})



if(CMAKE_BUILD_TYPE STREQUAL "")
  set(CMAKE_BUILD_TYPE "Debug")
endif(CMAKE_BUILD_TYPE STREQUAL "")

list(APPEND VALA_COMPILER_FLAGS "--target-glib=2.38")
list(APPEND VALA_COMPILER_FLAGs_DEBUG "--debug")


global_add_compiler_flags(-Wno-incompatible-pointer-types)


set(LIBS
	${GOBJECT_LIBRARIES}
	${GIO_LIBRARIES}
	${GEE_LIBRARIES}
	${GTHREAD_LIBRARIES}
        ${JSON_LIBRARIES}
)
link_libraries(${LIBS})


set(LIB_PATHS
	${GOBJECT_LIBRARY_DIRS}
	${GIO_LIBRARY_DIRS}
	${GEE_LIBRARY_DIRS}
	${GTHREAD_LIBRARY_DIRS}
        ${JSON_LIBRARY_DIRS}
)
link_directories(${LIB_PATHS})

set (LIBRARY_PATH "src")

  
add_subdirectory(src)
add_subdirectory(main)