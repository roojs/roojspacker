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

set(VALA_SRC
    jsdoc/Collapse.vala 
    jsdoc/CompressWhite.vala 
    jsdoc/Identifier.vala 
    jsdoc/Lang.vala 
    jsdoc/Packer.vala 
    jsdoc/ScopeParser.vala 
    jsdoc/Scope.vala 
    jsdoc/TextStream.vala 
    jsdoc/TokenReader.vala 
    jsdoc/TokenStream.vala 
    jsdoc/Token.vala 
    jsdoc/PackerRun.vala 
    jsdoc/Walker.vala 
    jsdoc/SymbolSet.vala 
    jsdoc/DocBuilder.vala 
    jsdoc/DocComment.vala 
    jsdoc/DocParser.vala 
    jsdoc/DocTag.vala 
    jsdoc/PrettyPrint.vala 
    jsdoc/Symbol.vala
)

 

# Vala segfaults if its output dirs are not existant. Therefore make sure they
# are there.
macro(make_compile_directory directory)
	if (NOT IS_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${directory}")
		make_directory("${CMAKE_CURRENT_BINARY_DIR}/${directory}")
	endif (NOT IS_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${directory}")
endmacro(make_compile_directory)

## ----------- the library

vala_precompile(VALA_C
	${VALA_SRC}
PACKAGES 
	gio-2.0
	gee-0.8
        glib-2.0
        gobject-2.0
        json-glib-1.0
OPTIONS 
	--thread
	--debug
        --vapidir=${CMAKE_SOURCE_DIR}/vapi
        -g
        -X -shared -X -lm
        --target-glib=2.32
GENERATE_HEADER
	roojspacker-1.2.h
GENERATE_VAPI
	roojspacker-1.2
)

add_library(libroojspacker-1.2 
	SHARED
	EXCLUDE_FROM_ALL
	${VALA_C} roojspacker.h
)
 
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/roojspacker-1.2.vapi
    DESTINATION ${CMAKE_INSTALL_DATADIR}/vala/vapi)
    
install (TARGETS libroojspacker-1.2
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}  # On Windows, the DLL goes in the same place as the executables
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}  # This is where shared libraries (*.so on Linux, *.dynlib on OS X)
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}) # Finally, this is where static libraries (*.a) go
    
## ----------- the binary

vala_precompile(VALABIN_C
	main.vala
PACKAGES 
	gio-2.0
	gee-0.8
        glib-2.0
        gobject-2.0
        json-glib-1.0
        roojspacker-1.2
OPTIONS 
	--thread
	--debug
        --vapidir=${CMAKE_SOURCE_DIR}/vapi
        --vapidir=${CMAKE_SOURCE_DIR}
        -g
        -X -shared -X -lm
        --target-glib=2.32
)



add_executable(roojspacker
  	${VALABIN_C}
)

# explicitly add libraries (needed e.g. for Fedora 13+)
# target_link_libraries(roojspacker -lm)

install(TARGETS 
	roojspacker
RUNTIME
DESTINATION
	bin
)


