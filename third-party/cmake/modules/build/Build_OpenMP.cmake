# =============================================================================
# Build_ZLIB.cmake - Integrates an embedded zlib into the project
#
# Special cases considered:
# - Creates the targets: OpenMP::OpenMP_C and OpenMP::OpenMP_CXX
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(OpenMP
    SUBMODULE_NAME "llvm-project"
    SOURCE_SUBDIR "openmp"
    CMAKE_EVAL_CODE
      "set(LIBOMP_FORTRAN_MODULES OFF)"
      "set(LIBOMP_FORTRAN_MODULES_ONLY OFF)"
      "set(OPENMP_ENABLE_LIBOMPTARGET OFF)"
      "set(OPENMP_ENABLE_OMPT_TOOLS OFF)"
      "set(OPENMP_STANDALONE_BUILD ON)"
      "set(LIBOMP_FORTRAN_MODULES_ONLY OFF)"

)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/OpenMPFlags.cmake)

if(NOT TARGET OpenMP::OpenMP_C)
  get_target_property(__av_omp_inc_dirs omp INCLUDE_DIRECTORIES)
  add_library(__av_omp_bind_c INTERFACE)
  target_link_libraries(__av_omp_bind_c INTERFACE omp)
  target_include_directories(__av_omp_bind_c INTERFACE ${__av_omp_inc_dirs})
  detect_openmp_flags(C __av_omp_flags_c ${__av_omp_inc_dirs})
  target_compile_options(__av_omp_bind_c INTERFACE ${__av_omp_flags_c})
  add_library(OpenMP::OpenMP_C ALIAS __av_omp_bind_c)
endif()

if(NOT TARGET OpenMP::OpenMP_CXX)
  get_target_property(__av_omp_inc_dirs omp INCLUDE_DIRECTORIES)
  add_library(__av_omp_bind_cxx INTERFACE)
  target_link_libraries(__av_omp_bind_cxx INTERFACE omp)
  target_include_directories(__av_omp_bind_cxx INTERFACE ${__av_omp_inc_dirs})
  detect_openmp_flags(C __av_omp_flags_cxx ${__av_omp_inc_dirs})
  target_compile_options(__av_omp_bind_cxx INTERFACE ${__av_omp_flags_cxx})
  add_library(OpenMP::OpenMP_CXX ALIAS __av_omp_bind_cxx)
endif()