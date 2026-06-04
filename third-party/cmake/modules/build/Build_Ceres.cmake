# =============================================================================
# Build_Ceres.cmake - Integrates an embedded Ceres into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

# We need to temporarily re-enable the CMAKE_FIND_USE_CMAKE_SYSTEM_PATH to
# allow Ceres finding Accelerate.framework

if(ALICEVISION_IGNORE_XCODE_PACKAGES AND APPLE)
  set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH ON)
endif()

# FIXME: Ceres currently does not use a release tag, because we need support
# for the newer CMakeLists.txt, which allows Eigen versions from 3.3 to 5.X.
# Remove once Ceres releases a new version which includes this patch.
alicevision_integrate_dependency(Ceres
    SUBMODULE_NAME "ceres-solver"
    CMAKE_EVAL_CODE
      # Ceres requires SuiteSparse::SPQR, which internally depends on
      # SuiteSparse::CHOLMOD with the Supernodal module, which is licensed
      # under GPL.
      # For Apple, SuiteSparse is disabled by default because Ceres can instead
      # utilize Accelerate.framework.
      "if(ALICEVISION_ALLOW_GPL AND (NOT APPLE OR ALICEVISION_SUITESPARSE_ON_APPLE))
        set(SUITESPARSE ON)
      else()
        set(SUITESPARSE OFF)
      endif()"
      "if(APPLE)
        set(ACCELERATESPARSE ON CACHE STRING \"\")
      else()
        set(ACCELERATESPARSE OFF CACHE STRING \"\")
      endif()"
      "set(USE_CUDA OFF CACHE STRING \"Enable use of CUDA linear algebra solvers.\")"
      "set(LAPACK ON)"
      "set(SCHUR_SPECIALIZATIONS ON)"
      "set(CUSTOM_BLAS ON)"
      "set(EIGENSPARSE ON)"
      "set(EIGENMETIS OFF)"   # So we do not depend on METIS
      "set(BUILD_TESTING OFF)"
      "set(BUILD_DOCUMENTATION OFF)"
      "set(BUILD_EXAMPLES OFF)"
      "set(BUILD_BENCHMARKS OFF)"
      "set(PROVIDE_UNINSTALL_TARGET ${ALICEVISION_INSTALL_THIRD_PARTY})"
      "set(ABSL_ENABLE_INSTALL ${ALICEVISION_INSTALL_THIRD_PARTY})"
)

# Turn system path off again
if(ALICEVISION_IGNORE_XCODE_PACKAGES AND APPLE)
  set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH OFF)
endif()
