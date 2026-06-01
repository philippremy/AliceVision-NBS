# =============================================================================
# Build_SuiteSparse.cmake - Integrates an embedded SuiteSparse into the project
#
# Special cases considered:
# - Create target SuiteSparse::Config, if it does not exist. Ceres exepcts this
# target name instead of SuiteSparse::SuiteSparseConfig
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

set(AV_SuiteSparse_CMAKE_OPTIONS
    "set(SUITESPARSE_ENABLE_PROJECTS
          suitesparse_config
          amd
          camd
          ccolamd
          cholmod
          colamd
          spqr
      )"
    "set(SUITESPARSE_USE_CUDA OFF)"   # This does not have any advantage for our use case
    "set(BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})"
    "set(BUILD_STATIC_LIBS ${BUILD_STATIC_LIBS})"
    "set(SUITESPARSE_USE_64BIT_BLAS OFF)"   # Could technically be changed, but our embedded OpenBLAS is 32-bit
    "set(SUITESPARSE_USE_PYTHON OFF)"
    "set(SUITESPARSE_USE_OPENMP ON)"
    # OpenBLAS always uses the underscore name mangling
    # The only exception is when an Intel Fortran Compiler is used in
    # conjunction with MSVC.
    # Because there might be issues, if the Fortran code was compiled with a
    # different compiler, we disable Fortran (it is not required).
    "set(SUITESPARSE_USE_FORTRAN OFF)"
    "set(SUITESPARSE_C_TO_FORTRAN \"(name,NAME) name##_\")"
    "set(CHOLMOD_GPL ON)"  # Required, because the Supernodal module is required by SPQR (and in turn by Ceres)
    "set(CHOLMOD_PARTITION ON)"
    "set(CHOLMOD_CAMD ON)"
    "set(SUITESPARSE_LOCAL_INSTALL ${ALICEVISION_INSTALL_THIRD_PARTY})"
    "set(SUITESPARSE_DEMOS OFF)"
)

# We must switch on whether we build an embedded BLAS, because otherwise
# SuiteSparse attempts to compile and run a test program with BLAS, which is
# not available yet and fails.
# We will patch this case. Otherwise it can proceed to try compiling this.
if(DEFINED AV_BLAS_IS_EMBEDDED AND AV_BLAS_IS_EMBEDDED)
  alicevision_integrate_dependency(SuiteSparse
      PATCH_STEP
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/build/patch/SuiteSparse-TryCompileBLAS-ExportTargets.patch"
      CMAKE_EVAL_CODE
      ${AV_SuiteSparse_CMAKE_OPTIONS}
  )
else()
  alicevision_integrate_dependency(SuiteSparse
      CMAKE_EVAL_CODE
        ${AV_SuiteSparse_CMAKE_OPTIONS}
  )
endif()