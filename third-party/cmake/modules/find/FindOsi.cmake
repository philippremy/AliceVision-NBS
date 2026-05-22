#[=======================================================================[.rst:
FindOsi
-------

Find the Osi include directory and library.

Use this module by invoking find_package with the form::

.. code-block:: cmake

  find_package(Osi
    [version]              # Minimum version e.g. 1.8.0
    [REQUIRED]             # Fail with error if Osi is not found
  )

Imported targets
^^^^^^^^^^^^^^^^

This module defines the following :prop_tgt:`IMPORTED` targets:

.. variable:: Coin::Osi

  Imported target for using the Osi library, if found.

Result variables
^^^^^^^^^^^^^^^^

.. variable:: Osi_FOUND

  Set to true if Osi library found, otherwise false or undefined.

.. variable:: Osi_INCLUDE_DIRS

  Paths to include directories listed in one variable for use by Osi client.

.. variable:: Osi_LIBRARIES

  Paths to libraries to linked against to use Osi.

.. variable:: Osi_VERSION

  The version string of Osi found.

Cache variables
^^^^^^^^^^^^^^^

For users who wish to edit and control the module behavior, this module
reads hints about search locations from the following variables::

.. variable:: Osi_INCLUDE_DIR

  Path to Osi include directory with ``OsiConfig.h`` header.

.. variable:: Osi_LIBRARY

  Path to Osi library to be linked.

NOTE: The variables above should not usually be used in CMakeLists.txt files!

#]=======================================================================]

### Find library ##############################################################

if(NOT Osi_LIBRARY)
  find_library(Osi_LIBRARY_RELEASE NAMES Osi)
  find_library(Osi_LIBRARY_DEBUG NAMES Osi)

  include(SelectLibraryConfigurations)
  select_library_configurations(Osi)
else()
  file(TO_CMAKE_PATH "${Osi_LIBRARY}" Osi_LIBRARY)
endif()

### Find include directory ####################################################
find_path(Osi_INCLUDE_DIR
    NAMES OsiConfig.h
    PATH_SUFFIXES
      "osi"
      "osi/coin"
)

if(Osi_INCLUDE_DIR AND EXISTS "${Osi_INCLUDE_DIR}/OsiConfig.h")
  file(STRINGS "${Osi_INCLUDE_DIR}/OsiConfig.h" _osi_h_contents
      REGEX "^[ \t]*#[ \t]*define[ \t]+OSI_VERSION[ \t]+\"[0-9]+(\\.[0-9]+)*\"")
  list(GET _osi_h_contents 0 _osi_version_line)
  string(REGEX REPLACE
      ".*OSI_VERSION[ \t]+\"([0-9]+(\\.[0-9]+)*)\".*" "\\1"
      _osi_h_version
      "${_osi_version_line}"
  )
  set(Osi_VERSION "${_osi_h_version}")
  unset(_osi_h_contents)
endif()

### Set result variables ######################################################
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Osi DEFAULT_MSG
    Osi_LIBRARY Osi_INCLUDE_DIR Osi_VERSION)

mark_as_advanced(Osi_INCLUDE_DIR Osi_LIBRARY)

set(Osi_LIBRARIES ${Osi_LIBRARY})
set(Osi_INCLUDE_DIRS ${Osi_INCLUDE_DIR})

### Import targets ############################################################
if(Osi_FOUND)
  if(NOT TARGET Coin::Osi)
    add_library(Coin::Osi UNKNOWN IMPORTED)
    set_target_properties(Coin::Osi PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        INTERFACE_INCLUDE_DIRECTORIES "${Osi_INCLUDE_DIR}")

    if(Osi_LIBRARY_RELEASE)
      set_property(TARGET Coin::Osi APPEND PROPERTY
          IMPORTED_CONFIGURATIONS RELEASE)
      set_target_properties(Coin::Osi PROPERTIES
          IMPORTED_LOCATION_RELEASE "${Osi_LIBRARY_RELEASE}")
    endif()

    if(Osi_LIBRARY_DEBUG)
      set_property(TARGET Coin::Osi APPEND PROPERTY
          IMPORTED_CONFIGURATIONS DEBUG)
      set_target_properties(Coin::Osi PROPERTIES
          IMPORTED_LOCATION_DEBUG "${Osi_LIBRARY_DEBUG}")
    endif()

    if(NOT Osi_LIBRARY_RELEASE AND NOT Osi_LIBRARY_DEBUG)
      set_property(TARGET Coin::Osi APPEND PROPERTY
          IMPORTED_LOCATION "${Osi_LIBRARY}")
    endif()
  endif()
endif()
