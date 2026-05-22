# =============================================================================
# This CMakeLists.txt exists for the purpose of building embedded dependencies
# for AliceVision.
#
# The reason for this is to split the third-party projects from the main
# project, especially to set dependency-specific settings without affecting the
# global project settings.
#
# The following changes are made specifically for the third-party projects:
#
# ALICEVISION_BUILD_THIRD_PARTY: If ON, CMake will build required dependencies
#                                from source (through FetchContent).
# ALICEVISION_FORCE_BUILD_<DEP_NAME>: If ON, CMake will build the dependency
#                                     <DEP_NAME> from source (through
#                                     FetchContent) and ensures no external
#                                     package will be used (overrides
#                                     ALICEVISION_ALLOW_SYSTEM_DEPENDENCIES and
#                                     ALICEVISION_ALLOW_SYSTEM_<DEP_NAME> for
#                                     the dependency <DEP_NAME>).
# ALICEVISION_INSTALL_THIRD_PARTY: If ON, CMake will generate install rules for
#                                  the third-party projects (DEFAULT: OFF)
# ALICEVISION_ALLOW_SYSTEM_DEPENDENCIES: If ON, CMake will first try to satisfy
#                                        all dependency through system-provided
#                                        ones (i.e., call find_package()).
# ALICEVISION_ALLOW_SYSTEM_<DEP_NAME>: If ON, CMake will first try to satisfy
#                                      the dependency <DEP_NAME> though a
#                                      system-provided one (i.e., call
#                                      find_package()).
# ALICEVISION_PRINT_THIRD_PARTY_WARNINGS: If ON, CMake will not prevent the
#                                         compiler from emitting warning
#                                         messages for third-party projects
#                                         (only MSVC/GNU/Clang-compatible
#                                         compilers are supported).
# ALICEVISION_DO_AS_I_SAY: If ON, CMake will not prevent some scenarios that
#                          might break the system. An example would be to
#                          install third-party projects into a system prefix
#                          (which could silently overwrite package-manager
#                          provided packages).
# =============================================================================

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
#   [VERSION <VERSION>|<VERSION_RANGE>]
#   [COMPONENTS <COMPONENTS...>]
#   [ALLOW_CMAKE_MODULE]
#   [LEGACY_SUPPORT_VERSION <VERSION>|<VERSION_RANGE>]
# )
# =============================================================================
function(alicevision_ensure_dependency AV_DEP_NAME)

  cmake_parse_arguments(AV_DEP
    "ALLOW_CMAKE_MODULE;FORCE_FIND_PKG_VERSION"
    "LEGACY_SUPPORT_VERSION;VERSION"
    "COMPONENTS;ALTERNATIVE_PACKAGE_NAMES"
    ${ARGN}
  )

  # There must at least be a dependency name
  if(NOT DEFINED AV_DEP_NAME OR AV_DEP_NAME STREQUAL "")
    message(FATAL_ERROR "Must provide a dependency name to alicevision_ensure_dependency!")
  endif()

  # Either we can look for all dependencies provided externally or the user
  # explicitly opted in for this specific dependency
  # Is forcibly overridden by ALICEVISION_FORCE_BUILD_<DEP_NAME>
  if((ALICEVISION_ALLOW_SYSTEM_DEPENDENCIES
     OR ALICEVISION_ALLOW_SYSTEM_${AV_DEP_NAME})
     AND NOT ALICEVISION_FORCE_BUILD_${AV_DEP_NAME}
  )

    # Build the find_package() call
    # We only use the main package name here!
    set(${AV_DEP_NAME}_FIND_PKG_ARGS "${AV_DEP_NAME}")

    # We want it to be quiet
    if(NOT ALICEVISION_FIND_SYSTEM_DEPENDENCIES_VERBOSE)
      list(APPEND ${AV_DEP_NAME}_FIND_PKG_ARGS "QUIET")
    endif()

    # Whether to allow CMake Find* modules
    if(AV_DEP_ALLOW_CMAKE_MODULE)
      # Nothing, module is allowed by default
    else()
      list(APPEND ${AV_DEP_NAME}_FIND_PKG_ARGS "CONFIG;NO_MODULE")
    endif()

    # We want it to be in global scope afterwards
    list(APPEND ${AV_DEP_NAME}_FIND_PKG_ARGS "GLOBAL")

    # Whether we need to append the components
    if(DEFINED AV_DEP_COMPONENTS AND NOT AV_DEP_COMPONENTS STREQUAL "")
      list(APPEND ${AV_DEP_NAME}_FIND_PKG_ARGS "COMPONENTS")
      foreach(AV_DEP_COMPONENT IN LISTS AV_DEP_COMPONENTS)
        list(APPEND ${AV_DEP_NAME}_FIND_PKG_ARGS "${AV_DEP_COMPONENT}")
      endforeach()
    endif()

    # If there are alternative package names given, use these as well
    if(DEFINED AV_DEP_ALTERNATIVE_PACKAGE_NAMES)
      list(APPEND ${AV_DEP_NAME}_FIND_PKG_ARGS "NAMES")
      # The main package name should be first
      list(APPEND ${AV_DEP_NAME}_FIND_PKG_ARGS "${AV_DEP_NAME}")
      list(APPEND ${AV_DEP_NAME}_FIND_PKG_ARGS "${AV_DEP_ALTERNATIVE_PACKAGE_NAMES}")
    endif()

    message(TRACE "[alicevision_ensure_dependency] Trying to find dependency externally with call: find_package(${${AV_DEP_NAME}_FIND_PKG_ARGS})")

    # We want to disable CMake Warning (dev) about case mismatches unless the
    # caller opted for a non-quiet search.
    if(NOT ALICEVISION_FIND_SYSTEM_DEPENDENCIES_VERBOSE)
      cmake_language(GET_MESSAGE_LOG_LEVEL AV_GLOBAL_LOG_LEVEL)
      set(CMAKE_MESSAGE_LOG_LEVEL "ERROR" CACHE STRING "The CMake Message log level" FORCE)
    endif()

    # Execute the call
    find_package(${${AV_DEP_NAME}_FIND_PKG_ARGS})

    if(NOT ALICEVISION_FIND_SYSTEM_DEPENDENCIES_VERBOSE)
      set(CMAKE_MESSAGE_LOG_LEVEL "${AV_GLOBAL_LOG_LEVEL}" CACHE STRING "The CMake Message log level" FORCE)
    endif()

    # Check if found, then we return early
    # Maybe the <DEP_NAME>_FOUND variable expects to be all uppercase, so check
    # for that as well
    string(TOUPPER ${AV_DEP_NAME} AV_DEP_NAME_UPPERCASE)
    if(${AV_DEP_NAME}_FOUND OR ${AV_DEP_NAME_UPPERCASE}_FOUND)
      set(AV_DEP_ACTUAL_VERSION)
      if(DEFINED ${AV_DEP_NAME}_VERSION)
        set(AV_DEP_ACTUAL_VERSION ${${AV_DEP_NAME}_VERSION})
      elseif(DEFINED ${AV_DEP_NAME_UPPERCASE}_VERSION)
        set(AV_DEP_ACTUAL_VERSION ${${AV_DEP_NAME_UPPERCASE}_VERSION})
      else()
        # No version available, emit a warning if we needed one
        if(DEFINED AV_DEP_VERSION)
          message(WARNING "Found dependency ${AV_DEP_NAME} without a version number but required was at least ${AV_DEP_VERSION}. It might work, please check the versions and expect issues if the version does not match the requirement.")
          message(STATUS "Found external ${AV_DEP_NAME}: N/A (version[s] ${AV_DEP_VERSION} supported)")
          return()
        else()
          message(STATUS "Found external ${AV_DEP_NAME}: N/A (all versions supported)")
          return()
        endif()
      endif()

      # No version specified, all versions are accepted
      if(NOT DEFINED AV_DEP_VERSION)
        message(STATUS "Found external ${AV_DEP_NAME}: ${AV_DEP_ACTUAL_VERSION} (all versions supported)")
        return()
      endif()

      # Ensure version compatibility explicitly
      include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/CheckDependencyVersion.cmake)
      alicevision_check_dependency_version(${AV_DEP_VERSION} ${AV_DEP_ACTUAL_VERSION} AV_DEP_VERSION_COMPATIBLE)
      if(AV_DEP_VERSION_COMPATIBLE)
        # Check if we are in a support version range, then emit a warning
        if(DEFINED AV_DEP_LEGACY_SUPPORT_VERSION)
          alicevision_check_dependency_version(${AV_DEP_LEGACY_SUPPORT_VERSION} ${AV_DEP_ACTUAL_VERSION} AV_DEP_VERSION_LEGACY_RANGE)
          if(AV_DEP_VERSION_LEGACY_RANGE)
            message(WARNING "Found external dependency ${AV_DEP_NAME} with legacy compatibility version ${AV_DEP_ACTUAL_VERSION}. Support is provided for backwards compatibility, other dependencies might require a newer version. Consider setting ${AV_DEP_NAME}_ROOT/${AV_DEP_NAME}_DIR if you have multiple versions installed and the wrong one is being found or update the dependency.")
          endif()
          message(STATUS "Found external ${AV_DEP_NAME}: ${AV_DEP_ACTUAL_VERSION} (version[s] ${AV_DEP_VERSION} supported, compat version[s] ${AV_DEP_LEGACY_SUPPORT_VERSION} supported)")
          return()
        else()
          message(STATUS "Found external ${AV_DEP_NAME}: ${AV_DEP_ACTUAL_VERSION} (version[s] ${AV_DEP_VERSION} supported)")
          return()
        endif()
      else()
        # Version is not compatible
        if(DEFINED AV_DEP_LEGACY_SUPPORT_VERSION)
          message(STATUS "Found external ${AV_DEP_NAME}, but the version is not in range: ${AV_DEP_ACTUAL_VERSION} (version[s] ${AV_DEP_VERSION} supported, compat version[s] ${AV_DEP_LEGACY_SUPPORT_VERSION} supported)")
        else()
          message(STATUS "Found external ${AV_DEP_NAME}, but the version is not in range: ${AV_DEP_ACTUAL_VERSION} (version[s] ${AV_DEP_VERSION} supported)")
        endif()
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

# Skip installation of third-party projects unless the user opted-in
# This applies to the current directory (third-party) and all subdirectories
# which are added by FetchContent.
if(NOT ALICEVISION_INSTALL_THIRD_PARTY)
  message(STATUS "No install rules will be generated for third-party projects.")
  set(CMAKE_SKIP_INSTALL_RULES ON)
else()
  if(CMAKE_GENERATOR MATCHES "(Xcode|Ninja Multi-Config|Visual Studio)")
    message(WARNING "Third-party projects will be installed, but it appears a multi-config generator (${CMAKE_GENERATOR}) is used. Expect issues and consider switching to a single-config generator instead.")
  else()
    message(STATUS "Third-party projects will be installed.")
  endif()
  if(CMAKE_INSTALL_PREFIX STREQUAL "c:/Program Files/${PROJECT_NAME}"
     OR CMAKE_INSTALL_PREFIX STREQUAL "/usr"
     OR CMAKE_INSTALL_PREFIX STREQUAL "/usr/local"
     OR CMAKE_INSTALL_PREFIX STREQUAL "/opt/homebrew"
     OR CMAKE_INSTALL_PREFIX STREQUAL "/opt/local"
  )
    if(ALICEVISION_DO_AS_I_SAY)
      # Do nothing, the user explicitly opted in to do something potentially
      # dangerous
    else()
      message(FATAL_ERROR "You are trying to install third-party packages into a system prefix (${CMAKE_INSTALL_PREFIX}), which can break your system and is *highly* discouraged. Consider setting CMAKE_INSTALL_PREFIX to another path. If you really know what you are doing, you can add ALICEVISION_DO_AS_I_SAY=ON to the CMake invocation (we won't bother you anymore but the responsibility is yours)!")
    endif()
  endif()
endif()

# We set some directory-level variables to deal with older third-party projects
# which might use deprecated CMake policies by default.
# CMP0077: If not set, older projects may overwrite set() calls with option()
# CMP0126: If not set, older projects may overwrite set() calls with set(CACHE)
set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
cmake_policy(SET CMP0077 NEW)
set(CMAKE_POLICY_DEFAULT_CMP0126 NEW)
cmake_policy(SET CMP0126 NEW)

# We don't want the targets found through any find_package() call of a third-
# party project to be promoted to global scope.
# Any of our find_package() calls include the GLOBAL keyword to promote them to
# the global scope, so a find_package(GLOBAL) call overrides any setting from
# CMAKE_FIND_PACKAGE_TARGETS_GLOBAL on a per-package based level.
set(CMAKE_FIND_PACKAGE_TARGETS_GLOBAL OFF)

# We don't want any warning messages to be emitted from a third-party project
# during build time so we unconditionally disable all compiler warnings by
# default unless the user opted-in to have them emitted.
if(NOT ALICEVISION_PRINT_THIRD_PARTY_WARNINGS)
  if(MSVC OR CMAKE_CXX_COMPILER_ID MATCHES "(GNU|AppleClang|Clang)")
    set_directory_properties(
        PROPERTIES COMPILE_OPTIONS $<$<COMPILE_LANGUAGE:C,CXX>:$<IF:$<BOOL:${MSVC}>,/W0,-w>>
    )
    message(STATUS "Compiler warnings for third-party projects will be suppressed.")
  else()
    message(STATUS "Compiler warnings for third-party projects cannot be suppressed because the compiler is not yet supported (${CMAKE_CXX_COMPILER_ID}).")
  endif()
else()
  message(STATUS "Compiler warnings for third-party projects will be emitted (build can be noisy!)")
endif()

# Add the folder for our custom Find*.cmake modules to the CMake module path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/find")

# Frameworks should be searched at the very end, because it might break stuff
# on Apple platforms (e.g., libPNG links against Homebrew and includes
# "/Library/Frameworks/Mono.framework/Headers", which causes symbol mismatches
set(CMAKE_FIND_FRAMEWORK LAST)

# =============================================================================
# zlib
# (Version compatibility: AnyNewerVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(zlib
    ALLOW_CMAKE_MODULE
)

# =============================================================================
# Boost
# (Version compatibility: SameMajorVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(Boost
    VERSION 1.74...<2
    COMPONENTS
      atomic
      container
      date_time
      graph
      headers
      json
      log
      log_setup
      program_options
      regex
      serialization
      system
      thread
      timer
      unit_test_framework
)

# =============================================================================
# OpenMP
# (Version compatibility: AnyNewerVersion)
#
# NOTE:
# OpenMP can never be found in Config mode because it technically is a compiler
# intrinsic functionality. In CMake, OpenMP is found using a CMake-provided
# FindOpenMP module. We use this and apply a range of workarounds, especially
# for Apple and when OpenMP is being built from source.
#
# Dependencies: None
# =============================================================================
# OpenMP requires special handling if a package-manager provided OpenMP should
# be used, provide a fixup for common paths
alicevision_push_appleclang_openmp()

alicevision_ensure_dependency(OpenMP
    ALLOW_CMAKE_MODULE
    COMPONENTS CXX
)

alicevision_pop_appleclang_openmp()

# =============================================================================
# nanoflann
# (Version compatibility: AnyNewerVersion)
#
# Dependencies: Threads
# =============================================================================
alicevision_ensure_dependency(nanoflann
    VERSION 1.5.4...
)

# =============================================================================
# Expat
# (Version compatibility: SameMajorVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(Expat
    VERSION 2.4.8...<3
)

# =============================================================================
# libdeflate
# (Version compatibility: AnyNewerVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(libdeflate)

# =============================================================================
# openjph
# (Version compatibility: SameMinorVersion)
#
# NOTE:
# Despite breaking API changes between minor versions we accept multiple
# versions, because OpenEXR supports any version newer than 0.21. This may
# change if other dependencies require a more specific version (range).
# Must at least be 0.21.2 for OpenImageIO.
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(openjph
  VERSION 0.21.2...
)

# =============================================================================
# Imath
# (Version compatibility: SameMajorVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(Imath
    VERSION 3.1...<4
)

# =============================================================================
# TBB/oneTBB
# (Version compatibility: AnyNewerVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(TBB)

# =============================================================================
# OpenEXR
# (Version compatibility: SameMajorVersion)
#
# NOTE:
# We keep support for OpenEXR 2.5, but prefer OpenEXR 3, allow 2.5 to fail
#
# Dependencies: Imath, Threads (libdeflate, openjph, TBB)
# =============================================================================
alicevision_ensure_dependency(OpenEXR
    VERSION 2.5...<=3
    LEGACY_SUPPORT_VERSION 2.5
)

# =============================================================================
# OpenColorIO
# (Version compatibility: SameMajorVersion)
#
# NOTE:
# We do not provide pystring, because OpenColorIO will just include it if
# required. The same applies to yaml-cpp and minizip-ng.
#
# Dependencies: Imath, zlib, minizip-ng, pystring, yaml-cpp, Expat
# =============================================================================
alicevision_ensure_dependency(OpenColorIO
    VERSION 2.3...<3
)

# =============================================================================
# Eigen
# (Version compatibility: SameMajorVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(Eigen
    ALTERNATIVE_PACKAGE_NAMES eigen Eigen3 eigen3
    VERSION 3...<=5
)

# =============================================================================
# LZ4
# (Version compatibility: SameMajorVersion)
#
# NOTE:
# Must use ALLOW_CMAKE_MODULE because package-manager provided versions might
# not ship an accompanying lz4Config.cmake file. We provide our own
# FindLZ4.cmake module to provide minimal support.
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(LZ4
  ALLOW_CMAKE_MODULE
)

# =============================================================================
# flann
# (Version compatibility: SameMajorVersion)
#
# Dependencies: LZ4 (OpenMP, CUDA)
# =============================================================================
alicevision_ensure_dependency(flann
  VERSION 1.8.4...<2
)

# =============================================================================
# (Open)BLAS/(Open)LAPACK
# (Version compatibility: All)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(BLAS
    ALLOW_CMAKE_MODULE
)
alicevision_ensure_dependency(LAPACK
    ALLOW_CMAKE_MODULE
)

# =============================================================================
# CoinUtils
# (Version compatibility: Unknown, suspecting SameMajorVersion)
#
# Dependencies: BLAS
# =============================================================================
alicevision_ensure_dependency(CoinUtils
    VERSION 2.9.3...<3
    ALLOW_CMAKE_MODULE
)

# =============================================================================
# Osi
# (Version compatibility: Unknown, suspecting SameMajorVersion)
#
# Dependencies: CoinUtils
# =============================================================================
alicevision_ensure_dependency(Osi
    VERSION ...<1
    ALLOW_CMAKE_MODULE
)

# =============================================================================
# Clp
# (Version compatibility: Unknown, suspecting SameMajorVersion)
#
# Dependencies: CoinUtils, Osi
# =============================================================================
alicevision_ensure_dependency(Clp
    VERSION 1...<2
    ALLOW_CMAKE_MODULE
)

# =============================================================================
# LEMON
# (Version compatibility: Unknown, suspecting SameMajorVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(LEMON
    VERSION 1.3...<2
)

# =============================================================================
# Xerces-C
# (Version compatibility: SameMajorVersion)
#
# Dependencies: Threads
# =============================================================================
alicevision_ensure_dependency(XercesC
    VERSION 3.2...<4
)

# =============================================================================
# E57Format
# (Version compatibility: SameMajorVersion)
#
# Dependencies: Xerces-C, Threads
# =============================================================================
alicevision_ensure_dependency(E57Format)

# =============================================================================
# Assimp
# (Version compatibility: SameMajorVersion)
#
# NOTE:
# Assimp only supports SameMajorVersion increments, but support for Assimp > 6
# is verified for this project. No other dependency requires Assimp.
#
# Dependencies: Threads
# =============================================================================
alicevision_ensure_dependency(Assimp
    VERSION 5.0.0...<=6.0.5
)

# =============================================================================
# Alembic
# (Version compatibility: AnyNewerVersion)
#
# Dependencies: Threads
# =============================================================================
alicevision_ensure_dependency(Alembic
    VERSION 1.7.0...
)

# =============================================================================
# libTIFF
# (Version compatibility: SameMajorVersion)
#
# Dependencies: Threads
# =============================================================================
alicevision_ensure_dependency(TIFF
    VERSION 4.0...<=5
    ALLOW_CMAKE_MODULE
)

# =============================================================================
# libjpeg-turbo
# (Version compatibility: AnyNewerVersion)
#
# Dependencies: zlib
# =============================================================================
alicevision_ensure_dependency(libjpeg-turbo
    VERSION 2.1...
)

# =============================================================================
# libPNG
# (Version compatibility: SameMinorVersion)
#
# NOTE:
# Although libPNG only supports API/ABI compatibility for same minor versions,
# OpenImageIO explicitly tests and supports libPNG 1.6...1.6.56.
#
# Dependencies: zlib
# =============================================================================
alicevision_ensure_dependency(PNG
    VERSION 1.6...<=1.6.58
    ALLOW_CMAKE_MODULE
)

# =============================================================================
# libRAW
# (Version compatibility: AnyNewerVersion)
#
# Dependencies: zlib, JPEG, (OpenMP)
# =============================================================================
alicevision_ensure_dependency(libraw
    VERSION 0.20...
)

# =============================================================================
# OpenJPEG
# (Version compatibility: SameMajorVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(OpenJPEG
    VERSION 2.0...<3
)

# =============================================================================
# GIFLIB
# (Version compatibility: Unknown, suspecting SameMajorVersion)
#
# NOTE:
# Although GIFLIB likely is only ABI/API compatible between major versions,
# OpenImageIO tests and supports GIFLIB versions 5.0...<=6.1.3.
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(GIF
    VERSION 5.0...<=6.1.3
    ALLOW_CMAKE_MODULE
)

# =============================================================================
# libheif: TODO
# =============================================================================

# =============================================================================
# WebP
# (Version compatibility: Unknown, AnyNewerVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(WebP
    VERSION 1.1...
)

# =============================================================================
# libjxl: TODO
# =============================================================================

# =============================================================================
# OpenImageIO
# (Version compatibility: SameMajorVersion)
#
# Dependencies: Imath, OpenEXR, libTIFF, OpenColorIO, libjpeg-turbo, zlib,
# (libPNG, libraw, OpenJPEG, TBB/oneTBB, GIFLIB, libheif, WebP, libjxl)
# =============================================================================
alicevision_ensure_dependency(OpenImageIO
    VERSION 3.0.0...<4
)

# =============================================================================
# Fixup targets to be under out third-party folder in IDEs
# =============================================================================
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/FixupTargetFolders.cmake)
alicevision_fixup_thirdparty_ide_folder(${CMAKE_CURRENT_SOURCE_DIR})

# Pop the folder for our custom Find*.cmake modules from the CMake module path
list(REMOVE_ITEM CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/find")