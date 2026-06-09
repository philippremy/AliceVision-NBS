# =============================================================================
# Build_ZLIB.cmake - Integrates an embedded zlib into the project
#
# Special cases considered:
# - Create ZLIB::ZLIB target if it does not exist
# - Set ZLIB_INCLUDE_DIR (assimp requires this)
# - Set ZLIB_LIBRARIES (assimp requires this)
# - Set ZLIB_FOUND to TRUE (assimp requires this)
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(ZLIB
    SUBMODULE_NAME "zlib"
    PATCH_STEP
      "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/build/patch/zlib-CPack.patch"
    CMAKE_EVAL_CODE
      "set(ZLIB_BUILD_TESTING OFF)"
      "set(ZLIB_BUILD_SHARED ${BUILD_SHARED_LIBS})"
      "set(ZLIB_BUILD_STATIC ${BUILD_STATIC_LIBS})"
      "set(ZLIB_INSTALL ${ALICEVISION_INSTALL_THIRD_PARTY})"
      "set(ZLIB_PREFIX OFF)"
      "set(ZLIB_BUILD_GVMAT64 OFF)"
      "set(ZLIB_BUILD_INFBACK9 OFF)"
      "set(ZLIB_BUILD_CRC32VX OFF)"
      "set(ZLIB_BUILD_ADA OFF)"
      "set(ZLIB_BUILD_BLAST OFF)"
      "set(ZLIB_BUILD_IOSTREAM3 OFF)"
      "set(ZLIB_BUILD_MINIZIP OFF)"
      "set(ZLIB_BUILD_PUFF OFF)"
      "set(ZLIB_BUILD_TESTZLIB OFF)"
      "set(ZLIB_BUILD_ZLIB1_DLL OFF)"
)

# Add ZLIB::ZLIB if in a static build
if(NOT TARGET ZLIB::ZLIB)
  if(TARGET ZLIB::ZLIBSTATIC)
    add_library(__zlib_interface INTERFACE)
    target_link_libraries(__zlib_interface INTERFACE ZLIB::ZLIBSTATIC)
    get_target_property(zlib_static_inc_dirs ZLIB::ZLIBSTATIC INCLUDE_DIRECTORIES)
    target_include_directories(__zlib_interface INTERFACE ${zlib_static_inc_dirs})
    add_library(ZLIB::ZLIB ALIAS __zlib_interface)
  else()
    message(FATAL_ERROR "Target ZLIB::ZLIB is not defined after configuring ZLIB, but ZLIB::ZLIBSTATIC is not available as well!")
  endif()
endif()

# Set ZLIB_LIBRARIES and ZLIB_INCLUDE_DIR
set(ZLIB_LIBRARIES ZLIB::ZLIB CACHE STRING "The libraries to link against for zlib" FORCE)
get_target_property(zlib_include_dir ZLIB::ZLIB INCLUDE_DIRECTORIES)
# These might be INTERFACE_INCLUDE_DIRECTORIES (see above)
if(NOT zlib_include_dir)
  get_target_property(zlib_include_dir ZLIB::ZLIB INTERFACE_INCLUDE_DIRECTORIES)
  if(NOT zlib_include_dir)
  message(FATAL_ERRRO "[Build_ZLIB] Unable to determine include directories for ZLIB::ZLIB!")
  endif()
endif()
set(ZLIB_INCLUDE_DIR ${zlib_include_dir} CACHE STRING "The directories to include for zlib" FORCE)

# Set ZLIB_FOUND
set(ZLIB_FOUND TRUE CACHE BOOL "Whether ZLIB was found" FORCE)