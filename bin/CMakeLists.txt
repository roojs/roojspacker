#
#
# Main target

# Compile Vala sources to C


vala_precompile(ROOJSPACKER_MAIN_SOURCES
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
        --vapidir=${CMAKE_SOURCE_DIR}/src
        -g
        -X -shared -X -lm
        --target-glib=2.32

)
# Tell CMake to create an executable named "my-project"
add_executable(roojspacker
	${ROOJSPACKER_MAIN_SOURCES})

 
# We need to add the directory where the C header for our library is
# installed, otherwise we'll get an error from the C compiler.
set_target_properties(roojspacker PROPERTIES
	INCLUDE_DIRECTORIES ${CMAKE_BINARY_DIR}/src)

# Any libraries that your tests need to link to should go here.
# Usually this will just be your library.
target_link_libraries(roojspacker roojspacker-1.2)

# Install the executable.
install (TARGETS roojspacker
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

 