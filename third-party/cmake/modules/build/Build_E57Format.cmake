# =============================================================================
# Build_E57Format.cmake - Integrates an embedded E57Format into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(E57Format
    SUBMODULE_NAME "libE57Format"
    CMAKE_EVAL_CODE
      "set(E57_VERBOSE OFF)"
      "set(E57_ENABLE_DIAGNOSTIC_OUTPUT OFF)"
      "set(E57_WRITE_CRAZY_PACKET_MODE  OFF)"
      "set(E57_RELEASE_LTO OFF)"
      "set(E57_BUILD_TEST OFF)"
      "set(E57FORMAT_SANITIZE_ALL OFF)"
      "set(E57FORMAT_SANITIZE_ADDRESS OFF)"
      "set(E57FORMAT_SANITIZE_UNDEFINED OFF)"
      "set(E57_GIT_SUBMODULE_UPDATE OFF)"
)
