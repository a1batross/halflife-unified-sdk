cmake_minimum_required(VERSION 3.23)

if (MSVC)
	set(CMAKE_SYSTEM_VERSION 10.0)
endif()

set(VCPKG_OVERLAY_TRIPLETS ${CMAKE_SOURCE_DIR}/vcpkg_config/triplets)

project(HalfLifeMod
	VERSION 1.0.0
	DESCRIPTION "Half-Life CMake Mod Template"
	LANGUAGES CXX)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Disable the use of absolute paths in library paths even in development builds.
set(CMAKE_SKIP_BUILD_RPATH ON)

# Link statically with the runtime
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

# Because we have 2 libraries that use the same symbols we have to default visibility to hidden so there are no collisions,
# and so the symbols don't merge and cause problems like server code calling the client version of a function.
set(CMAKE_CXX_VISIBILITY_PRESET hidden)

# Get the Half-Life directory and mod name from the install path
cmake_path(HAS_PARENT_PATH CMAKE_INSTALL_PREFIX HAS_HALFLIFE_DIRECTORY)
cmake_path(HAS_STEM CMAKE_INSTALL_PREFIX HAS_MOD_NAME)

if (NOT HAS_HALFLIFE_DIRECTORY OR NOT HAS_MOD_NAME)
	message(FATAL_ERROR "The install path must point to a mod directory")
endif()

cmake_path(GET CMAKE_INSTALL_PREFIX PARENT_PATH HALFLIFE_DIRECTORY)
cmake_path(GET CMAKE_INSTALL_PREFIX STEM MOD_NAME)

# All Half-Life specific commands are prefixed with HalfLife so they show up in the same group in the CMake GUI
set(HalfLife_HLDS_DIRECTORY "" CACHE PATH "Path to the Half-Life Dedicated Server directory. Must be specified to automatically set up dedicated server debugging settings and to copy libraries")

# Default to Pre-Alpha. The documentation explains how to use this, so check that first!
set(RELEASE_TYPE "Pre-Alpha" "Alpha" "Beta" "Release")
set(HalfLife_RELEASE_TYPE "Pre-Alpha" CACHE STRING "What type of release you're building")
set_property(CACHE HalfLife_RELEASE_TYPE PROPERTY STRINGS ${RELEASE_TYPE})

list(FIND RELEASE_TYPE "${HalfLife_RELEASE_TYPE}" RELEASE_TYPE_INDEX)
if(RELEASE_TYPE_INDEX EQUAL -1)
	message(FATAL_ERROR "HalfLife_RELEASE_TYPE must be one of: ${RELEASE_TYPE}")
endif()

# Find dependencies
find_package(Threads REQUIRED)
find_package(Git REQUIRED)

find_package(spdlog CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
find_package(Angelscript CONFIG REQUIRED)
find_package(OpenAL CONFIG REQUIRED)

option(BUILD_EXAMPLES "" OFF)
option(BUILD_TESTS "" OFF)
add_subdirectory(external/json-schema-validator
	json-validator-binary-dir
	EXCLUDE_FROM_ALL)

option(LIBNYQUIST_BUILD_EXAMPLE "" OFF)
add_subdirectory(external/libnyquist
	libnyquist-binary-dir
	EXCLUDE_FROM_ALL)


function(set_dependency_common_properties TARGET_NAME)
	target_compile_features(${TARGET_NAME} PRIVATE cxx_std_20)
	
	# Enable multithreaded building to speed up building these a bit.
	target_compile_options(${TARGET_NAME} PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/MP>)

	# Silence warnings coming from this library.
	target_compile_options(${TARGET_NAME} PRIVATE $<$<CXX_COMPILER_ID:Clang,AppleClang,GNU>:-w>)
	
	set_target_properties(${TARGET_NAME} PROPERTIES FOLDER "Dependencies")
endfunction()

set_dependency_common_properties(nlohmann_json_schema_validator)
set_dependency_common_properties(libnyquist)

# Generate DebugInfo.h with appropriate information.

# Get the current working branch
execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE UNIFIED_SDK_GIT_BRANCH
    OUTPUT_STRIP_TRAILING_WHITESPACE)

# CI builds don't fetch tags so this should have a sensible value.
if ($ENV{CI})
	set(UNIFIED_SDK_GIT_TAG "CI build")
else()
	# Get the latest tag name
	execute_process(
		COMMAND ${GIT_EXECUTABLE} describe --abbrev=0 --tags
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
		OUTPUT_VARIABLE UNIFIED_SDK_GIT_TAG
		OUTPUT_STRIP_TRAILING_WHITESPACE
		ERROR_QUIET)
		
	# This can happen if there are no tags in the repository, so provide a suitable fallback.
	if (UNIFIED_SDK_GIT_TAG STREQUAL "")
		set(UNIFIED_SDK_GIT_TAG "None (No tags found)")
	endif()
endif()

# Get the latest commit hash
execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE UNIFIED_SDK_GIT_COMMIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(
    COMMAND ${GIT_EXECUTABLE} status --porcelain=v1
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE UNIFIED_SDK_GIT_STATUS_RESULT
    OUTPUT_STRIP_TRAILING_WHITESPACE)

# If not performing a CI build, mark commit as dirty if there are uncommitted changes.
if (NOT "$ENV{CI}" AND NOT UNIFIED_SDK_GIT_STATUS_RESULT STREQUAL "")
	set(UNIFIED_SDK_GIT_COMMIT_HASH "${UNIFIED_SDK_GIT_COMMIT_HASH}-dirty")
endif()

configure_file(src/game/shared/ProjectInfo.h.in ${CMAKE_BINARY_DIR}/ProjectInfo.h @ONLY)

# Sets properties common to all projects
function(set_common_properties TARGET_NAME)
	set_target_properties(${TARGET_NAME} PROPERTIES PREFIX "")
	
	# Enable use of Clang-Tidy in code analysis. See [repo_root]/.clang-tidy for the checks used in the project.
	set_target_properties(${TARGET_NAME} PROPERTIES VS_GLOBAL_EnableClangTidyCodeAnalysis true)
	
	target_compile_features(${TARGET_NAME} PRIVATE cxx_std_20)
		
	target_compile_definitions(${TARGET_NAME} PRIVATE
		_CRT_SECURE_NO_WARNINGS
		$<$<CONFIG:DEBUG>:_DEBUG>
		CLIENT_WEAPONS
		# These are defined for OSX as well
		$<$<PLATFORM_ID:Linux, Darwin>:
			POSIX
			_POSIX
			LINUX
			_LINUX
			GNUC
		>
		$<$<PLATFORM_ID:Darwin>:
			OSX
			_OSX
		>
		UNIFIED_SDK_CONFIG="$<CONFIG>")
		
	target_link_libraries(${TARGET_NAME} PRIVATE
		Angelscript::angelscript
		spdlog::spdlog
		Threads::Threads
		${CMAKE_DL_LIBS}
		nlohmann_json
		nlohmann_json_schema_validator)
	
	target_include_directories(${TARGET_NAME} PRIVATE
		${CMAKE_BINARY_DIR})

	# TODO: review Linux compiler flags
	target_compile_options(${TARGET_NAME} PRIVATE
		# force 387 for FP math so the precision between win32 and linux and osx match
		# Note: the pentium-m arch setting is not used for AMD systems in the original makefile
		# Since the arch settings used are i686 this means including the setting ensures original settings are used,
		# but it could cause problems for AMD targets
		$<$<CXX_COMPILER_ID:Clang,AppleClang,GNU>:-fpermissive -fno-strict-aliasing -Wno-invalid-offsetof -march=pentium-m -mfpmath=387>
			
		$<$<CXX_COMPILER_ID:MSVC>:/W3 /MP>
			
		# These are all from the original Makefile
		# They have not been tested with CMake since there is no Mac system available to test on, so this might not work
		$<$<PLATFORM_ID:Darwin>:-Qunused-arguments -mmacosx-version-min=10.5 -fasm-blocks -arch i386 -march=prescott -momit-leaf-frame-pointer -mtune=core2>)

	target_link_options(${TARGET_NAME} PRIVATE
		$<$<PLATFORM_ID:Linux>:-Wl,-Map,${TARGET_NAME}_map.txt>)
	
	target_sources(${TARGET_NAME}
		PRIVATE
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/src/game/UnifiedSDK.natvis)
endfunction()

add_subdirectory(src/game/client)
add_subdirectory(src/game/server)

# Add generated files now so it doesn't cause source_group to fail.
target_sources(client PRIVATE ${CMAKE_BINARY_DIR}/ProjectInfo.h)
target_sources(server PRIVATE ${CMAKE_BINARY_DIR}/ProjectInfo.h)

# Set Visual Studio starting project
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT client)

if (MSVC)
	set(HL_EXECUTABLE "hl.exe")
	set(HLDS_EXECUTABLE "hlds.exe")
	
	set(HalfLife_DEVELOPER_LEVEL "0" CACHE STRING "When launching from Visual Studio, the developer level is set to this value")
	set_property(CACHE HalfLife_DEVELOPER_LEVEL PROPERTY STRINGS 0 1 2 3)
	
	option(HalfLife_ENABLE_CHEATS "When launching from Visual Studio, enable cheats as well" OFF)
	option(HalfLife_ENABLE_CONSOLE "When launching from Visual Studio, enable the console on startup" OFF)
	option(HalfLife_ENABLE_DEV_MODE "When launching from Visual Studio, enables developer mode. The engine will enable the console on startup, sets developer to 1 during startup and sets sv_cheats to 1" OFF)
	
	set(HalfLife_ADDITIONAL_COMMAND_ARGUMENTS "" CACHE STRING "When launching from Visual Studio, additional command line arguments to add")
	
	set(COMMAND_ARGUMENTS "-game ${MOD_NAME} +developer ${HalfLife_DEVELOPER_LEVEL}")
	
	if (HalfLife_ENABLE_CHEATS)
		set(COMMAND_ARGUMENTS "${COMMAND_ARGUMENTS} +sv_cheats 1")
	endif()
	
	if (HalfLife_ENABLE_CONSOLE)
		set(COMMAND_ARGUMENTS "${COMMAND_ARGUMENTS} -console")
	endif()
	
	if (HalfLife_ENABLE_DEV_MODE)
		set(COMMAND_ARGUMENTS "${COMMAND_ARGUMENTS} -dev")
	endif()
	
	set(COMMAND_ARGUMENTS "${COMMAND_ARGUMENTS} ${HalfLife_ADDITIONAL_COMMAND_ARGUMENTS}")

	# Set debugging settings to work on the mod directory
	set_target_properties(client PROPERTIES
		VS_DEBUGGER_COMMAND "${HALFLIFE_DIRECTORY}/${HL_EXECUTABLE}"
		VS_DEBUGGER_COMMAND_ARGUMENTS "${COMMAND_ARGUMENTS}"
		VS_DEBUGGER_WORKING_DIRECTORY "${HALFLIFE_DIRECTORY}")

	# If HalfLife_HLDS_DIRECTORY is not specified it will leave a non-functional "default" setting
	set_target_properties(server PROPERTIES
		VS_DEBUGGER_COMMAND "${HalfLife_HLDS_DIRECTORY}/${HLDS_EXECUTABLE}"
		VS_DEBUGGER_COMMAND_ARGUMENTS "${COMMAND_ARGUMENTS}"
		VS_DEBUGGER_WORKING_DIRECTORY "${HalfLife_HLDS_DIRECTORY}")
endif()
	
# Set install paths to the user-defined mod directory
install(TARGETS client
	RUNTIME DESTINATION cl_dlls
	LIBRARY DESTINATION cl_dlls
)

install(TARGETS server
	RUNTIME DESTINATION dlls
	LIBRARY DESTINATION dlls
)

configure_file(config/liblist.gam.in liblist.gam @ONLY)

install(FILES 
	config/network/delta.lst
	${CMAKE_BINARY_DIR}/liblist.gam
	DESTINATION .)

if (MSVC)
	install(FILES $<TARGET_PDB_FILE:client> DESTINATION cl_dlls OPTIONAL)
	install(FILES $<TARGET_PDB_FILE:server> DESTINATION dlls OPTIONAL)
	
	# Copy the OpenAL library on Windows only.
	# On Linux OpenAL is loaded by Miles Sound System, and the Steam runtime provides this library.
	# CMake doesn't currently support installing imported libraries of type UNKNOWN.
	# See https://gitlab.kitware.com/cmake/cmake/-/issues/22406
	#install(IMPORTED_RUNTIME_ARTIFACTS OpenAL::OpenAL
	#	RUNTIME DESTINATION cl_dlls)
	
	install(FILES $<TARGET_FILE:OpenAL::OpenAL> DESTINATION cl_dlls)
endif()

# Set up the script that will copy the mod libraries to the HLDS directory
if (NOT ${HalfLife_HLDS_DIRECTORY} STREQUAL "")
	set(hldsInstallScriptFile ${CMAKE_CURRENT_BINARY_DIR}/InstallToHLDS.cmake)
	configure_file(cmake/InstallToHLDS.cmake.in ${hldsInstallScriptFile} @ONLY)
	install(SCRIPT ${hldsInstallScriptFile})
endif()
	
