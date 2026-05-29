# =============================================================================
# Build_Eigen.cmake - Integrates an embedded Eigen into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(Eigen
    SUBMODULE_NAME "eigen"
    CMAKE_EVAL_CODE
      "set(PROJECT_IS_TOP_LEVEL OFF)"
      "set(BUILD_TESTING OFF)"
      "set(EIGEN_BUILD_TESTING OFF)"
      "set(EIGEN_LEAVE_TEST_IN_ALL_TARGET OFF)"
      "set(EIGEN_BUILD_BLAS OFF)"
      "set(EIGEN_BUILD_LAPACK OFF)"
      "set(EIGEN_BUILD_DOC OFF)"
      "set(EIGEN_BUILD_DEMOS OFF)"
      "set(EIGEN_BUILD_PKGCONFIG ${ALICEVISION_INSTALL_THIRD_PARTY})"
      "set(EIGEN_BUILD_CMAKE_PACKAGE ${ALICEVISION_INSTALL_THIRD_PARTY})"
)