find_package(PkgConfig)
pkg_check_modules(GOBJECT REQUIRED gobject-2.0)
pkg_check_modules(GIO REQUIRED gio-2.0)
pkg_check_modules(GEE REQUIRED gee-0.8)
pkg_check_modules(GTHREAD REQUIRED gthread-2.0)


set(CFLAGS
	${GOBJECT_CFLAGS} ${GOBJECT_CFLAGS_OTHER}
	${GIO_CFLAGS} ${GIO_CFLAGS_OTHER}
	${GTK_CFLAGS} ${GTK_CFLAGS_OTHER}
	${GTHREAD_CFLAGS} ${GTHREAD_CFLAGS_OTHER}
)
add_definitions(${CFLAGS})


set(LIBS
	${GOBJECT_LIBRARIES}
	${GIO_LIBRARIES}
	${GTK_LIBRARIES}
	${GTHREAD_LIBRARIES}
)
link_libraries(${LIBS})


set(LIB_PATHS
	${GOBJECT_LIBRARY_DIRS}
	${GIO_LIBRARY_DIRS}
	${POPPLER_LIBRARY_DIRS}
	${GTK_LIBRARY_DIRS}
	${GTHREAD_LIBRARY_DIRS}
)
link_directories(${LIB_PATHS})

set(VALA_SRC
  ...
  
)

# Vala segfaults if its output dirs are not existant. Therefore make sure they
# are there.
macro(make_compile_directory directory)
	if (NOT IS_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${directory}")
		make_directory("${CMAKE_CURRENT_BINARY_DIR}/${directory}")
	endif (NOT IS_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${directory}")
endmacro(make_compile_directory)

vala_precompile(VALA_C
	${VALA_SRC}
PACKAGES 
	gio-2.0
	poppler-glib
	gtk+-2.0
	posix
OPTIONS 
	--thread
	--debug
GENERATE_HEADER
	roojspacker
GENERATE_VAPI
	roojspacker
)

add_executable(roojspacker
  	${VALA_C}
)

# explicitly add libraries (needed e.g. for Fedora 13+)
target_link_libraries(roojspacker -lm)

install(TARGETS 
	roojspacker
RUNTIME
DESTINATION
	bin
)

add_library(roojspacker_library 
	SHARED
	EXCLUDE_FROM_ALL
	${VALA_C} roojspacker.h roojspacker.vapi
)