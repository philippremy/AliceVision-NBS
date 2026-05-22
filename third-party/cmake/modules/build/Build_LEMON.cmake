# =============================================================================
# Build_LEMON.cmake - Integrates an embedded libLEMON into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(LEMON
    CMAKE_EVAL_CODE
      "set(LEMON_ENABLE_GLPK OFF)"
      "set(LEMON_ENABLE_ILOG OFF)"
      "set(LEMON_ENABLE_COIN OFF)"
      "set(LEMON_ENABLE_SOPLEX OFF)"
)