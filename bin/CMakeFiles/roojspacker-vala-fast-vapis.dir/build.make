# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.12

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/alan/gitlive/roojspacker

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/alan/gitlive/roojspacker

# Utility rule file for roojspacker-vala-fast-vapis.

# Include the progress variables for this target.
include bin/CMakeFiles/roojspacker-vala-fast-vapis.dir/progress.make

bin/CMakeFiles/roojspacker-vala-fast-vapis: bin/roojspacker-vala/fast-vapis.stamp


bin/roojspacker-vala/fast-vapis.stamp: bin/roojspacker-vala/build/bin/main.vapi.stamp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/alan/gitlive/roojspacker/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Generating fast VAPIs for roojspacker-vala"
	cd /home/alan/gitlive/roojspacker/bin && /usr/bin/cmake -E touch /home/alan/gitlive/roojspacker/bin/roojspacker-vala/fast-vapis.stamp

bin/roojspacker-vala/build/bin/main.vapi.stamp: bin/main.vala
bin/roojspacker-vala/build/bin/main.vapi.stamp: roojspacker/roojspacker-.vapi
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/alan/gitlive/roojspacker/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Generating fast VAPI /home/alan/gitlive/roojspacker/bin/roojspacker-vala/build/bin/main.vapi"
	cd /home/alan/gitlive/roojspacker/bin && /usr/bin/valac /home/alan/gitlive/roojspacker/bin/main.vala --fast-vapi /home/alan/gitlive/roojspacker/bin/roojspacker-vala/build/bin/main.vapi /home/alan/gitlive/roojspacker/roojspacker/roojspacker-.vapi --target-glib=2.38 -g --thread --vapidir=/home/alan/gitlive/roojspacker/vapi
	cd /home/alan/gitlive/roojspacker/bin && /usr/bin/cmake -E touch /home/alan/gitlive/roojspacker/bin/roojspacker-vala/build/bin/main.vapi.stamp

roojspacker-vala-fast-vapis: bin/CMakeFiles/roojspacker-vala-fast-vapis
roojspacker-vala-fast-vapis: bin/roojspacker-vala/fast-vapis.stamp
roojspacker-vala-fast-vapis: bin/roojspacker-vala/build/bin/main.vapi.stamp
roojspacker-vala-fast-vapis: bin/CMakeFiles/roojspacker-vala-fast-vapis.dir/build.make

.PHONY : roojspacker-vala-fast-vapis

# Rule to build all files generated by this target.
bin/CMakeFiles/roojspacker-vala-fast-vapis.dir/build: roojspacker-vala-fast-vapis

.PHONY : bin/CMakeFiles/roojspacker-vala-fast-vapis.dir/build

bin/CMakeFiles/roojspacker-vala-fast-vapis.dir/clean:
	cd /home/alan/gitlive/roojspacker/bin && $(CMAKE_COMMAND) -P CMakeFiles/roojspacker-vala-fast-vapis.dir/cmake_clean.cmake
.PHONY : bin/CMakeFiles/roojspacker-vala-fast-vapis.dir/clean

bin/CMakeFiles/roojspacker-vala-fast-vapis.dir/depend:
	cd /home/alan/gitlive/roojspacker && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/alan/gitlive/roojspacker /home/alan/gitlive/roojspacker/bin /home/alan/gitlive/roojspacker /home/alan/gitlive/roojspacker/bin /home/alan/gitlive/roojspacker/bin/CMakeFiles/roojspacker-vala-fast-vapis.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : bin/CMakeFiles/roojspacker-vala-fast-vapis.dir/depend

