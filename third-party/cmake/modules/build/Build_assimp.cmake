# =============================================================================
# Build_assimp.cmake - Integrates an embedded assimp into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(assimp
    CMAKE_EVAL_CODE
      "set(ASSIMP_HUNTER_ENABLED OFF)"
      "set(BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})"
      "set(ASSIMP_BUILD_FRAMEWORK OFF)"
      "set(ASSIMP_DOUBLE_PRECISION OFF)"
      "set(ASSIMP_OPT_BUILD_PACKAGES OFF)"
      "set(ASSIMP_ANDROID_JNIIOSYSTEM OFF)"
      "set(ASSIMP_NO_EXPORT OFF)"
      "set(ASSIMP_BUILD_ZLIB OFF)"
      "set(ASSIMP_BUILD_ALL_EXPORTERS_BY_DEFAULT ON)"
      "set(ASSIMP_BUILD_ALL_IMPORTERS_BY_DEFAULT ON)"
      "set(ASSIMP_BUILD_ASSIMP_TOOLS OFF)"
      "set(ASSIMP_BUILD_SAMPLES OFF)"
      "set(ASSIMP_BUILD_TESTS OFF)"
      "set(ASSIMP_COVERALLS OFF)"
      "set(ASSIMP_INSTALL ${ALICEVISION_INSTALL_THIRD_PARTY})"
      "set(ASSIMP_WARNINGS_AS_ERRORS OFF)"
      "set(ASSIMP_ASAN OFF)"
      "set(ASSIMP_UBSAN OFF)"
      "set(ASSIMP_BUILD_DOCS OFF)"
      "set(ASSIMP_INJECT_DEBUG_POSTFIX OFF)"
      "set(ASSIMP_IGNORE_GIT_HASH ON)"
      "set(ASSIMP_INSTALL_PDB OFF)"
      "set(ASSIMP_BUILD_DRACO OFF)"
      "set(ASSIMP_BUILD_ASSIMP_VIEW OFF)"
      "set(ASSIMP_BUILD_USD_IMPORTER OFF)"
)