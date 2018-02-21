# Distributed under the OSI-approved BSD 3-Clause License.
#
# Find the Pthreads library
# This module searches for the Pthreads library (including the
# pthreads-win32 port).
#
# This module defines these variables:
#
#  PTHREADS-WIN32_FOUND       - True if the Pthreads-win32 library was found
#  PTHREADS-WIN32_LIBRARY     - The location of the Pthreads-win32 library
#  PTHREADS-WIN32_INCLUDE_DIR - Pthreads-win32's include directory
#  PTHREADS-WIN32_DEFINITIONS - Preprocessor definitions to define
#
# Hints and Build Customization
# =============================
#
# PTHREADS-WIN32_EXCEPTION_SCHEME
# -------------------------------
#
# This module responds to the PTHREADS-WIN32_EXCEPTION_SCHEME
# variable on Win32 to allow the user to control the
# library linked against.  The Pthreads-win32 port
# provides the ability to link against a version of the
# library with exception handling. IT IS NOT RECOMMENDED
# THAT YOU CHANGE PTHREADS-WIN32_EXCEPTION_SCHEME TO ANYTHING OTHER THAN
# "C" because most POSIX thread implementations do not support stack
# unwinding.
#       C  = no exceptions (default)
#          (NOTE: This is the default scheme on most POSIX thread
#           implementations and what you should probably be using)
#       CE = C++ Exception Handling
#       SE = Structure Exception Handling (MSVC only)
#
# PTHREADS-WIN32_ROOT
# -------------------
#
# to the root directory of an OpenSSL installation.

# PTHREADS-WIN32_USE_STATIC_LIBS
# ------------------------------
#
# to ``TRUE`` to look for static libraries.
#

# Define a default exception scheme to link against
# and validate user choice.
if(NOT DEFINED PTHREADS-WIN32_EXCEPTION_SCHEME)
  # Assign default if needed
  set(PTHREADS-WIN32_EXCEPTION_SCHEME "C")
else()
  # Validate
  if(NOT PTHREADS-WIN32_EXCEPTION_SCHEME STREQUAL "C" AND
  NOT PTHREADS-WIN32_EXCEPTION_SCHEME STREQUAL "CE" AND
  NOT PTHREADS-WIN32_EXCEPTION_SCHEME STREQUAL "SE")

  message(FATAL_ERROR "See documentation for FindPTHREADS-WIN32.cmake,
  only C, CE, and SE modes are allowed")

  endif()

  if(NOT MSVC AND PTHREADS-WIN32_EXCEPTION_SCHEME STREQUAL "SE")
    message(FATAL_ERROR "Structured Exception Handling is MSVC only")
  endif()

endif()

# XXX - One day, we will have this...
# find_package(PkgConfig QUIET)
# pkg_check_modules(PTHREADS-WIN32 QUIET Pthreads-win32)

# Support preference of static libs by adjusting CMAKE_FIND_LIBRARY_SUFFIXES
# and CMAKE_FIND_LIBRARY_PREFIXES
if(PTHREADS-WIN32_USE_STATIC_LIBS)
  set(pthreads-win32_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})
  set(pthreads-win32_ORIG_CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_FIND_LIBRARY_PREFIXES})

  if(MSVC)
    set(CMAKE_FIND_LIBRARY_PREFIXES lib ${CMAKE_FIND_LIBRARY_PREFIXES})
    set(CMAKE_FIND_LIBRARY_SUFFIXES .lib ${CMAKE_FIND_LIBRARY_SUFFIXES})
  elseif(MINGW)
    set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
  endif()

  set(PTHREADS-WIN32_DEFINITIONS ${PTHREADS-WIN32_DEFINITIONS} -DPTW32_STATIC_LIB)
endif()

if(NOT PTHREADS-WIN32_ROOT)
  set(PTHREADS-WIN32_ROOT $ENV{PTHREADS-WIN32_ROOT})
endif()

# Find the header file
find_path(PTHREADS-WIN32_INCLUDE_DIR pthread.h
  HINTS
  $ENV{PTHREADS-WIN32_INCLUDE_PATH}
  ${PTHREADS-WIN32_ROOT}
  PATH_SUFFIXES include
)
# XXX - make sure we didn't find any other pthread header

# Find the library
set(names)
if(MSVC)
  set(names pthreadV${PTHREADS_EXCEPTION_SCHEME}2)
elseif(MINGW)
  set(names pthreadG${PTHREADS_EXCEPTION_SCHEME}2)
endif()

find_library(PTHREADS-WIN32_LIBRARY NAMES ${names}
  HINTS
  $ENV{PTHREADS-WIN32_LIBRARY_PATH}
  ${PTHREADS-WIN32_ROOT}
  PATH_SUFFIXES lib
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PTHREADS-WIN32
  DEFAULT_MSG
  PTHREADS-WIN32_INCLUDE_DIR
  PTHREADS-WIN32_LIBRARY
)

if(PTHREADS-WIN32_INCLUDE_DIR AND PTHREADS-WIN32_LIBRARY)
  set(PTHREADS-WIN32_DEFINITIONS ${PTHREADS-WIN32_DEFINITIONS} -DHAVE_PTHREADS_WIN32)
  add_definitions(${PTHREADS-WIN32_DEFINITIONS})
  set(PTHREADS-WIN32_INCLUDE_DIRS ${PTHREADS-WIN32_INCLUDE_DIR})
  set(PTHREADS-WIN32_LIBRARIES ${PTHREADS-WIN32_LIBRARY})
endif()

mark_as_advanced(PTHREADS-WIN32_INCLUDE_DIR PTHREADS-WIN32_LIBRARY)

# Restore the original find library ordering
if(PTHREADS-WIN32_USE_STATIC_LIBS)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ${pthreads-win32_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES})
  set(CMAKE_FIND_LIBRARY_PREFIXES ${pthreads-win32_ORIG_CMAKE_FIND_LIBRARY_PREFIXES})
endif()
