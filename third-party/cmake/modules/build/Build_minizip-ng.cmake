# =============================================================================
# Build_minizip-ng.cmake - Integrates an embedded minizip-ng into the project
#
# Special cases considered:
# - Create target MINIZIP::minizip-ng if it does not exist
# - Create target zip::zip if it does not exist (assimp drop-in for vendored
# zip code which can cause duplicate symbols with minizip-ng)
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(minizip-ng
    CMAKE_EVAL_CODE
      "set(MZ_COMPAT ON)" # Assimp expects zip/unzip functions to be available
      "set(MZ_ZLIB ON)"
      "set(MZ_ZLIB_FLAVOR zlib)"
      "set(MZ_BZIP2 OFF)"
      "set(MZ_LZMA OFF)"
      "set(MZ_PPMD OFF)"
      "set(MZ_ZSTD OFF)"
      "set(MZ_LIBCOMP OFF)"
      "set(MZ_FETCH_LIBS OFF)"
      "set(MZ_FORCE_FETCH_LIBS OFF)"
      "set(MZ_PKCRYPT OFF)"
      "set(MZ_WZAES OFF)"
      "set(MZ_OPENSSL OFF)"
      "set(MZ_LIBBSD OFF)"
      "set(MZ_ICONV OFF)"
      "set(MZ_COMPRESS_ONLY OFF)"
      "set(MZ_DECOMPRESS_ONLY OFF)"
      "set(MZ_FILE32_API OFF)"
      "set(MZ_BUILD_TESTS OFF)"
      "set(MZ_BUILD_UNIT_TESTS OFF)"
      "set(MZ_BUILD_FUZZ_TESTS OFF)"
      "set(MZ_CODE_COVERAGE OFF)"
      "set(MZ_SANITIZER OFF)"
      "if(NOT ${ALICEVISION_INSTALL_THIRD_PARTY})
        set(SKIP_INSTALL_ALL ON)
        set(SKIP_INSTALL_LIBRARIES ON)
      else()
        set(SKIP_INSTALL_ALL OFF)
        set(SKIP_INSTALL_LIBRARIES OFF)
      endif()"
)

# Create compatibility targets
if(NOT TARGET MINIZIP::minizip-ng)
  add_library(MINIZIP::minizip-ng ALIAS minizip)
endif()

if(NOT TARGET zip::zip)
  add_library(zip::zip ALIAS minizip)
endif()