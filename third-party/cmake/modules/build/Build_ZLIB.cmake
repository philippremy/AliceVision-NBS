# =============================================================================
# Build_ZLIB.cmake - Integrates an embedded zlib into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(ZLIB
    SUBMODULE_NAME "zlib"
    CMAKE_EVAL_CODE
      "set(ZLIB_BUILD_TESTING OFF)"
      "set(ZLIB_BUILD_SHARED ${BUILD_SHARED_LIBS})"
      "set(ZLIB_BUILD_STATIC ${BUILD_STATIC_LIBS})"
      "set(ZLIB_INSTALL ${ALICEVISION_INSTALL_THIRD_PARTY})"
      "set(ZLIB_PREFIX OFF)"
      "set(ZLIB_BUILD_GVMAT64 OFF)"
      "set(ZLIB_BUILD_INFBACK9 OFF)"
      "set(ZLIB_BUILD_CRC32VX OFF)"
      "set(ZLIB_BUILD_ADA OFF)"
      "set(ZLIB_BUILD_BLAST OFF)"
      "set(ZLIB_BUILD_IOSTREAM3 OFF)"
      "set(ZLIB_BUILD_MINIZIP OFF)"
      "set(ZLIB_BUILD_PUFF OFF)"
      "set(ZLIB_BUILD_TESTZLIB OFF)"
      "set(ZLIB_BUILD_ZLIB1_DLL OFF)"
)
