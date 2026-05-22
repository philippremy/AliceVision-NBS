#[=======================================================================[.rst:
FindClp
-------

Find the Clp include directory and library.

Use this module by invoking find_package with the form::

.. code-block:: cmake

  find_package(Clp
    [version]              # Minimum version e.g. 1.8.0
    [REQUIRED]             # Fail with error if Clp is not found
  )

Imported targets
^^^^^^^^^^^^^^^^

This module defines the following :prop_tgt:`IMPORTED` targets:

.. variable:: Coin::Clp

  Imported target for using the Clp library, if found.

.. variable:: Coin::ClpSolver

  Imported target for using the ClpSolver library, if found.

.. variable:: Coin::OsiClp

  Imported target for using the OsiClp library, if found.

Result variables
^^^^^^^^^^^^^^^^

.. variable:: Clp_FOUND

  Set to true if Clp library found, otherwise false or undefined.

.. variable:: Clp_INCLUDE_DIRS

  Paths to include directories listed in one variable for use by Clp client.

.. variable:: Clp_LIBRARIES

  Paths to libraries to linked against to use Clp.

.. variable:: Clp_VERSION

  The version string of Clp found.

Cache variables
^^^^^^^^^^^^^^^

For users who wish to edit and control the module behavior, this module
reads hints about search locations from the following variables::

.. variable:: Clp_INCLUDE_DIR

  Path to Clp include directory with ``ClpConfig.h`` header.

.. variable:: Clp_LIBRARY

  Path to Clp library to be linked.

NOTE: The variables above should not usually be used in CMakeLists.txt files!

#]=======================================================================]

### Find library ##############################################################

if(NOT Clp_LIBRARY OR NOT ClpSolver_LIBRARY)
  find_library(Clp_LIBRARY_RELEASE NAMES Clp)
  find_library(Clp_LIBRARY_DEBUG NAMES Clp)
  find_library(ClpSolver_LIBRARY_RELEASE NAMES ClpSolver)
  find_library(ClpSolver_LIBRARY_DEBUG NAMES ClpSolver)

  include(SelectLibraryConfigurations)
  select_library_configurations(Clp)
  select_library_configurations(ClpSolver)
else()
  file(TO_CMAKE_PATH "${Clp_LIBRARY}" Clp_LIBRARY)
  file(TO_CMAKE_PATH "${ClpSolver_LIBRARY}" ClpSolver_LIBRARY)
endif()

if(NOT OsiClp_LIBRARY)
  find_library(OsiClp_LIBRARY_RELEASE NAMES OsiClp)
  find_library(OsuClp_LIBRARY_DEBUG NAMES OsiClp)

  include(SelectLibraryConfigurations)
  select_library_configurations(OsiClp)
else()
  file(TO_CMAKE_PATH "${OsiClp_LIBRARY}" OsiClp_LIBRARY)
endif()

### Find include directory ####################################################
find_path(Clp_INCLUDE_DIR
    NAMES ClpConfig.h
    PATH_SUFFIXES
      "clp"
      "clp/coin"
)

if(Clp_INCLUDE_DIR AND EXISTS "${Clp_INCLUDE_DIR}/ClpConfig.h")
  file(STRINGS "${Clp_INCLUDE_DIR}/ClpConfig.h" _clp_h_contents
      REGEX "^[ \t]*#[ \t]*define[ \t]+CLP_VERSION[ \t]+\"[0-9]+(\\.[0-9]+)*\"")
  list(GET _clp_h_contents 0 _clp_version_line)
  string(REGEX REPLACE
      ".*CLP_VERSION[ \t]+\"([0-9]+(\\.[0-9]+)*)\".*" "\\1"
      _clp_h_version
      "${_clp_version_line}"
  )
  set(Clp_VERSION "${_clp_h_version}")
  unset(_clp_h_contents)
endif()

### Set result variables ######################################################
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Clp DEFAULT_MSG
    Clp_LIBRARY Clp_INCLUDE_DIR Clp_VERSION)

mark_as_advanced(Clp_INCLUDE_DIR Clp_LIBRARY)

set(Clp_LIBRARIES ${Clp_LIBRARY})
set(Clp_INCLUDE_DIRS ${Clp_INCLUDE_DIR})

### Import targets ############################################################
if(Clp_FOUND)
  if(NOT TARGET Coin::Clp)
    add_library(Coin::Clp UNKNOWN IMPORTED)
    set_target_properties(Coin::Clp PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        INTERFACE_INCLUDE_DIRECTORIES "${Clp_INCLUDE_DIR}")

    if(Clp_LIBRARY_RELEASE)
      set_property(TARGET Coin::Clp APPEND PROPERTY
          IMPORTED_CONFIGURATIONS RELEASE)
      set_target_properties(Coin::Clp PROPERTIES
          IMPORTED_LOCATION_RELEASE "${Clp_LIBRARY_RELEASE}")
    endif()

    if(Clp_LIBRARY_DEBUG)
      set_property(TARGET Coin::Clp APPEND PROPERTY
          IMPORTED_CONFIGURATIONS DEBUG)
      set_target_properties(Coin::Clp PROPERTIES
          IMPORTED_LOCATION_DEBUG "${Clp_LIBRARY_DEBUG}")
    endif()

    if(NOT Clp_LIBRARY_RELEASE AND NOT Clp_LIBRARY_DEBUG)
      set_property(TARGET Coin::Clp APPEND PROPERTY
          IMPORTED_LOCATION "${Clp_LIBRARY}")
    endif()
  endif()
  if(NOT TARGET Coin::ClpSolver)
    add_library(Coin::ClpSolver UNKNOWN IMPORTED)
    set_target_properties(Coin::ClpSolver PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        INTERFACE_INCLUDE_DIRECTORIES "${Clp_INCLUDE_DIR}")

    if(ClpSolver_LIBRARY_RELEASE)
      set_property(TARGET Coin::ClpSolver APPEND PROPERTY
          IMPORTED_CONFIGURATIONS RELEASE)
      set_target_properties(Coin::ClpSolver PROPERTIES
          IMPORTED_LOCATION_RELEASE "${ClpSolver_LIBRARY_RELEASE}")
    endif()

    if(ClpSolver_LIBRARY_DEBUG)
      set_property(TARGET Coin::ClpSolver APPEND PROPERTY
          IMPORTED_CONFIGURATIONS DEBUG)
      set_target_properties(Coin::ClpSolver PROPERTIES
          IMPORTED_LOCATION_DEBUG "${ClpSolver_LIBRARY_DEBUG}")
    endif()

    if(NOT ClpSolver_LIBRARY_RELEASE AND NOT ClpSolver_LIBRARY_DEBUG)
      set_property(TARGET Coin::ClpSolver APPEND PROPERTY
          IMPORTED_LOCATION "${ClpSolver_LIBRARY}")
    endif()
    target_link_libraries(Coin::Clp INTERFACE Coin::ClpSolver)
  endif()
  if(NOT TARGET Coin::OsiClp)
    add_library(Coin::OsiClp UNKNOWN IMPORTED)
    set_target_properties(Coin::OsiClp PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        INTERFACE_INCLUDE_DIRECTORIES "${Clp_INCLUDE_DIR}")

    if(OsiClp_LIBRARY_RELEASE)
      set_property(TARGET Coin::OsiClp APPEND PROPERTY
          IMPORTED_CONFIGURATIONS RELEASE)
      set_target_properties(Coin::OsiClp PROPERTIES
          IMPORTED_LOCATION_RELEASE "${OsiClp_LIBRARY_RELEASE}")
    endif()

    if(OsiClp_LIBRARY_DEBUG)
      set_property(TARGET Coin::OsiClp APPEND PROPERTY
          IMPORTED_CONFIGURATIONS DEBUG)
      set_target_properties(Coin::OsiClp PROPERTIES
          IMPORTED_LOCATION_DEBUG "${OsiClp_LIBRARY_DEBUG}")
    endif()

    if(NOT OsiClp_LIBRARY_RELEASE AND NOT OsiClp_LIBRARY_DEBUG)
      set_property(TARGET Coin::OsiClp APPEND PROPERTY
          IMPORTED_LOCATION "${OsiClp_LIBRARY}")
    endif()
  endif()
endif()
