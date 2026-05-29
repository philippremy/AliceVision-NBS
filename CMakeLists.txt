cmake_minimum_required(VERSION 3.30)

project(AliceVision LANGUAGES C CXX)

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

set(ALICEVISION_FORCE_BUILD_zlib OFF)
set(ALICEVISION_FORCE_BUILD_Boost OFF)
set(ALICEVISION_FORCE_BUILD_OpenMP OFF)
set(ALICEVISION_FORCE_BUILD_nanoflann OFF)
set(ALICEVISION_FORCE_BUILD_Expat OFF)
set(ALICEVISION_FORCE_BUILD_libdeflate OFF)
set(ALICEVISION_FORCE_BUILD_openjph OFF)
set(ALICEVISION_FORCE_BUILD_Imath OFF)
set(ALICEVISION_FORCE_BUILD_TBB OFF)
set(ALICEVISION_FORCE_BUILD_OpenEXR OFF)
set(ALICEVISION_FORCE_BUILD_OpenColorIO OFF)
set(ALICEVISION_FORCE_BUILD_Eigen OFF)
set(ALICEVISION_FORCE_BUILD_LZ4 OFF)
set(ALICEVISION_FORCE_BUILD_flann OFF)
set(ALICEVISION_FORCE_BUILD_BLAS OFF)
set(ALICEVISION_FORCE_BUILD_LAPACK OFF)
set(ALICEVISION_FORCE_BUILD_CoinUtils OFF)
set(ALICEVISION_FORCE_BUILD_Clp OFF)
set(ALICEVISION_FORCE_BUILD_Osi OFF)
set(ALICEVISION_FORCE_BUILD_LEMON OFF)
set(ALICEVISION_FORCE_BUILD_XercesC OFF)
set(ALICEVISION_FORCE_BUILD_E57Format OFF)

# Detect if we are building a fat binary on Apple, then don't allow any
# external dependencies
list(LENGTH CMAKE_OSX_ARCHITECTURES AV_APPLE_ARCHITECTURE_COUNT)
if(AV_APPLE_ARCHITECTURE_COUNT GREATER 1)
  message(STATUS "Building a universal binary for macOS, disabling external dependencies.")
  set(ALICEVISION_BUILD_THIRD_PARTY ON CACHE BOOL "Allow building dependencies from source (force enable because a universal macOS binary will be built)" FORCE)
  set(ALICEVISION_INSTALL_THIRD_PARTY OFF CACHE BOOL "Install any third-party packages obtained through FetchContent (force disable because a universal macOS binary will be built)" FORCE)
  set(ALICEVISION_ALLOW_SYSTEM_DEPENDENCIES OFF CACHE BOOL "Allow finding dependencies externally (force disable because a universal macOS binary will be built)" FORCE)
endif()

# Default to shared libraries
if(NOT DEFINED BUILD_SHARED_LIBS)
  set(BUILD_SHARED_LIBS ON)
endif()
set(BUILD_STATIC_LIBS ON)
if(BUILD_SHARED_LIBS)
  set(BUILD_STATIC_LIBS OFF)
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