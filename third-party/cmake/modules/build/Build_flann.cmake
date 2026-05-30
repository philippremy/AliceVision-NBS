# =============================================================================
# Build_flann.cmake - Integrates an embedded flann into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(flann
    PATCH_STEP
      "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/build/patch/flann-cmake.patch"
    CMAKE_EVAL_CODE
      "set(BUILD_C_BINDINGS OFF)"
      "set(BUILD_PYTHON_BINDINGS OFF)"
      "set(BUILD_MATLAB_BINDINGS OFF)"
      "set(BUILD_CUDA_LIB OFF)"
      "set(BUILD_EXAMPLES OFF)"
      "set(BUILD_TESTS OFF)"
      "set(BUILD_DOC OFF)"
      "set(USE_OPENMP ON)"
      "set(USE_MPI OFF)"
      "set(HDF5_FOUND OFF)"
      "set(HDF5_IS_PARALLEL OFF)"
)
