# =============================================================================
# EnsureDependency.cmake - Helps with finding or integrating a dependency into
# the project.
# =============================================================================

# =============================================================================
# Internal helper to build a find_package() argument list.
# - mode must be one of: CONFIG or MODULE
# - when mode == MODULE, we intentionally do NOT add NAMES (so module search can
#   work as expected, i.e. Find<Package>.cmake lookup)
# =============================================================================
function(_alicevision_build_find_package_args out_var dep_name mode version_req)

  set(_args "${dep_name}")

  # Append the version requirement, if any
  if(DEFINED version_req AND NOT version_req STREQUAL "")
    list(APPEND _args "${version_req}")
  endif()

  # We want it to be quiet
  if(NOT ALICEVISION_FIND_SYSTEM_DEPENDENCIES_VERBOSE)
    list(APPEND _args "QUIET")
  endif()

  if(mode STREQUAL "CONFIG")
    list(APPEND _args "CONFIG" "NO_MODULE")
  elseif(mode STREQUAL "MODULE")
    # Force module mode explicitly (requires CMake where MODULE mode is supported)
    list(APPEND _args "MODULE")
  else()
    message(FATAL_ERROR "Unknown find_package mode '${mode}'")
  endif()

  # We want it to be in global scope afterwards
  list(APPEND _args "GLOBAL")

  # Whether we need to append the components
  if(DEFINED AV_DEP_COMPONENTS AND NOT AV_DEP_COMPONENTS STREQUAL "")
    list(APPEND _args "COMPONENTS")
    foreach(_comp IN LISTS AV_DEP_COMPONENTS)
      list(APPEND _args "${_comp}")
    endforeach()
  endif()

  # If there are alternative package names given, use these as well
  # NOTE: only for CONFIG mode; MODULE mode must not use NAMES.
  if(mode STREQUAL "CONFIG" AND DEFINED AV_DEP_ALTERNATIVE_PACKAGE_NAMES)
    list(APPEND _args "NAMES")
    list(APPEND _args "${dep_name}")
    list(APPEND _args "${AV_DEP_ALTERNATIVE_PACKAGE_NAMES}")
  endif()

  set(${out_var} "${_args}" PARENT_SCOPE)

endfunction()

# =============================================================================
# A helper macro which temporarily adds certain prefix paths to allow CMake to
# find OpenMP correctly on macOS. The equivalent revert function must be called
# to ensure that the paths are not messed-up afterwards.
# For now we use the first version of OpenMP found (Homebrew > MacPorts),
# so it might be somewhat unpredictable if package-managers install multiple
# versions of OpenMP. Nix is currently unsupported.
# =============================================================================
macro(alicevision_push_appleclang_openmp)

  if(APPLE)

    set(AV_KNOWN_PACKAGE_MANAGER_PATHS
        "/opt/homebrew/Cellar/libomp"   # Apple Silicon Mac Homebrew (standalone OpenMP)
        "/usr/local/Cellar/libomp"      # Intel Mac Homebrew (standalone OpenMP)
        "/opt/local"                    # MacPorts (standalone)
    )

    # Whether the pop() function must remove a directory eventually
    set(AV_MUST_POP_PREFIX_PATH FALSE)

    foreach(AV_KNOWN_PACKAGE_MANAGER_PATH IN LISTS AV_KNOWN_PACKAGE_MANAGER_PATHS)

      # Skip if the prefix does not exist
      if(NOT EXISTS "${AV_KNOWN_PACKAGE_MANAGER_PATH}")
        message(TRACE "[alicevision_push_appleclang_openmp] Skipping non-existent prefix: ${AV_KNOWN_PACKAGE_MANAGER_PATH}")
        continue()
      endif()

      # Check if there is a lib and an include folder present directly
      if((EXISTS "${AV_KNOWN_PACKAGE_MANAGER_PATH}/lib/libomp.dylib"
          OR EXISTS "${AV_KNOWN_PACKAGE_MANAGER_PATH}/lib/libomp.a")
          AND EXISTS "${AV_KNOWN_PACKAGE_MANAGER_PATH}/include/omp.h")
        list(APPEND CMAKE_PREFIX_PATH ${AV_KNOWN_PACKAGE_MANAGER_PATH})
        set(AV_MUST_POP_PREFIX_PATH TRUE)
        message(TRACE "[alicevision_push_appleclang_openmp] Found OpenMP lib/include prefix: ${AV_KNOWN_PACKAGE_MANAGER_PATH}")
        break()
      endif()

      # If the above did not succeed, we will recursively glob files for a file
      # called omp.h. If one is found, we check if there is a accompanying .dylib
      # or .a file for the library.
      # If that is the case, the parent folder containing them is added to the
      # CMake prefix path
      message(TRACE "[alicevision_push_appleclang_openmp] Globbing known package manager prefix: ${AV_KNOWN_PACKAGE_MANAGER_PATH}")
      file(GLOB_RECURSE AV_OMP_H_FILES LIST_DIRECTORIES FALSE "${AV_KNOWN_PACKAGE_MANAGER_PATH}/**/omp.h")
      if(AV_OMP_H_FILES)
        foreach(AV_OMP_H_FILE_TEMP "${AV_OMP_H_FILES}")
          set(AV_OMP_H_FILE ${AV_OMP_H_FILE_TEMP})
          break()
        endforeach()
        if(NOT AV_OMP_H_FILE)
          continue()
        endif()
        cmake_path(GET AV_OMP_H_FILE PARENT_PATH AV_OMP_H_DIR)
        cmake_path(GET AV_OMP_H_DIR PARENT_PATH AV_OMP_PREFIX)
        message(TRACE "[alicevision_push_appleclang_openmp] Found an omp.h in: ${AV_OMP_H_DIR}")
        message(TRACE "[alicevision_push_appleclang_openmp] Checking for libomp.[a|dylib]: ${AV_OMP_PREFIX}")
        if(EXISTS "${AV_OMP_PREFIX}/lib/libomp.a" OR EXISTS "${AV_OMP_PREFIX}/lib/libomp.dylib")
          list(APPEND CMAKE_PREFIX_PATH ${AV_OMP_PREFIX})
          set(AV_MUST_POP_PREFIX_PATH TRUE)
          message(TRACE "[alicevision_push_appleclang_openmp] Found OpenMP lib/include prefix: ${AV_OMP_PREFIX}")
          break()
        endif()
      endif()

    endforeach()

    # Inform the user we prepended something
    if(AV_MUST_POP_PREFIX_PATH)
      list(LENGTH CMAKE_PREFIX_PATH AV_PREFIX_PATH_LEN)
      if(AV_PREFIX_PATH_LEN GREATER 0)
        math(EXPR AV_PREFIX_PATH_IDX "${AV_PREFIX_PATH_LEN}-1")
        list(GET CMAKE_PREFIX_PATH ${AV_PREFIX_PATH_IDX} AV_TEMP_PREFIX_PATH)
        if(AV_TEMP_PREFIX_PATH)
          message(VERBOSE "Added temporary prefix ${AV_TEMP_PREFIX_PATH} to CMAKE_PREFIX_PATH to allow CMake to find a package-manager OpenMP (macOS workaround).")
        endif()
      endif()
    endif()

  endif()

endmacro()

# =============================================================================
# The equivalent revert function for alicevision_push_appleclang_openmp()
# =============================================================================
macro(alicevision_pop_appleclang_openmp)

  if(APPLE)
    # Only remove if the push function added something
    if(AV_MUST_POP_PREFIX_PATH)
      list(LENGTH CMAKE_PREFIX_PATH AV_PREFIX_PATH_LEN)
      if(AV_PREFIX_PATH_LEN GREATER 0)
        math(EXPR AV_PREFIX_PATH_IDX "${AV_PREFIX_PATH_LEN}-1")
        list(GET CMAKE_PREFIX_PATH ${AV_PREFIX_PATH_IDX} AV_TEMP_PREFIX_PATH)
      endif()
      list(POP_BACK CMAKE_PREFIX_PATH)
      if(AV_TEMP_PREFIX_PATH)
        message(VERBOSE "Popped temporary prefix ${AV_TEMP_PREFIX_PATH} from CMAKE_PREFIX_PATH (macOS workaround).")
      endif()
    endif()
  endif()

endmacro()

# =============================================================================
# A helper function to ensure a dependency is available at the end of the call
#
# Call signature:
# alicevision_ensure_dependency(<DEPENDENCY_NAME>
#   [ALTERNATIVE_PACKAGE_NAMES <PACKAGE_NAME>...]
#   [VERSION <VERSION>]
#   [COMPONENTS <COMPONENTS...>]
#   [ALLOW_CMAKE_MODULE]
#   [LEGACY_SUPPORT_VERSION <VERSION>]
# )
# =============================================================================
function(alicevision_ensure_dependency AV_DEP_NAME)

  cmake_parse_arguments(AV_DEP
      "ALLOW_CMAKE_MODULE;NO_CONFIG"
      "LEGACY_SUPPORT_VERSION;VERSION"
      "COMPONENTS;ALTERNATIVE_PACKAGE_NAMES"
      ${ARGN}
  )

  # There must at least be a dependency name
  if(NOT DEFINED AV_DEP_NAME OR AV_DEP_NAME STREQUAL "")
    message(FATAL_ERROR "Must provide a dependency name to alicevision_ensure_dependency!")
  endif()

  # We must have a special handling for BLAS and LAPACK on macOS, if the build
  # is a universal build. OpenBLAS does not support a universal build and it is
  # likely never needed, because macOS provides its custom BLAS/LAPACK.
  set(AV_DEP_BLAS_LAPACK_SHORT_CIRCUIT OFF)
  if(AV_IS_APPLE_UNIVERSAL_BUILD
     AND (AV_DEP_NAME STREQUAL "BLAS" OR AV_DEP_NAME STREQUAL "LAPACK"))
    set(AV_DEP_BLAS_LAPACK_SHORT_CIRCUIT ON)
  endif()

  # Either we can look for all dependencies provided externally or the user
  # explicitly opted in for this specific dependency
  # Is forcibly overridden by ALICEVISION_FORCE_BUILD_<DEP_NAME>
  if(((ALICEVISION_ALLOW_SYSTEM_DEPENDENCIES
      OR ALICEVISION_ALLOW_SYSTEM_${AV_DEP_NAME})
      AND NOT ALICEVISION_FORCE_BUILD_${AV_DEP_NAME})
      OR AV_DEP_BLAS_LAPACK_SHORT_CIRCUIT
  )

    if(NOT AV_DEP_NO_CONFIG)
      # Pass 1: Prefer CONFIG mode (supports NAMES for alternative config package names).
      _alicevision_build_find_package_args(${AV_DEP_NAME}_FIND_PKG_ARGS "${AV_DEP_NAME}" "CONFIG" "${AV_DEP_VERSION}")
      message(TRACE "[alicevision_ensure_dependency] Trying to find dependency externally (CONFIG) with call: find_package(${${AV_DEP_NAME}_FIND_PKG_ARGS})")

      # We want to disable CMake Warning (dev) about case mismatches unless the
      # caller opted for a non-quiet search.
      if(NOT ALICEVISION_FIND_SYSTEM_DEPENDENCIES_VERBOSE)
        cmake_language(GET_MESSAGE_LOG_LEVEL AV_GLOBAL_LOG_LEVEL)
        set(CMAKE_MESSAGE_LOG_LEVEL "ERROR" CACHE STRING "The CMake Message log level" FORCE)
      endif()

      # Execute the call
      find_package(${${AV_DEP_NAME}_FIND_PKG_ARGS})
    endif()

    # Pass 2 (optional): If CONFIG lookup failed and caller allows it,
    # try MODULE-only lookup without NAMES (so Find<Package>.cmake can be found).
    string(TOUPPER ${AV_DEP_NAME} AV_DEP_NAME_UPPERCASE)
    if(AV_DEP_NO_CONFIG OR (NOT (${AV_DEP_NAME}_FOUND OR ${AV_DEP_NAME_UPPERCASE}_FOUND) AND AV_DEP_ALLOW_CMAKE_MODULE))
      _alicevision_build_find_package_args(${AV_DEP_NAME}_FIND_PKG_ARGS "${AV_DEP_NAME}" "MODULE" "${AV_DEP_VERSION}")
      message(TRACE "[alicevision_ensure_dependency] Trying to find dependency externally (MODULE) with call: find_package(${${AV_DEP_NAME}_FIND_PKG_ARGS})")
      find_package(${${AV_DEP_NAME}_FIND_PKG_ARGS})
    endif()

    if(NOT ALICEVISION_FIND_SYSTEM_DEPENDENCIES_VERBOSE)
      set(CMAKE_MESSAGE_LOG_LEVEL "${AV_GLOBAL_LOG_LEVEL}" CACHE STRING "The CMake Message log level" FORCE)
    endif()

    # Check if found, then we return early
    # Maybe the <DEP_NAME>_FOUND variable expects to be all uppercase, so check
    # for that as well
    if(${AV_DEP_NAME}_FOUND OR ${AV_DEP_NAME_UPPERCASE}_FOUND)

      # Version was in range
      if(DEFINED ${AV_DEP_NAME}_VERSION AND DEFINED AV_DEP_VERSION)
        message(STATUS "Found external ${AV_DEP_NAME}: ${${AV_DEP_NAME}_VERSION} (allowed version[s] are ${AV_DEP_VERSION})")
      elseif(DEFINED ${AV_DEP_NAME_UPPERCASE}_VERSION AND DEFINED AV_DEP_VERSION)
        message(STATUS "Found external ${AV_DEP_NAME}: ${${AV_DEP_NAME_UPPERCASE}_VERSION} (allowed version[s] are ${AV_DEP_VERSION})")
      else()
        if(DEFINED AV_DEP_VERSION)
          message(WARNING "Found external dependency ${AV_DEP_NAME}, but the version is unknown. Supported versions are ${AV_DEP_VERSION}, expect issues if the dependency cannot fulfill this!")
        else()
          if(DEFINED ${AV_DEP_NAME}_VERSION)
            message(STATUS "Found external ${AV_DEP_NAME}: ${${AV_DEP_NAME}_VERSION} (no version requirement)")
          elseif(DEFINED ${AV_DEP_NAME_UPPERCASE}_VERSION)
            message(STATUS "Found external ${AV_DEP_NAME}: ${${AV_DEP_NAME_UPPERCASE}_VERSION} (no version requirement)")
          else()
            message(STATUS "Found external ${AV_DEP_NAME}. (no version requirement)")
          endif()
        endif()
      endif()

      # Return early
      return()

    endif()

    # Normal version was not found, we can attempt to use the legacy compatbility version
    if(DEFINED AV_DEP_LEGACY_SUPPORT_VERSION)

      # Legacy pass 1: Prefer CONFIG mode (supports NAMES).
      _alicevision_build_find_package_args(${AV_DEP_NAME}_FIND_PKG_ARGS "${AV_DEP_NAME}" "CONFIG" "${AV_DEP_LEGACY_SUPPORT_VERSION}")
      message(TRACE "[alicevision_ensure_dependency] Trying to find legacy dependency externally (CONFIG) with call: find_package(${${AV_DEP_NAME}_FIND_PKG_ARGS})")

      # We want to disable CMake Warning (dev) about case mismatches unless the
      # caller opted for a non-quiet search.
      if(NOT ALICEVISION_FIND_SYSTEM_DEPENDENCIES_VERBOSE)
        cmake_language(GET_MESSAGE_LOG_LEVEL AV_GLOBAL_LOG_LEVEL)
        set(CMAKE_MESSAGE_LOG_LEVEL "ERROR" CACHE STRING "The CMake Message log level" FORCE)
      endif()

      # Execute the call
      find_package(${${AV_DEP_NAME}_FIND_PKG_ARGS})

      # Legacy pass 2 (optional): MODULE-only lookup without NAMES.
      string(TOUPPER ${AV_DEP_NAME} AV_DEP_NAME_UPPERCASE)
      if(NOT (${AV_DEP_NAME}_FOUND OR ${AV_DEP_NAME_UPPERCASE}_FOUND) AND AV_DEP_ALLOW_CMAKE_MODULE)
        _alicevision_build_find_package_args(${AV_DEP_NAME}_FIND_PKG_ARGS "${AV_DEP_NAME}" "MODULE" "${AV_DEP_LEGACY_SUPPORT_VERSION}")
        message(TRACE "[alicevision_ensure_dependency] Trying to find legacy dependency externally (MODULE) with call: find_package(${${AV_DEP_NAME}_FIND_PKG_ARGS})")
        find_package(${${AV_DEP_NAME}_FIND_PKG_ARGS})
      endif()

      if(NOT ALICEVISION_FIND_SYSTEM_DEPENDENCIES_VERBOSE)
        set(CMAKE_MESSAGE_LOG_LEVEL "${AV_GLOBAL_LOG_LEVEL}" CACHE STRING "The CMake Message log level" FORCE)
      endif()

      # Check if found, then we return early
      # Maybe the <DEP_NAME>_FOUND variable expects to be all uppercase, so check
      # for that as well
      if(${AV_DEP_NAME}_FOUND OR ${AV_DEP_NAME_UPPERCASE}_FOUND)

        # Version was in range
        if(DEFINED ${AV_DEP_NAME}_VERSION AND DEFINED AV_DEP_VERSION)
          message(WARNING "Found external legacy ${AV_DEP_NAME}: ${${AV_DEP_NAME}_VERSION} (allowed version[s] are ${AV_DEP_VERSION}, ${AV_DEP_LEGACY_SUPPORT_VERSION} for legacy compatibility). Consider updating this dependency!")
        elseif(DEFINED ${AV_DEP_NAME_UPPERCASE}_VERSION AND DEFINED AV_DEP_VERSION)
          message(WARNING "Found external legacy ${AV_DEP_NAME}: ${${AV_DEP_NAME_UPPERCASE}_VERSION} (allowed version[s] are ${AV_DEP_VERSION}, ${AV_DEP_LEGACY_SUPPORT_VERSION} for legacy compatibility). Consider updating this dependency!")
        else()
          if(DEFINED AV_DEP_VERSION)
            message(WARNING "Found external dependency ${AV_DEP_NAME}, but the version is unknown. Supported versions are ${AV_DEP_LEGACY_SUPPORT_VERSION}, expect issues if the dependency cannot fulfill this!")
          else()
            if(DEFINED ${AV_DEP_NAME}_VERSION)
              message(STATUS "Found external ${AV_DEP_NAME}: ${${AV_DEP_NAME}_VERSION} (no version requirement)")
            elseif(DEFINED ${AV_DEP_NAME_UPPERCASE}_VERSION)
              message(STATUS "Found external ${AV_DEP_NAME}: ${${AV_DEP_NAME_UPPERCASE}_VERSION} (no version requirement)")
            else()
              message(STATUS "Found external ${AV_DEP_NAME}. (no version requirement)")
            endif()
          endif()
        endif()

        # Return early
        return()

      endif()

    endif()

  endif()

  # Not found or no external package allowed
  # We might be allowed to build it
  if(ALICEVISION_BUILD_THIRD_PARTY OR ALICEVISION_FORCE_BUILD_${AV_DEP_NAME})
    message(STATUS "Dependency ${AV_DEP_NAME} will be built from source.")
    # Include the build helper file
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/build/Build_${AV_DEP_NAME}.cmake)

    # We try to find it again (must be included by now) without any standard
    # ways CMake provides. This should redirect to the pkgRedirects directory.
    # If the <AV_DEP_NAME>_FOUND variable is still FALSE, there is some deeper
    # issue which is likely a bug. Catch it early here.
    find_package(${AV_DEP_NAME}
        QUIET
        CONFIG
        NO_MODULE
        NO_CMAKE_BUILDS_PATH
        NO_CMAKE_ENVIRONMENT_PATH
        NO_CMAKE_FIND_ROOT_PATH
        NO_CMAKE_INSTALL_PREFIX
        NO_CMAKE_PACKAGE_REGISTRY
        NO_CMAKE_PATH
        NO_CMAKE_SYSTEM_PACKAGE_REGISTRY
        NO_CMAKE_SYSTEM_PATH
        NO_DEFAULT_PATH
        NO_PACKAGE_ROOT_PATH
    )
    if(NOT ${AV_DEP_NAME}_FOUND)
      message(FATAL_ERROR "After adding ${AV_DEP_NAME} with FetchContent, a call to find_package() still leaves ${AV_DEP_NAME}_FOUND as FALSE. This is likely a bug!")
    endif()

    return()
  endif()

  # If we got here neither the external nor the embedded way were allowed
  # This is quasi an unreachable scenario because there is no way to get
  # the dependency now.
  message(FATAL_ERROR "The dependency ${AV_DEP_NAME} cannot be resolved because it may not be found externally and not be built (unreachable dependency)!")

endfunction()
