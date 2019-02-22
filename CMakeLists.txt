project("roojspacker" C)

cmake_minimum_required(VERSION 3.2)


set(PROJECT_WEB "https://www.roojs.com/")
# Where to report bugs; usually either an e-mail address or an issue
# tracker URL.
set(PROJECT_BUGS "https://www.roojs.com/mtrack/")
# Gettext package name
#set(GETTEXT_PACKAGE ${PROJECT_NAME})

# Library version
#
# This should be incremented with every release.  See semver.org.
set (ROOJSPACKER_VERSION_MAJOR    1)
set (ROOJSPACKER_VERSION_MINOR    2)
set (ROOJSPACKER_VERSION_REVISION 0)

# API version.
#
# This will go in the pkg-config and shared library names.  Should
# only be changed if the API breaks backwards compatibility.
set (ROOJSPACKER_VERSION_API      "1.2")
set (ROOJSPACKER_SOVERSION_CURRENT  ${ROOJSPACKER_VERSION_MAJOR})
set (ROOJSPACKER_SOVERSION_REVISION ${ROOJSPACKER_VERSION_MINOR})
set (ROOJSPACKER_SOVERSION_AGE      ${ROOJSPACKER_VERSION_REVISION})



list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

 
find_package(GLib "2.38" REQUIRED) 
find_package(Vala "0.36.0" REQUIRED)

   

find_package(PkgConfig)
pkg_check_modules(GOBJECT REQUIRED gobject-2.0)
pkg_check_modules(GIO REQUIRED gio-2.0)
pkg_check_modules(GEE REQUIRED gee-0.8)
pkg_check_modules(GTHREAD REQUIRED gthread-2.0)
# this was optional??
pkg_check_modules(JSON REQUIRED json-glib-1.0)


set(ROOJSPACKER_VALA_PACKAGES
    glib-2.0  
    gobject-2.0  
    gee-0.8 
    posix 
    gio-2.0
    json-glib-1.0
)

set(HAVE_JSON_GLIB, "yes")

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

list(APPEND VALA_COMPILER_FLAGS
        "--target-glib=2.38"
        "-g"
        "--thread"
        "--vapidir=${CMAKE_SOURCE_DIR}/vapi"
)
list(APPEND VALA_COMPILER_FLAGs_DEBUG "--debug")
#        "-X -shared"
#"-X -lm"



include(AddCompilerFlags)

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
set(ROOJSPACKER_LIBRARY_NAME ${PROJECT_NAME}-${ROOJSPACKER_VERSION_API})
set(ROOJSPACKER_PKG_NAME ${PROJECT_NAME}-${ROOJSPACKER_VERSION_API})

# Name of the GObject Introspection repository for the library.
set(ROOJSPACKER_GIR_NAME "MyProject-${ROOJSPACKER_VERSION_API}")

set (LIBRARY_PATH "roojspacker")
  
add_subdirectory(roojspacker)
add_subdirectory(bin)