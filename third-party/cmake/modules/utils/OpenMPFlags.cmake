# =============================================================================
# OpenMPFlags.cmake - Finds out the required flags for enabling OpenMP with the
# current compiler.
#
# This file is copied from the base CMake FindOpenMP.cmake module
#
# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.md or https://cmake.org/licensing for details.
#
# Minimal extraction from CMake's FindOpenMP module: detect the *compiler
# flag(s)* needed to enable OpenMP for a given language, and return them in an
# output var.
#
# Minimal extraction from CMake's FindOpenMP module: detect the *compiler
# flag(s)* needed to enable OpenMP for a given language, and return them
# in an output var.
#
# This intentionally ignores everything else (version, include dirs, implicit libs, etc.).
#
# Usage example:
#   detect_openmp_flags(CXX OpenMP_CXX_FLAGS "")  # no extra include dirs
#
# Notes:
# - The output is either a flag string (e.g. "-fopenmp") or "NOTFOUND".
# - Detection uses try_compile, but is configured to avoid the final link step by
#   compiling an OBJECT library (STATIC_LIBRARY target type).
# =============================================================================

cmake_policy(PUSH)
cmake_policy(SET CMP0159 NEW) # file(STRINGS) with REGEX updates CMAKE_MATCH_<n>

# --- Candidate flag selection (extracted from upstream _OPENMP_FLAG_CANDIDATES) ---
function(_openmp_flag_candidates LANG out_var)
  set(OMP_FLAG_GNU "-fopenmp")
  set(OMP_FLAG_LCC "-fopenmp")
  set(OMP_FLAG_Clang "-fopenmp=libomp" "-fopenmp=libiomp5" "-fopenmp" "-Xclang -fopenmp")
  set(OMP_FLAG_AppleClang "-Xclang -fopenmp")
  set(OMP_FLAG_HP "+Oopenmp")

  if(WIN32)
    set(OMP_FLAG_Intel "-Qopenmp")
  elseif(CMAKE_${LANG}_COMPILER_ID STREQUAL "Intel" AND
      "${CMAKE_${LANG}_COMPILER_VERSION}" VERSION_LESS "15.0.0.20140528")
    set(OMP_FLAG_Intel "-openmp")
  else()
    set(OMP_FLAG_Intel "-qopenmp")
  endif()

  if(CMAKE_${LANG}_COMPILER_ID STREQUAL "IntelLLVM" AND
      "x${CMAKE_${LANG}_COMPILER_FRONTEND_VARIANT}" STREQUAL "xMSVC")
    set(OMP_FLAG_IntelLLVM "-Qiopenmp")
  else()
    set(OMP_FLAG_IntelLLVM "-fiopenmp")
  endif()

  if(OpenMP_RUNTIME_MSVC)
    set(OMP_FLAG_MSVC "-openmp:${OpenMP_RUNTIME_MSVC}")
  else()
    set(OMP_FLAG_MSVC "-openmp")
  endif()

  set(OMP_FLAG_PathScale "-openmp")
  set(OMP_FLAG_NAG "-openmp")
  set(OMP_FLAG_Absoft "-openmp")
  set(OMP_FLAG_NVHPC "-mp")
  set(OMP_FLAG_PGI "-mp")
  set(OMP_FLAG_Flang "-fopenmp")
  set(OMP_FLAG_LLVMFlang "-fopenmp")
  set(OMP_FLAG_SunPro "-xopenmp")
  set(OMP_FLAG_XL "-qsmp=omp")
  set(OMP_FLAG_Cray " " "-h omp") # upstream: " " means "no flag"
  set(OMP_FLAG_CrayClang "-fopenmp")
  set(OMP_FLAG_Fujitsu "-Kopenmp" "-KOMP")
  set(OMP_FLAG_FujitsuClang "-fopenmp" "-Kopenmp")

  if(CMAKE_${LANG}_COMPILER_ID STREQUAL "NVIDIA" AND CMAKE_${LANG}_HOST_COMPILER_ID)
    set(compiler_id "${CMAKE_${LANG}_HOST_COMPILER_ID}")
  else()
    set(compiler_id "${CMAKE_${LANG}_COMPILER_ID}")
  endif()

  if(DEFINED OMP_FLAG_${compiler_id})
    set(${out_var} "${OMP_FLAG_${compiler_id}}" PARENT_SCOPE)
  else()
    set(${out_var} "-openmp" "-fopenmp" "-mp" " " PARENT_SCOPE)
  endif()
endfunction()

# --- Prepare test source (extracted from upstream, but trimmed to just what's needed) ---
function(_openmp_prepare_source LANG out_name out_content)
  set(OpenMP_C_CXX_TEST_SOURCE
      "
#include <omp.h>
int main(void) {
#ifdef _OPENMP
  omp_get_max_threads();
#elif !defined(__CUDA_ARCH__) && !defined(__HIP_DEVICE_COMPILE__)
#  error \"_OPENMP not defined!\"
#endif
  return 0;
}
")
  if("${LANG}" STREQUAL "C")
    set(${out_name} "OpenMPTryFlag.c" PARENT_SCOPE)
    set(${out_content} "${OpenMP_C_CXX_TEST_SOURCE}" PARENT_SCOPE)
  elseif("${LANG}" STREQUAL "CXX")
    set(${out_name} "OpenMPTryFlag.cpp" PARENT_SCOPE)
    set(${out_content} "${OpenMP_C_CXX_TEST_SOURCE}" PARENT_SCOPE)
  elseif("${LANG}" STREQUAL "CUDA")
    set(${out_name} "OpenMPTryFlag.cu" PARENT_SCOPE)
    set(${out_content} "${OpenMP_C_CXX_TEST_SOURCE}" PARENT_SCOPE)
  elseif("${LANG}" STREQUAL "Fortran")
    set(OpenMP_Fortran_TEST_SOURCE
        "
      program test
      @OpenMP_Fortran_INCLUDE_LINE@
  !$  integer :: n
      n = omp_get_num_threads()
      end program test
  "
    )
    set(OpenMP_Fortran_INCLUDE_LINE "use omp_lib\n      implicit none")
    string(CONFIGURE "${OpenMP_Fortran_TEST_SOURCE}" _content @ONLY)
    set(${out_name} "OpenMPTryFlag.F90" PARENT_SCOPE)
    set(${out_content} "${_content}" PARENT_SCOPE)
  else()
    message(FATAL_ERROR "detect_openmp_flags: unsupported LANG='${LANG}'. Use C, CXX, CUDA, or Fortran.")
  endif()
endfunction()

# --- Public API ---
#
# detect_openmp_flags(
#   <LANG>
#   <OUT_FLAGS_VAR>
#   <VAR1_INCLUDE_DIRS>
# )
#
# - LANG: C, CXX, CUDA, Fortran
# - OUT_FLAGS_VAR: name of variable to set in caller scope
# - VAR1_INCLUDE_DIRS: input: include dirs to help find headers/modules (can be "" to skip)
#
function(detect_openmp_flags LANG OUT_FLAGS_VAR VAR1)
  if(NOT CMAKE_${LANG}_COMPILER_LOADED)
    set(${OUT_FLAGS_VAR} "NOTFOUND" PARENT_SCOPE)
    return()
  endif()

  _openmp_flag_candidates("${LANG}" _openmp_candidates)
  _openmp_prepare_source("${LANG}" _src_name _src_content)

  unset(_includeDirFlags)
  if(NOT "${VAR1}" STREQUAL "")
    set(_includeDirFlags "-DINCLUDE_DIRECTORIES:STRING=${VAR1}")
  endif()

  foreach(_flag IN LISTS _openmp_candidates)
    string(REGEX REPLACE "[-/=+]" "" _plain_flag "${_flag}")

    # IMPORTANT: Avoid linking. This is the main change vs the previous version.
    #
    # try_compile() still performs a "compile + archive" step for STATIC_LIBRARY.
    # It does *not* link an executable, which avoids the final link stage.
    set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
    try_compile(_ok_${_plain_flag}
        SOURCE_FROM_VAR "${_src_name}" _src_content
        LOG_DESCRIPTION "Detecting ${LANG} OpenMP flag (compile-only via object/static library)"
        CMAKE_FLAGS
        "-DCOMPILE_DEFINITIONS:STRING=${_flag}"
        ${_includeDirFlags}
        "-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY"
        OUTPUT_VARIABLE _try_output
    )

    if(_ok_${_plain_flag})
      # Keep the upstream clang-cl guard: it can compile but may not truly be usable without extra lib handling.
      # Since we now avoid linking entirely, this guard remains important to keep behavior close to upstream.
      if(NOT "${CMAKE_${LANG}_COMPILER_ID};${CMAKE_${LANG}_SIMULATE_ID}" STREQUAL "Clang;MSVC")
        # If multiple arguments are specified, they must be turned from a string into a list
        string(REGEX REPLACE "[ \t]+" ";" _list "${_flag}")
        set(${OUT_FLAGS_VAR} ${_list} PARENT_SCOPE)
        return()
      endif()
    endif()
  endforeach()

  # For Fortran: upstream tries module form and header form. Reproduce that behavior.
  if("${LANG}" STREQUAL "Fortran")
    set(OpenMP_Fortran_TEST_SOURCE
        "
      program test
      @OpenMP_Fortran_INCLUDE_LINE@
  !$  integer :: n
      n = omp_get_num_threads()
      end program test
  "
    )
    set(OpenMP_Fortran_INCLUDE_LINE "implicit none\n      include 'omp_lib.h'")
    string(CONFIGURE "${OpenMP_Fortran_TEST_SOURCE}" _src_content2 @ONLY)
    set(_src_name2 "OpenMPTryFlag2.F90")

    foreach(_flag IN LISTS _openmp_candidates)
      string(REGEX REPLACE "[-/=+]" "" _plain_flag "${_flag}")

      try_compile(_ok2_${_plain_flag}
          SOURCE_FROM_VAR "${_src_name2}" _src_content2
          LOG_DESCRIPTION "Detecting Fortran OpenMP flag (omp_lib.h form, compile-only)"
          CMAKE_FLAGS
          "-DCOMPILE_DEFINITIONS:STRING=${_flag}"
          ${_includeDirFlags}
          "-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY"
          OUTPUT_VARIABLE _try_output2
      )

      if(_ok2_${_plain_flag})
        # If multiple arguments are specified, they must be turned from a string into a list
        string(REGEX REPLACE "[ \t]+" ";" _list "${_flag}")
        set(${OUT_FLAGS_VAR} "${_list}" PARENT_SCOPE)
        return()
      endif()
    endforeach()
  endif()

  set(${OUT_FLAGS_VAR} "NOTFOUND" PARENT_SCOPE)
endfunction()

cmake_policy(POP)