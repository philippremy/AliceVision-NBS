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
option(ALICEVISION_DO_AS_I_SAY "Prevent CMake from ensuring you are not breaking your system or accidentially including GPL-licensed code in a distributable package (DANGEROUS!)" OFF)
option(ALICEVISION_LOG_THIRD_PARTY_CONFIGURE "Show configure logs of third-party projects" OFF)
option(ALICEVISION_NO_FORTRAN "Do not use Fortran as a language" OFF)
option(ALICEVISION_ALLOW_GPL "Allows using GPL-licensed code from external dependencies, but makes this build undistributable" ON)
option(ALICEVISION_SUITESPARSE_ON_APPLE "Forces usage of SuiteSparse on Apple platforms (Apple has Accelerate.framework for the same functionality, so only turn ON for good reason!)" ON)  # TODO: Turn OFF by default

# Specific dependency options
include(CMakeDependentOption)
cmake_dependent_option(ALICEVISION_OPENBLAS_PREBUILT "Whether to use pre-built binaries for BLAS/LAPACK on Windows" OFF "WIN32 AND NOT CMAKE_CROSSCOMPILING" OFF)
if(WIN32)
  option(ALICEVISION_USE_C_LAPACK ON "Whether to use the f2c'ed (C) version of LAPACK when building an embedded LAPACK")
else()
  option(ALICEVISION_USE_C_LAPACK OFF "Whether to use the f2c'ed (C) version of LAPACK when building an embedded LAPACK")
endif()

option(ALICEVISION_FORCE_BUILD_zlib "Force build zlib" OFF)
option(ALICEVISION_FORCE_BUILD_Boost "Force build Boost" OFF)
option(ALICEVISION_FORCE_BUILD_OpenMP "Force build OpenMP" OFF)
option(ALICEVISION_FORCE_BUILD_nanoflann "Force build nanoflann" OFF)
option(ALICEVISION_FORCE_BUILD_Expat "Force build Expat" OFF)
option(ALICEVISION_FORCE_BUILD_libdeflate "Force build libdeflate" OFF)
option(ALICEVISION_FORCE_BUILD_openjph "Force build openjph" OFF)
option(ALICEVISION_FORCE_BUILD_Imath "Force build Imath" OFF)
option(ALICEVISION_FORCE_BUILD_TBB "Force build TBB" OFF)
option(ALICEVISION_FORCE_BUILD_OpenEXR "Force build OpenEXR" OFF)
option(ALICEVISION_FORCE_BUILD_OpenColorIO "Force build OpenColorIO" OFF)
option(ALICEVISION_FORCE_BUILD_Eigen "Force build Eigen" OFF)
option(ALICEVISION_FORCE_BUILD_LZ4 "Force build LZ4" OFF)
option(ALICEVISION_FORCE_BUILD_flann "Force build flann" OFF)
option(ALICEVISION_FORCE_BUILD_BLAS "Force build BLAS" OFF)
option(ALICEVISION_FORCE_BUILD_LAPACK "Force build LAPACK" OFF)
option(ALICEVISION_FORCE_BUILD_SuiteSparse "Force build SuiteSparse" OFF)
option(ALICEVISION_FORCE_BUILD_Ceres "Force build Ceres" OFF)
option(ALICEVISION_FORCE_BUILD_XercesC "Force build XercesC" OFF)
option(ALICEVISION_FORCE_BUILD_E57Format "Force build E57Format" OFF)
option(ALICEVISION_FORCE_BUILD_assimp "Force build assimp" OFF)
option(ALICEVISION_FORCE_BUILD_Alembic "Force build Alembic" OFF)
option(ALICEVISION_FORCE_BUILD_Geogram "Force build Geogram" OFF)

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

# We emit a warning if the user disallowed GPL code but allowed external
# dependencies
if(NOT ALICEVISION_ALLOW_GPL AND ALICEVISION_ALLOW_SYSTEM_DEPENDENCIES)
  message(WARNING "GPL code is not allowed, but CMake is allowed to look for external dependencies! We cannot ensure that no GPL-licensed code will be picked up along the way by means of transitive dependencies. This build will not be redistributable by default unless you specify ALICEVISION_DO_AS_I_SAY.")
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

# Make an SBOM library
if(BUILD_SHARED_LIBS AND NOT VCPKG_TOOLCHAIN)

  add_library(AliceVision_ALL_DEPS SHARED
    stub.cpp
  )

  target_link_libraries(AliceVision_ALL_DEPS
      PUBLIC
        ZLIB::ZLIB
        Boost::atomic
        Boost::container
        Boost::date_time
        Boost::graph
        Boost::headers
        Boost::json
        Boost::log
        Boost::log_setup
        Boost::program_options
        Boost::regex
        Boost::serialization
        Boost::thread
        Boost::timer
        Boost::unit_test_framework
        OpenMP::OpenMP_CXX
        nanoflann::nanoflann
        expat::expat
        libdeflate::libdeflate_shared
        openjph
        Imath::Imath
        TBB::tbb
        OpenEXR::OpenEXR
        pystring::pystring
        yaml-cpp::yaml-cpp
        MINIZIP::minizip-ng
        OpenColorIO::OpenColorIO
        Eigen3::Eigen
        lz4::lz4
        flann::flann_cpp
        BLAS::BLAS
        LAPACK::LAPACK
        $<$<BOOL:ALICEVISION_ALLOW_GPL>:SuiteSparse::AMD>
        $<$<BOOL:ALICEVISION_ALLOW_GPL>:SuiteSparse::CAMD>
        $<$<BOOL:ALICEVISION_ALLOW_GPL>:SuiteSparse::CCOLAMD>
        $<$<BOOL:ALICEVISION_ALLOW_GPL>:SuiteSparse::CHOLMOD>
        $<$<BOOL:ALICEVISION_ALLOW_GPL>:SuiteSparse::COLAMD>
        $<$<BOOL:ALICEVISION_ALLOW_GPL>:SuiteSparse::SPQR>
        Ceres::ceres
        XercesC::XercesC
        E57Format::E57Format
        assimp::assimp
        Alembic::Alembic
        Geogram::geogram
  )

elseif(BUILD_STATIC_LIBS AND NOT VCPKG_TOOLCHAIN)

  add_library(AliceVision_ALL_DEPS SHARED
      stub.cpp
  )

  # Force loading all symbols
  target_link_options(AliceVision_ALL_DEPS
      PRIVATE -all_load
  )

  target_link_libraries(AliceVision_ALL_DEPS
      PUBLIC
      ZLIB::ZLIBSTATIC
      Boost::atomic
      Boost::container
      Boost::date_time
      Boost::graph
      Boost::headers
      Boost::json
      Boost::log
      Boost::log_setup
      Boost::program_options
      Boost::regex
      Boost::serialization
      Boost::thread
      Boost::timer
      Boost::unit_test_framework
      OpenMP::OpenMP_CXX
      nanoflann::nanoflann
      expat::expat
      libdeflate::libdeflate_static
      openjph
      Imath::Imath
      TBB::tbb
      OpenEXR::OpenEXR
      pystring::pystring
      yaml-cpp::yaml-cpp
      MINIZIP::minizip-ng
      OpenColorIO::OpenColorIO
      Eigen3::Eigen
      lz4::lz4
      flann::flann_cpp_s
      BLAS::BLAS
      LAPACK::LAPACK
      $<$<BOOL:ALICEVISION_ALLOW_GPL>:SuiteSparse::AMD_static>
      $<$<BOOL:ALICEVISION_ALLOW_GPL>:SuiteSparse::CAMD_static>
      $<$<BOOL:ALICEVISION_ALLOW_GPL>:SuiteSparse::CCOLAMD_static>
      $<$<BOOL:ALICEVISION_ALLOW_GPL>:SuiteSparse::CHOLMOD_static>
      $<$<BOOL:ALICEVISION_ALLOW_GPL>:SuiteSparse::COLAMD_static>
      $<$<BOOL:ALICEVISION_ALLOW_GPL>:SuiteSparse::SPQR_static>
      Ceres::ceres
      XercesC::XercesC
      E57Format::E57Format
      assimp::assimp
      Alembic::Alembic
      Geogram::geogram
  )

endif()
