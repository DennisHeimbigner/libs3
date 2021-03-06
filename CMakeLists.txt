############
# Set Project Properties
#############

cmake_minimum_required(VERSION 2.8.12)

#######
# Project Name: libs3
#######
PROJECT(libs3 CXX C)
SET(PACKAGE "libs3" CACHE STRING "")

SET(CMAKE_C_COMPILER "/usr/bin/gcc")
SET(CMAKE_CXX_COMPILER "/usr/bin/g++")

#######
# VERSION INFO:
#
# Just setting to 1.0.0 for now.
#######
SET(S3_VERSION_MAJOR 1)
SET(S3_VERSION_MINOR 0)
SET(S3_VERSION_PATCH 0)
SET(S3_VERSION_NOTE  "")
SET(libs3_VERSION ${S3_VERSION_MAJOR}.${S3_VERSION_MINOR}.${S3_VERSION_PATCH}${S3_VERSION_NOTE})
SET(libs3_SO_VERSION 1)
SET(libs3_LIB_VERSION 1.0.0)
##
# Get system configuration, Use it to determine osname, os release, cpu. These
# will be used when committing to CDash.
##
find_program(UNAME NAMES uname)
IF(UNAME)
  macro(getuname name flag)
    exec_program("${UNAME}" ARGS "${flag}" OUTPUT_VARIABLE "${name}")
  endmacro(getuname)
  getuname(osname -s)
  getuname(osrel  -r)
  getuname(cpu    -m)
  set(BUILDNAME "${osname}-${osrel}-${cpu}" CACHE STRING "Build name variable for CDash")
ENDIF()

##
# For CMAKE_INSTALL_LIBDIR
##
INCLUDE(GNUInstallDirs)

SET(CMAKE_INSTALL_CMAKEDIR cmake)

IF(NOT DEFINED CMAKE_INSTALL_LIBDIR)
  SET(CMAKE_INSTALL_LIBDIR lib)
ENDIF(NOT DEFINED CMAKE_INSTALL_LIBDIR)

IF(MSVC)
  SET(GLOBAL PROPERTY USE_FOLDERS ON)
ENDIF()

##
# Add custom CMake Module
##
SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules/"
  CACHE INTERNAL "Location of our custom CMake modules.")

##
# auto-configure style checks, other CMake modules.
##
# Are these actually used?
INCLUDE(${CMAKE_ROOT}/Modules/CheckLibraryExists.cmake)
INCLUDE(${CMAKE_ROOT}/Modules/CheckIncludeFile.cmake)
INCLUDE(${CMAKE_ROOT}/Modules/CheckTypeSize.cmake)
INCLUDE(${CMAKE_ROOT}/Modules/CheckFunctionExists.cmake)
INCLUDE(${CMAKE_ROOT}/Modules/CheckCXXSourceCompiles.cmake)
INCLUDE(${CMAKE_ROOT}/Modules/CheckCSourceCompiles.cmake)
INCLUDE(${CMAKE_ROOT}/Modules/TestBigEndian.cmake)
INCLUDE(${CMAKE_ROOT}/Modules/CheckSymbolExists.cmake)
INCLUDE(${CMAKE_ROOT}/Modules/GetPrerequisites.cmake)

INCLUDE(CheckCCompilerFlag)
INCLUDE(CheckCXXCompilerFlag)
FIND_PACKAGE(PkgConfig QUIET)

# Set the build type.
IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE DEBUG CACHE STRING "Choose the type of build, options are: None, Debug, Release."
    FORCE)
ENDIF()

# Set build type uppercase
STRING(TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE)

# Determine the configure date.

EXECUTE_PROCESS(
  COMMAND date
  OUTPUT_VARIABLE CONFIG_DATE
  )
IF(CONFIG_DATE)
	string(STRIP ${CONFIG_DATE} CONFIG_DATE)
ENDIF()

#########
# End setting general properties.
#########

#########
# Compiler Options
#########




####
# Default building shared libraries.
# BUILD_SHARED_LIBS is provided by/used by
# CMake directly.
#####
OPTION(BUILD_SHARED_LIBS "Build library as a shared library." ON)
IF(BUILD_SHARED_LIBS)
  SET(CMAKE_POSITION_INDEPENDENT_CODE ON)
ENDIF()

#####
# Set some default linux gcc & apple compiler options for
# debug builds.
#####
IF(CMAKE_CXX_COMPILER_IS_GNUCC OR APPLE)
  OPTION(ENABLE_COVERAGE_TESTS "Enable compiler flags needed to perform coverage tests." OFF)
  OPTION(ENABLE_CONVERSION_WARNINGS "Enable warnings for implicit conversion from 64 to 32-bit datatypes." ON)
  OPTION(ENABLE_LARGE_FILE_TESTS "Enable large file tests." OFF)

  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall")

  # Debugging flags
  SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -Wall -g -O0")

  # Check to see if -Wl,--no-undefined is supported.
  CHECK_CXX_LINKER_FLAG("-Wl,--no-undefined" LIBTOOL_HAS_NO_UNDEFINED)

  IF(LIBTOOL_HAS_NO_UNDEFINED)
    SET(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG} -Wl,--no-undefined")
  ENDIF()
  SET(CMAKE_REQUIRED_FLAGS "${TMP_CMAKE_REQUIRED_FLAGS}")

  # Coverage tests need to have optimization turned off.
  IF(ENABLE_COVERAGE_TESTS)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0 -fprofile-arcs -ftest-coverage")
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fprofile-arcs -ftest-coverage")
    MESSAGE(STATUS "Coverage Tests: On.")
  ENDIF()

    # Warnings for 64-to-32 bit conversions.
  IF(ENABLE_CONVERSION_WARNINGS)
    CHECK_CXX_COMPILER_FLAG(-Wconversion CXX_HAS_WCONVERSION)
    CHECK_CXX_COMPILER_FLAG(-Wshorten-64-to-32 CXX_HAS_SHORTEN_64_32)

    IF(CXX_HAS_SHORTEN_64_32)
      SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Wshorten-64-to-32")
    ENDIF()
    IF(CXX_HAS_WCONVERSION)
      SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Wconversion")
    ENDIF()

  ENDIF(ENABLE_CONVERSION_WARNINGS)

ENDIF(CMAKE_CXX_COMPILER_IS_GNUCC OR APPLE)

ADD_DEFINITIONS()
#####
# Supress CRT Warnings.
# Only necessary for Windows
#####
IF(MSVC)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_WARNINGS)
ENDIF()

#####
# Configuration for post-install RPath
# Adapted from http://www.cmake.org/Wiki/CMake_RPATH_handling
#####
IF(NOT MSVC)
  # use, i.e. don't skip the full RPATH for the build tree
  SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

  # when building, don't use the install RPATH already
  # (but later on when installing)
  SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

  if(APPLE)
    set(CMAKE_MACOSX_RPATH ON)
  endif(APPLE)

  # add the automatically determined parts of the RPATH
  # which point to directories outside the build tree to the install RPATH
  SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

  # the RPATH to be used when installing,
  # but only if it's not a system directory
  LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}" isSystemDir)
  IF("${isSystemDir}" STREQUAL "-1")
    SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}")
  ENDIF("${isSystemDir}" STREQUAL "-1")

ENDIF()

##
# End configuration for post-install RPath
##

#####
# Set the appropriate compiler/architecture for universal OSX binaries.
#####
IF(${CMAKE_SYSTEM_NAME} EQUAL "Darwin")
  SET(CMAKE_OSX_ARCHITECTURES i386;x86_64)
ENDIF(${CMAKE_SYSTEM_NAME} EQUAL "Darwin")


##########
# End compiler options
##########

##########
# User Options
##########

##########
# End user options
##########

CHECK_INCLUDE_FILE("stdlib.h"  HAVE_STDLIB_H)
CHECK_INCLUDE_FILE("stdio.h"   HAVE_STDIO_H)
CHECK_INCLUDE_FILE("strings.h"   HAVE_STRINGS_H)
CHECK_INCLUDE_FILE("signal.h"    HAVE_SIGNAL_H)
CHECK_INCLUDE_FILE("sys/select.h"   HAVE_SYS_SELECT_H)

INCLUDE_DIRECTORIES(inc)

SET(libs3_SOURCES
src/acl.c
src/bucket.c
src/error_parser.c
src/general.c
src/mingw_functions.c
src/mingw_s3_functions.c
src/multipart.c
src/object.c
src/request.c
src/request_context.c
src/response_headers_handler.c
src/s3.c
src/service.c
src/service_access_logging.c
src/util.c)

ADD_LIBRARY(libs3 ${libs3_SOURCES})

SET_TARGET_PROPERTIES(libs3 PROPERTIES LINKER_LANGUAGE C)

SET_TARGET_PROPERTIES(libs3 PROPERTIES
  VERSION ${libs3_LIB_VERSION}
  SOVERSION ${libs3_SO_VERSION}
  )

INSTALL(FILES inc/libs3.h
	      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
	      COMPONENT headers)
INSTALL(FILES libs3-config.cmake
	      DESTINATION ${CMAKE_INSTALL_CMAKEDIR}
	      COMPONENT headers)

INSTALL(
  TARGETS libs3
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    COMPONENT libraries
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    COMPONENT libraries
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    COMPONENT libraries
  INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  )











##########
# Installation stuff
##########
##
# Brute force, grab all of the dlls from the dependency directory,
# install them in the binary dir. Grab all of the .libs, put them
# in the libdir.
##

###
# Subdirectory CMakeLists.txt files should specify their own
# 'install' files.
# Including 'CPack' kicks everything off.
###
INCLUDE(InstallRequiredSystemLibraries)

###
# Create pkgconfig files.
###


# Set
SET(prefix ${CMAKE_INSTALL_PREFIX})
SET(exec_prefix ${CMAKE_INSTALL_PREFIX})
SET(libdir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
SET(includedir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})
SET(cmakedir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_CMAKEDIR})
SET(CC ${CMAKE_C_COMPILER})

# CPack inclusion must come last.
INCLUDE(CPack)
