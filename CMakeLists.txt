cmake_minimum_required(VERSION 3.30)

message(STATUS "The CMake version is: ${CMAKE_VERSION}")

set(CMAKE_CXX_STANDARD 20 CACHE STRING "The C++ standard to use")
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE BOOL "Whether the C++ standard is required")

option(ALICEVISION_BUILD_THIRD_PARTY "Allow building dependencies from source" ON)
option(ALICEVISION_INSTALL_THIRD_PARTY "Install any third-party packages obtained through FetchContent" OFF)
option(ALICEVISION_ALLOW_SYSTEM_DEPENDENCIES "Allow finding dependencies externally" ON)
option(ALICEVISION_FIND_SYSTEM_DEPENDENCIES_VERBOSE "When finding system-provided dependencies do not pass QUIET to find_package()" OFF)
option(ALICEVISION_IGNORE_XCODE_PACKAGES "Ignores packages provided by Xcode (e.g., zlib, liblzma, etc.) which are usually too old" ON)
option(ALICEVISION_PRINT_THIRD_PARTY_WARNINGS "Print compiler warnings for any third-party projects" OFF)
option(ALICEVISION_DO_AS_I_SAY "Prevent CMake from ensuring you are not breaking your system (DANGEROUS!)" OFF)
option(ALICEVISION_LOG_THIRD_PARTY_CONFIGURE "Show configure logs of third-party projects" OFF)
option(ALICEVISION_NO_FORTRAN "Do not use Fortran as a language" OFF)

# Specific dependency options
include(CMakeDependentOption)
cmake_dependent_option(ALICEVISION_OPENBLAS_PREBUILT "Whether to use pre-built binaries for BLAS/LAPACK on Windows" OFF WIN32 OFF)
if(WIN32)
  option(ALICEVISION_USE_C_LAPACK ON "Whether to use the f2c'ed (C) version of LAPACK when building an embedded LAPACK")
else()
  option(ALICEVISION_USE_C_LAPACK OFF "Whether to use the f2c'ed (C) version of LAPACK when building an embedded LAPACK")
endif()

option(ALICEVISION_FORCE_BUILD_zlib OFF "Force build zlib")
option(ALICEVISION_FORCE_BUILD_Boost OFF "Force build Boost")
option(ALICEVISION_FORCE_BUILD_OpenMP OFF "Force build OpenMP")
option(ALICEVISION_FORCE_BUILD_nanoflann OFF "Force build nanoflann")
option(ALICEVISION_FORCE_BUILD_Expat OFF "Force build Expat")
option(ALICEVISION_FORCE_BUILD_libdeflate OFF "Force build libdeflate")
option(ALICEVISION_FORCE_BUILD_openjph OFF "Force build openjph")
option(ALICEVISION_FORCE_BUILD_Imath OFF "Force build Imath")
option(ALICEVISION_FORCE_BUILD_TBB OFF "Force build TBB")
option(ALICEVISION_FORCE_BUILD_OpenEXR OFF "Force build OpenEXR")
option(ALICEVISION_FORCE_BUILD_OpenColorIO OFF "Force build OpenColorIO")
option(ALICEVISION_FORCE_BUILD_Eigen OFF "Force build Eigen")
option(ALICEVISION_FORCE_BUILD_LZ4 OFF "Force build LZ4")
option(ALICEVISION_FORCE_BUILD_flann OFF "Force build flann")
option(ALICEVISION_FORCE_BUILD_BLAS OFF "Force build BLAS")
option(ALICEVISION_FORCE_BUILD_LAPACK OFF "Force build LAPACK")
option(ALICEVISION_FORCE_BUILD_CoinUtils OFF "Force build CoinUtils")
option(ALICEVISION_FORCE_BUILD_Clp OFF "Force build Clp")
option(ALICEVISION_FORCE_BUILD_Osi OFF "Force build Osi")
option(ALICEVISION_FORCE_BUILD_LEMON OFF "Force build LEMON")
option(ALICEVISION_FORCE_BUILD_XercesC OFF "Force build XercesC")
option(ALICEVISION_FORCE_BUILD_E57Format OFF "Force build E57Format")

# Default to shared libraries
if(NOT DEFINED BUILD_SHARED_LIBS)
  set(BUILD_SHARED_LIBS ON)
  message(STATUS "Building shared libraries.")
endif()
set(BUILD_STATIC_LIBS OFF)
if(NOT BUILD_SHARED_LIBS)
  set(BUILD_STATIC_LIBS ON)
  message(STATUS "Building static libraries.")
endif()

# Detect of we are building a fat binary on Apple, then don't allow any
# external dependencies
list(LENGTH CMAKE_OSX_ARCHITECTURES AV_APPLE_ARCHITECTURE_COUNT)
if(APPLE AND AV_APPLE_ARCHITECTURE_COUNT GREATER 1)
  message(STATUS "Building a universal binary for macOS, disabling external dependencies.")
  set(ALICEVISION_BUILD_THIRD_PARTY ON CACHE BOOL "Allow building dependencies from source (force enable because a universal macOS binary will be built)" FORCE)
  set(ALICEVISION_INSTALL_THIRD_PARTY OFF CACHE BOOL "Install any third-party packages obtained through FetchContent (force disable because a universal macOS binary will be built)" FORCE)
  set(ALICEVISION_ALLOW_SYSTEM_DEPENDENCIES OFF CACHE BOOL "Allow finding dependencies externally (force disable because a universal macOS binary will be built)" FORCE)
  set(AV_IS_APPLE_UNIVERSAL_BUILD ON CACHE INTERNAL "Whether a universal binary is being built on Apple platforms")

  # We must additionally work around a bug in upstream LLVM:
  # See https://github.com/llvm/llvm-project/issues/98997
  # When a non-AppleClang compiler (i.e., LLVM Clang) is used to build a
  # universal binary, CMake will use RANLIB from this LLVM  installation (i.e.,
  # llvm-ranlib). These currently produce invalid archive  files if compiled as
  # static libraries.
  # Detect this case and then force usage of the Xcode command line tools
  # RANLIB.
  # This must be set before the first project() call to correctly take effect.
  if(BUILD_STATIC_LIBS)

    message(WARNING "Attempting to build static universal binaries with a compiler other than AppleClang is known to cause issues. Trying to fix up CMAKE_RANLIB to work around LLVM bug #98997.")

    execute_process(
      COMMAND
        /usr/bin/xcrun --find ranlib
      OUTPUT_VARIABLE XCRUN_FIND_RANLIB_OUTPUT
      OUTPUT_STRIP_TRAILING_WHITESPACE
      COMMAND_ERROR_IS_FATAL ANY
    )

    set(CMAKE_RANLIB ${XCRUN_FIND_RANLIB_OUTPUT} CACHE INTERNAL "Path to a program." FORCE)

    message(STATUS "Fixed up CMAKE_RANLIB (now ${XCRUN_FIND_RANLIB_OUTPUT}) to allow building universal binaries with non-AppleClang compiler.")

  endif()
endif()

# If Fortran is disabled, we must force the C LAPACK to be used
if(ALICEVISION_NO_FORTRAN)
  set(ALICEVISION_USE_C_LAPACK ON CACHE BOOL "Whether to use the f2c'ed (C) version of LAPACK when building an embedded LAPACK (force enabled because Fortran was disabled by the user)" FORCE)
endif()

# Project call after determining Apple quirks
project(AliceVision LANGUAGES C CXX)

# We might need a Fortran compiler, so check if one is available. It is not an
# error if it is unavailable.
# If a universal build for Apple is requested, we do not activate Fortran at
# all, because building universal binaries is unsupported.
if(NOT ALICEVISION_NO_FORTRAN AND NOT AV_IS_APPLE_UNIVERSAL_BUILD)
  include(CheckLanguage)
  check_language(Fortran)
  if(CMAKE_Fortran_COMPILER)
    enable_language(Fortran)
  endif()
else()
  set(CMAKE_Fortran_COMPILER NOTFOUND)
endif()

# Add the dependency management
add_subdirectory(third-party EXCLUDE_FROM_ALL)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE
    ZLIB::ZLIB
    Boost::filesystem
    OpenMP::OpenMP_CXX
    nanoflann::nanoflann
    expat::expat
    libdeflate::libdeflate_shared
    openjph
    Imath::Imath
    TBB::tbb
    OpenEXR::OpenEXR
    Eigen3::Eigen
    lz4::lz4
)