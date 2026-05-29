# =============================================================================
# Build_Expat.cmake - Integrates an embedded Expat into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(Expat
    SOURCE_SUBDIR "expat"
    SUBMODULE_NAME "libexpat"
    CMAKE_EVAL_CODE
      "set(EXPAT_BUILD_TOOLS OFF)"
      "set(EXPAT_BUILD_EXAMPLES OFF)"
      "set(EXPAT_BUILD_TESTS OFF)"
      "if(${BUILD_SHARED_LIBS})
        set(EXPAT_SHARED_LIBS ON)
      else()
        set(EXPAT_SHARED_LIBS OFF)
      endif()"
      "set(EXPAT_BUILD_DOCS OFF)"
      "set(EXPAT_BUILD_FUZZERS OFF)"
      "set(EXPAT_BUILD_PKGCONFIG ${ALICEVISION_INSTALL_THIRD_PARTY})"
      "set(EXPAT_OSSFUZZ_BUILD OFF)"
      "set(EXPAT_ENABLE_INSTALL ${ALICEVISION_INSTALL_THIRD_PARTY})"
)