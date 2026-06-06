# =============================================================================
# Build_minizip-ng.cmake - Integrates an embedded minizip-ng into the project
#
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(minizip-ng
    CMAKE_EVAL_CODE
      "set(MZ_COMPAT OFF)"
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

# Add ZLIB::ZLIB if in a static build
if(NOT TARGET ZLIB::ZLIB)
  if(TARGET ZLIB::ZLIBSTATIC)
    add_library(__zlib_interface INTERFACE)
    target_link_libraries(__zlib_interface INTERFACE ZLIB::ZLIBSTATIC)
    get_target_property(zlib_static_inc_dirs ZLIB::ZLIBSTATIC INCLUDE_DIRECTORIES)
    target_include_directories(__zlib_interface INTERFACE ${zlib_static_inc_dirs})
    add_library(ZLIB::ZLIB ALIAS __zlib_interface)
  else()
    message(FATAL_ERROR "Target ZLIB::ZLIB is not defined after configuring ZLIB, but ZLIB::ZLIBSTATIC is not available as well!")
  endif()
endif()