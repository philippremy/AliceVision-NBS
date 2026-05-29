# =============================================================================
# Build_libdeflate.cmake - Integrates an embedded libdeflate into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(libdeflate
    CMAKE_EVAL_CODE
      "set(LIBDEFLATE_IS_TOP_LEVEL_PROJECT OFF)"
      "set(LIBDEFLATE_BUILD_STATIC_LIB ${BUILD_STATIC_LIBS})"
      "set(LIBDEFLATE_BUILD_SHARED_LIB ${BUILD_SHARED_LIBS})"
      "set(LIBDEFLATE_COMPRESSION_SUPPORT ON)"
      "set(LIBDEFLATE_DECOMPRESSION_SUPPORT ON)"
      "set(LIBDEFLATE_ZLIB_SUPPORT ON)"
      "set(LIBDEFLATE_GZIP_SUPPORT ON)"
      "set(LIBDEFLATE_FREESTANDING OFF)"
      "set(LIBDEFLATE_BUILD_GZIP OFF)"
      "set(LIBDEFLATE_BUILD_TESTS OFF)"
      "set(LIBDEFLATE_INSTALL ${ALICEVISION_INSTALL_THIRD_PARTY})"
      "set(LIBDEFLATE_APPLE_FRAMEWORK OFF)"
)