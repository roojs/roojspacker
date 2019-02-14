#
#
# Main target

# Compile Vala sources to C
vala_precompile_target(
  "roojspacker-vala"
  ROOJSPACKER_MAIN_SOURCES
  ${CMAKE_BINARY_DIR}/src/roojspacker-1.2.vapi
  main.vala
DEPENDS
        "${MY_PROJECT_LIBRARY_NAME}-vala"
)

# Tell CMake to create an executable named "my-project"
add_executable(roojspacker
	${ROOJSPACKER_MAIN_SOURCES})

# Make sure the Vala sources are compiled to C before attempting to
# build the executable.
add_dependencies("roojspacker" "roojspacker-vala")

# We need to add the directory where the C header for our library is
# installed, otherwise we'll get an error from the C compiler.
set_target_properties(roojspacker PROPERTIES
	INCLUDE_DIRECTORIES ${CMAKE_BINARY_DIR}/src)

# Any libraries that your tests need to link to should go here.
# Usually this will just be your library.
target_link_libraries(${PROJECT_NAME}
    roojspacker-1.2)

# Install the executable.
install (TARGETS roojspacker
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

 