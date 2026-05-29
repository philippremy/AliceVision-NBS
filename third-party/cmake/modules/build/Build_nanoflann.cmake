# =============================================================================
# Build_nanoflann.cmake - Integrates an embedded nanoflann into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(nanoflann
    CMAKE_EVAL_CODE
      "set(MASTER_PROJECT OFF)"
      "set(NANOFLANN_BUILD_EXAMPLES OFF)"
      "set(NANOFLANN_BUILD_TESTS OFF)"
      "set(MASTER_PROJECT_HAS_TARGET_UNINSTALL OFF)"
)