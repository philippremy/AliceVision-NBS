#[=======================================================================[.rst:
FindCoinUtils
-------

Find the CoinUtils include directory and library.

Use this module by invoking find_package with the form::

.. code-block:: cmake

  find_package(CoinUtils
    [version]              # Minimum version e.g. 1.8.0
    [REQUIRED]             # Fail with error if CoinUtils is not found
  )

Imported targets
^^^^^^^^^^^^^^^^

This module defines the following :prop_tgt:`IMPORTED` targets:

.. variable:: Coin::CoinUtils

  Imported target for using the CoinUtils library, if found.

Result variables
^^^^^^^^^^^^^^^^

.. variable:: CoinUtils_FOUND

  Set to true if CoinUtils library found, otherwise false or undefined.

.. variable:: CoinUtils_INCLUDE_DIRS

  Paths to include directories listed in one variable for use by CoinUtils client.

.. variable:: CoinUtils_LIBRARIES

  Paths to libraries to linked against to use CoinUtils.

.. variable:: CoinUtils_VERSION

  The version string of CoinUtils found.

Cache variables
^^^^^^^^^^^^^^^

For users who wish to edit and control the module behavior, this module
reads hints about search locations from the following variables::

.. variable:: CoinUtils_INCLUDE_DIR

  Path to CoinUtils include directory with ``CoinUtilsConfig.h`` header.

.. variable:: CoinUtils_LIBRARY

  Path to CoinUtils library to be linked.

NOTE: The variables above should not usually be used in CMakeLists.txt files!

#]=======================================================================]

### Find library ##############################################################

if(NOT CoinUtils_LIBRARY)
  find_library(CoinUtils_LIBRARY_RELEASE NAMES CoinUtils)
  find_library(CoinUtils_LIBRARY_DEBUG NAMES CoinUtils)

  include(SelectLibraryConfigurations)
  select_library_configurations(CoinUtils)
else()
  file(TO_CMAKE_PATH "${CoinUtils_LIBRARY}" CoinUtils_LIBRARY)
endif()

### Find include directory ####################################################
find_path(CoinUtils_INCLUDE_DIR
    NAMES CoinUtilsConfig.h
    PATH_SUFFIXES
      "coinutils"
      "coinutils/coin"
)

if(CoinUtils_INCLUDE_DIR AND EXISTS "${CoinUtils_INCLUDE_DIR}/CoinUtilsConfig.h")
  file(STRINGS "${CoinUtils_INCLUDE_DIR}/CoinUtilsConfig.h" _coinutils_h_contents
      REGEX "^[ \t]*#[ \t]*define[ \t]+COINUTILS_VERSION[ \t]+\"[0-9]+(\\.[0-9]+)*\"")
  list(GET _coinutils_h_contents 0 _coinutils_version_line)
  string(REGEX REPLACE
      ".*COINUTILS_VERSION[ \t]+\"([0-9]+(\\.[0-9]+)*)\".*" "\\1"
      _coinutils_h_version
      "${_coinutils_version_line}"
  )
  set(CoinUtils_VERSION "${_coinutils_h_version}")
  unset(_coinutils_h_contents)
endif()

### Set result variables ######################################################
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CoinUtils DEFAULT_MSG
    CoinUtils_LIBRARY CoinUtils_INCLUDE_DIR CoinUtils_VERSION)

mark_as_advanced(CoinUtils_INCLUDE_DIR CoinUtils_LIBRARY)

set(CoinUtils_LIBRARIES ${CoinUtils_LIBRARY})
set(CoinUtils_INCLUDE_DIRS ${CoinUtils_INCLUDE_DIR})

### Import targets ############################################################
if(CoinUtils_FOUND)
  if(NOT TARGET Coin::CoinUtils)
    add_library(Coin::CoinUtils UNKNOWN IMPORTED)
    set_target_properties(Coin::CoinUtils PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        INTERFACE_INCLUDE_DIRECTORIES "${CoinUtils_INCLUDE_DIR}")

    if(CoinUtils_LIBRARY_RELEASE)
      set_property(TARGET Coin::CoinUtils APPEND PROPERTY
          IMPORTED_CONFIGURATIONS RELEASE)
      set_target_properties(Coin::CoinUtils PROPERTIES
          IMPORTED_LOCATION_RELEASE "${CoinUtils_LIBRARY_RELEASE}")
    endif()

    if(CoinUtils_LIBRARY_DEBUG)
      set_property(TARGET Coin::CoinUtils APPEND PROPERTY
          IMPORTED_CONFIGURATIONS DEBUG)
      set_target_properties(Coin::CoinUtils PROPERTIES
          IMPORTED_LOCATION_DEBUG "${CoinUtils_LIBRARY_DEBUG}")
    endif()

    if(NOT CoinUtils_LIBRARY_RELEASE AND NOT CoinUtils_LIBRARY_DEBUG)
      set_property(TARGET Coin::CoinUtils APPEND PROPERTY
          IMPORTED_LOCATION "${CoinUtils_LIBRARY}")
    endif()
  endif()
endif()
