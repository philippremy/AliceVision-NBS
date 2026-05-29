# =============================================================================
# Build_OpenEXR.cmake - Integrates an embedded OpenEXR into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(OpenEXR
    SUBMODULE_NAME "openexr"
    CMAKE_EVAL_CODE
      "set(OPENEXR_INSTALL_PKG_CONFIG ${ALICEVISION_INSTALL_THIRD_PARTY})"
      "set(OPENEXR_ENABLE_THREADING ON)"
      "set(OPENEXR_USE_TBB ON)"
      "set(OPENEXR_INSTALL ${ALICEVISION_INSTALL_THIRD_PARTY})"
      "set(OPENEXR_BUILD_LIBS ON)"
      "set(OPENEXR_BUILD_TOOLS OFF)"
      "set(OPENEXR_INSTALL_TOOLS OFF)"
      "set(OPENEXR_INSTALL_DEVELOPER_TOOLS OFF)"
      "set(OPENEXR_BUILD_EXAMPLES OFF)"
      "set(OPENEXR_BUILD_PYTHON OFF)"
      "set(OPENEXR_BUILD_OSS_FUZZ OFF)"
      "set(OPENEXR_TEST_LIBRARIES OFF)"
      "set(OPENEXR_TEST_TOOLS OFF)"
      "set(OPENEXR_TEST_PYTHON OFF)"
      "set(OPENEXR_IS_SUBPROJECT ON)"
      "set(OPENEXR_FORCE_INTERNAL_DEFLATE OFF)"
      "set(OPENEXR_FORCE_INTERNAL_OPENJPH OFF)"
      "set(OPENEXR_FORCE_INTERNAL_IMATH OFF)"
)