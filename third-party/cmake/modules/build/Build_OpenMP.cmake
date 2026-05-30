# =============================================================================
# Build_OpenMP.cmake - Integrates an embedded OpenMP into the project
#
# Special cases considered:
# - Creates the targets: OpenMP::OpenMP_C and OpenMP::OpenMP_CXX
# - Sets the following variables (per the FindOpenMP.cmake module)
#   OpenMP_FOUND: ON
#   OpenMP_VERSION: 5.1
#   OpenMP_C_VERSION: 5.1
#   OpenMP_CXX_VERSION: 5.1
#   OpenMP_C_VERSION_MAJOR: 5
#   OpenMP_CXX_VERSION_MAJOR: 5
#   OpenMP_C_VERSION_MINOR: 1
#   OpenMP_CXX_VERSION_MINOR: 1
#   OpenMP_C_SPEC_DATE: 202011
#   OpenMP_CXX_SPEC_DATE: 202011
#   OpenMP_C_FLAGS: <COMPILER_SPECIFIC>
#   OpenMP_CXX_FLAGS: <COMPILER_SPECIFIC>
#   OpenMP_C_INCLUDE_DIRS: <TARGET_INCLUDE_DIRS>
#   OpenMP_CXX_INCLUDE_DIRS: <TARGET_INCLUDE_DIRS>
#   OpenMP_C_LIBRARIES: OpenMP::OpenMP_C
#   OpenMP_CXX_LIBRARIES: OpenMP::OpenMP_CXX
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
      "if(BUILD_STATIC_LIBS AND NOT WIN32)
        set(LIBOMP_ENABLE_SHARED OFF)
      else()
        set(LIBOMP_ENABLE_SHARED ON)
      endif()"
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
  detect_openmp_flags(CXX __av_omp_flags_cxx ${__av_omp_inc_dirs})
  target_compile_options(__av_omp_bind_cxx INTERFACE ${__av_omp_flags_cxx})
  add_library(OpenMP::OpenMP_CXX ALIAS __av_omp_bind_cxx)
endif()

# OpenMP cache variables
set(OpenMP_FOUND ON CACHE BOOL "Whether OpenMP was found" FORCE)

set(OpenMP_VERSION "5.1" CACHE STRING "OpenMP version" FORCE)

set(OpenMP_C_VERSION "5.1" CACHE STRING "OpenMP C version" FORCE)
set(OpenMP_CXX_VERSION "5.1" CACHE STRING "OpenMP CXX version" FORCE)

set(OpenMP_C_VERSION_MAJOR "5" CACHE STRING "OpenMP C version major" FORCE)
set(OpenMP_CXX_VERSION_MAJOR "5" CACHE STRING "OpenMP CXX version major" FORCE)

set(OpenMP_C_VERSION_MINOR "1" CACHE STRING "OpenMP C version minor" FORCE)
set(OpenMP_CXX_VERSION_MINOR "1" CACHE STRING "OpenMP CXX version minor" FORCE)

set(OpenMP_C_SPEC_DATE "202011" CACHE STRING "OpenMP C spec date" FORCE)
set(OpenMP_CXX_SPEC_DATE "202011" CACHE STRING "OpenMP CXX spec date" FORCE)

if(TARGET OpenMP::OpenMP_C)
  get_target_property(__av_omp_inc_dirs OpenMP::OpenMP_C INTERFACE_INCLUDE_DIRECTORIES)
  detect_openmp_flags(C __av_omp_flags_c ${__av_omp_inc_dirs})
  set(OpenMP_C_FLAGS "${__av_omp_flags_c}" CACHE STRING "OpenMP C compile flags" FORCE)
  set(OpenMP_C_INCLUDE_DIRS "${__av_omp_inc_dirs}" CACHE STRING "OpenMP C include dirs" FORCE)
endif()

if(TARGET OpenMP::OpenMP_CXX)
  get_target_property(__av_omp_inc_dirs OpenMP::OpenMP_CXX INTERFACE_INCLUDE_DIRECTORIES)
  detect_openmp_flags(CXX __av_omp_flags_cxx ${__av_omp_inc_dirs})
  set(OpenMP_CXX_FLAGS "${__av_omp_flags_cxx}" CACHE STRING "OpenMP CXX compile flags" FORCE)
  set(OpenMP_CXX_INCLUDE_DIRS "${__av_omp_inc_dirs}" CACHE STRING "OpenMP CXX include dirs" FORCE)
endif()

set(OpenMP_C_LIBRARIES OpenMP::OpenMP_C CACHE STRING "OpenMP C libraries/target" FORCE)
set(OpenMP_CXX_LIBRARIES OpenMP::OpenMP_CXX CACHE STRING "OpenMP CXX libraries/target" FORCE)