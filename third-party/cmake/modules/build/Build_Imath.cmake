# =============================================================================
# Build_Imath.cmake - Integrates an embedded Imath into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(Imath
    CMAKE_EVAL_CODE
      "set(IMATH_IS_SUBPROJECT ON)"
      "set(IMATH_HALF_USE_LOOKUP_TABLE ON)"
      "set(IMATH_INSTALL_PKG_CONFIG ${ALICEVISION_INSTALL_THIRD_PARTY})"
)