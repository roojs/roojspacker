
set(VALA_SRC
    Collapse.vala 
    CompressWhite.vala 
    Identifier.vala 
    Lang.vala 
    Packer.vala 
    ScopeParser.vala 
    Scope.vala 
    TextStream.vala 
    TokenReader.vala 
    TokenStream.vala 
    Token.vala 
    PackerRun.vala 
    Walker.vala 
    SymbolSet.vala 
    DocBuilder.vala 
    DocComment.vala 
    DocParser.vala 
    DocTag.vala 
    PrettyPrint.vala 
    Symbol.vala
)

 

# Vala segfaults if its output dirs are not existant. Therefore make sure they
# are there.
macro(make_compile_directory directory)
	if (NOT IS_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${directory}")
		make_directory("${CMAKE_CURRENT_BINARY_DIR}/${directory}")
	endif (NOT IS_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${directory}")
endmacro(make_compile_directory)

## ----------- the library

vala_precompile_target(
        "libroojspacker-vala"
	VALA_C
PACKAGES 
	gio-2.0
	gee-0.8
        glib-2.0
        gobject-2.0
        json-glib-1.0
HEADER roojspacker-1.2.h
VAPI roojspacker-1.2
    ${VALA_SRC}
)

add_library(libroojspacker 
	SHARED
	${VALA_C} roojspacker.h
)

add_dependencies("libroojspacker" "libroojspacker-vala")

# Set the library's version information
set_target_properties (${MY_PROJECT_LIBRARY_NAME} PROPERTIES
    SOVERSION "1.2.1000"
    VERSION   "1.2")


# Install our VAPI
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/roojspacker.vapi
    DESTINATION ${CMAKE_INSTALL_DATADIR}/vala/vapi)
    
install (TARGETS "libroojspacker"
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}  # On Windows, the DLL goes in the same place as the executables
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}  # This is where shared libraries (*.so on Linux, *.dynlib on OS X)
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}) # Finally, this is where static libraries (*.a) go

# Install the C header
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/roojspacker-1.2.h
    DESTINATION ${CMAKE_INSTALL_FULL_INCLUDEDIR})


# pkg-config file..    
configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/../roojspacker-1.2.pc.in"
    "${CMAKE_CURRENT_BINARY_DIR}/roojspacker-1.2.pc"
    @ONLY)
    
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/roojspacker-1.2.pc
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)
     
