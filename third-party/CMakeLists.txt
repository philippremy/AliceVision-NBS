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
# ALICEVISION_FIND_SYSTEM_DEPENDENCIES_VERBOSE: If ON, CMake will call
#                                               find_package() without the
#                                               QUIET argument.
# ALICEVISION_LOG_THIRD_PARTY_CONFIGURE: If ON, CMake will not supress any
#                                        calls to message() with a level
#                                        lower than FATAL_ERROR when
#                                        configuring third-party dependencies.
# ALICEVISION_NO_FORTRAN: If ON, will instruct CMake to use fallback mechanisms
#                         for Fortran-related projects (this currently includes
#                         building LAPACK with a f2c'ed version instead of the
#                         original Fortran code).
# ALICEVISION_ALLOW_GPL: If ON, CMake can find/build GPL-licensed code and link
#                        such code into the project (currently only affects
#                        SuiteSparse, whose CHOLMOD module contains GPL-
#                        licensed code.)
# ALICEVISION_SUITESPARSE_ON_APPLE: If ON, will find/build SuiteSparse on Apple
#                                   platforms although it is not required, as
#                                   Apple provides Accelerate.framework with
#                                   similar functionality.
# ALICEVISION_OPENBLAS_PREBUILT: If ON (possible on Windows only), CMake will
#                                fetch pre-built binaries of OpenBLAS instead
#                                of building OpenBLAS from source.
# ALICEVISION_USE_C_LAPACK: If ON, CMake will build the LAPACK contained in
#                           OpenBLAS from f2c'ed C code instead of the original
#                           Fortran source code. This is forced to ON if
#                           ALICEVISION_NO_FORTRAN is set to ON.
# ALICEVISION_IGNORE_XCODE_PACKAGES: If ON, CMake will not look for packages
#                                    provided by Xcode (e.g., zlib, etc.) which
#                                    are usually old enough to be incompatible
#                                    with everything else. An exception is made
#                                    for Ceres to allow finding the Accelerate
#                                    framework provided by Apple. This option
#                                    should technically not be changed.
# ALICEVISION_DO_AS_I_SAY: If ON, CMake will not prevent some scenarios that
#                          might break the system. An example would be to
#                          install third-party projects into a system prefix
#                          (which could silently overwrite package-manager
#                          provided packages).
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/EnsureDependency.cmake)

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
# CMP0074: If not set, older projects might ignore <PackageName>_ROOT variables
# CMP0135: If not set, older project might use wrong download timestamps
# CMP0168: If not set, older project might use a seperate build for FetchContent
set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
cmake_policy(SET CMP0077 NEW)
set(CMAKE_POLICY_DEFAULT_CMP0126 NEW)
cmake_policy(SET CMP0126 NEW)
set(CMAKE_POLICY_DEFAULT_CMP0074 NEW)
cmake_policy(SET CMP0074 NEW)
set(CMAKE_POLICY_DEFAULT_CMP0135 NEW)
cmake_policy(SET CMP0135 NEW)
set(CMAKE_POLICY_DEFAULT_CMP0168 NEW)
cmake_policy(SET CMP0168 NEW)

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
  if(MSVC OR (CMAKE_C_COMPILER_ID MATCHES "(GNU|AppleClang|Clang)" AND CMAKE_CXX_COMPILER_ID MATCHES "(GNU|AppleClang|Clang)"))
    set_directory_properties(
        PROPERTIES COMPILE_OPTIONS $<$<COMPILE_LANGUAGE:C,CXX>:$<IF:$<BOOL:${MSVC}>,/w,-w>>
    )
    message(STATUS "C/C++ Compiler warnings for third-party projects will be suppressed.")
  else()
    message(STATUS "C/C++ Compiler warnings for third-party projects cannot be suppressed because the compiler is not yet supported (${CMAKE_CXX_COMPILER_ID}).")
  endif()
  if(CMAKE_Fortran_COMPILER)
    if(CMAKE_Fortran_COMPILER_ID MATCHES "(Flang|LLVMFlang|G95|GNU)")
      set_directory_properties(
          PROPERTIES COMPILE_OPTIONS $<$<COMPILE_LANGUAGE:Fortran>:-w>
      )
      message(STATUS "Fortran Compiler warnings for third-party projects will be suppressed.")
    else()
      message(STATUS "Fortran Compiler warnings for third-party projects cannot be suppressed because the compiler is not yet supported (${CMAKE_Fortran_COMPILER_ID}).")
    endif()
  endif()
else()
  message(STATUS "Compiler warnings for third-party projects will be emitted (build can be noisy!)")
endif()

# Add the folder for our custom Find*.cmake modules to the CMake module path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/find")

# We have custom *Config.cmake modules for SuiteSparse, so set our folder as
# a SuiteSparse_DIR variable to be used by CONFIG search mode, if it was not
# set by the user.
if(NOT DEFINED SuiteSparse_DIR)
  set(SuiteSparse_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake/configs")
endif()

# Frameworks should be searched at the very end, because it might break stuff
# on Apple platforms (e.g., libPNG links against Homebrew and includes
# "/Library/Frameworks/Mono.framework/Headers", which causes symbol mismatches
set(CMAKE_FIND_FRAMEWORK LAST)

# Apple provides many packages and libraries with Xcode, but they are pretty
# much all way too old to be used. Disable finding there globally.
if(CMAKE_CROSSCOMPILING OR (ALICEVISION_IGNORE_XCODE_PACKAGES AND APPLE))
  # Remove all CMake system paths
  set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH OFF)
  set(CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH OFF)
  # For Apple, re-add package manager prefixes
  if(NOT CMAKE_CROSSCOMPILING)
    list(APPEND CMAKE_PREFIX_PATH
      "/opt/homebrew"   # Apple Silicon Homebrew
      "/usr/local"      # Intel Mac Homebrew
      "/opt/local"      # MacPorts
    )
  endif()
endif()

# This is an undocumented CPack variable which is used by some projects (oneTBB
# and lz4 for example) to check whether they should do a include(CPack) calll,
# which they should *not*. We set it here and unset it at the end of this file.
set(CPack_CMake_INCLUDED ON)

# =============================================================================
# Threads
# (Version compatibility: AnyNewerVersion)
#
# NOTE:
# This is required by several dependencies, so we find it early explicitly, but
# this cannot be built from source. Either the system supports threads or it
# does not.
#
# Dependencies: None
# =============================================================================
find_package(Threads REQUIRED QUIET)

# =============================================================================
# zlib
# (Version compatibility: AnyNewerVersion)
#
# NOTE:
# OpenColorIO requires at least zlib 1.2.13, which is newer than any zlib
# provided by Apple. I.e, the system zlib from Apple cannot be used.
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(ZLIB
    ALTERNATIVE_PACKAGE_NAMES ZLIB zlib
    VERSION 1.2.13
    ALLOW_CMAKE_MODULE
)

# =============================================================================
# Boost
# (Version compatibility: SameMajorVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(Boost
    VERSION 1.74.0
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
    VERSION 1.5.4
)

# =============================================================================
# Expat
# (Version compatibility: SameMajorVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(Expat
    VERSION 2.4.8
)

# =============================================================================
# libdeflate
# (Version compatibility: AnyNewerVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(libdeflate
    TRANSITIVE_ONLY
)

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
# FIXME:
# We cannot specify a version requirement, because this excludes many versions
# that are potentially compatible. If it is too old, some dependency might just
# not use it. Unless CMake starts providing a way to just query the version, we
# cannot do anything about it - except hard-erroring, which is not appropriate.
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(openjph
    TRANSITIVE_ONLY
)

# =============================================================================
# Imath
# (Version compatibility: SameMajorVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(Imath
    VERSION 3.1.0
    TRANSITIVE_ONLY
)

# =============================================================================
# TBB/oneTBB
# (Version compatibility: AnyNewerVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(TBB
    TRANSITIVE_ONLY
)

# =============================================================================
# OpenEXR
# (Version compatibility: SameMajorVersion)
#
# Dependencies: Imath, Threads (libdeflate, openjph, TBB)
# =============================================================================
alicevision_ensure_dependency(OpenEXR
    VERSION 3.0.0
)

# =============================================================================
# pystring
# (Version compatibility: Unknown, suspecting SameMajorVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(pystring
    VERSION 1.1.3
    TRANSITIVE_ONLY
)

# =============================================================================
# yaml-cpp
# (Version compatibility: AnyNewerVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(yaml-cpp
    VERSION 0.8.0
    TRANSITIVE_ONLY
)

# =============================================================================
# minizip-ng
# (Version compatibility: SameMajorVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(minizip-ng
    VERSION 4.0.0
    TRANSITIVE_ONLY
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
    VERSION 2.3.0
    TRANSITIVE_ONLY
)

# =============================================================================
# Eigen
# (Version compatibility: SameMajorVersion)
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(Eigen
    ALTERNATIVE_PACKAGE_NAMES Eigen eigen Eigen3 eigen3
    VERSION 5
    LEGACY_SUPPORT_VERSION 3
)

# =============================================================================
# LZ4
# (Version compatibility: SameMajorVersion)
#
# NOTE:
# Must use ALLOW_CMAKE_MODULE because package-manager provided versions might
# not ship an accompanying LZ4Config.cmake file. We provide our own
# FindLZ4.cmake module to provide minimal support.
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(LZ4
    ALLOW_CMAKE_MODULE
    TRANSITIVE_ONLY
)

# =============================================================================
# flann
# (Version compatibility: SameMajorVersion)
#
# Dependencies: LZ4 (OpenMP, CUDA)
# =============================================================================
alicevision_ensure_dependency(flann
    VERSION 1.8.4
)

# =============================================================================
# (Open)BLAS/(Open)LAPACK
# (Version compatibility: All)
#
# NOTE:
# We cannot allow CONFIG mode, because (for example) Netlib BLAS/LAPACK does
# not expose the target as LAPACK::LAPACK, but instead simply uses lapack.
# If we always use MODULE mode, we can ensure maximum compatibility between
# all platforms, regardless of the installed BLAS/LAPACK.
#
# Dependencies: None
# =============================================================================
alicevision_ensure_dependency(BLAS
    NO_CONFIG
    ALLOW_CMAKE_MODULE
    TRANSITIVE_ONLY
)
alicevision_ensure_dependency(LAPACK
    NO_CONFIG
    ALLOW_CMAKE_MODULE
    TRANSITIVE_ONLY
)

# =============================================================================
# SuiteSparse
# (Version compatibility: SameMajorVersion)
#
# NOTE:
# SuiteSparse contains GPL-licensed code modules (CHOLMOD), so it will neither
# be searched nor built if the user did not explicitly allow GPL licensed code.
#
# Dependencies: BLAS/LAPACK
# =============================================================================
if(ALICEVISION_ALLOW_GPL AND (NOT APPLE OR ALICEVISION_SUITESPARSE_ON_APPLE))
  alicevision_ensure_dependency(SuiteSparse
      VERSION 4.5.6
      ALLOW_CMAKE_MODULE
      COMPONENTS
        AMD
        CAMD
        CCOLAMD
        COLAMD
        CHOLMOD
        SPQR
      TRANSITIVE_ONLY
  )
endif()

# =============================================================================
# Ceres
# (Version compatibility: SameMajorVersion)
#
# Dependencies: Eigen, BLAS/LAPACK, (SuiteSparse/Accelerate.framework)
# =============================================================================
alicevision_ensure_dependency(Ceres
    VERSION 2.0.0
    LEGACY_SUPPORT_VERSION 1.10.0
)

# =============================================================================
# Xerces-C
# (Version compatibility: SameMajorVersion)
#
# Dependencies: Threads
# =============================================================================
alicevision_ensure_dependency(XercesC
    VERSION 3.2.0
    TRANSITIVE_ONLY
)

# =============================================================================
# libE57Format
# (Version compatibility: SameMajorVersion)
#
# Dependencies: Threads, XercesC
# =============================================================================
alicevision_ensure_dependency(E57Format
    VERSION 3.0.0
)

# =============================================================================
# Assimp
# (Version compatibility: SameMajorVersion)
#
# Dependencies: ZLIB
# =============================================================================
alicevision_ensure_dependency(assimp
    VERSION 6
    LEGACY_SUPPORT_VERSION 5
)

# =============================================================================
# Alembic
# (Version compatibility: AnyNewerVersion)
#
# Dependencies: Threads, Imath
# =============================================================================
alicevision_ensure_dependency(Alembic
    VERSION 1.7.0
)

# =============================================================================
# Fixup targets to be under out third-party folder in IDEs
# =============================================================================
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/FixupTargetWarningFlags.cmake)
alicevision_ensure_target_nowarn(${CMAKE_CURRENT_SOURCE_DIR})

# =============================================================================
# Fixup targets to be under out third-party folder in IDEs
# =============================================================================
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/FixupTargetFolders.cmake)
alicevision_fixup_thirdparty_ide_folder(${CMAKE_CURRENT_SOURCE_DIR})

# Pop the folder for our custom Find*.cmake modules from the CMake module path
list(REMOVE_ITEM CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/find")

# See above why this is explicitly unset here
unset(CPack_CMake_INCLUDED)
