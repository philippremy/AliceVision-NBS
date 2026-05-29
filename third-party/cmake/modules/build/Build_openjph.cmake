# =============================================================================
# Build_openjph.cmake - Integrates an embedded openjph into the project
#
# Special cases considered:
# - Explicitly sets openjph_VERSION to 0.27.3 for OpenEXR, which does a version
#   check to ensure the openjph is recent enough. This variable will not be set
#   when included by FetchContent.
# - Explicitly add the "<openjph_SOURCE_DIR>/src/core" folder to the include
#   directories of openjph, because OpenEXR expects an installed form, which is
#   done by applying a minimal patch with Git.
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(openjph
    SUBMODULE_NAME "OpenJPH"
    PATCH_STEP
      "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/build/patch/openjph-include-dirs.patch"
    CMAKE_EVAL_CODE
      "set(OJPH_ENABLE_TIFF_SUPPORT OFF)"   # Only used in Apps, not in the library
      "set(OJPH_BUILD_TESTS OFF)"
      "set(OJPH_BUILD_EXECUTABLES OFF)"
      "set(OJPH_BUILD_STREAM_EXPAND OFF)"
      "set(OJPH_BUILD_FUZZER OFF)"
    CMAKE_EVAL_COMPAT_CODE
      # Provide a version variable for OpenEXR
      "set(openjph_VERSION 0.27.3 CACHE STRING \"The version for openjph\" FORCE)"
)