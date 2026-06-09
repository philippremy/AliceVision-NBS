# =============================================================================
# Build_XercesC.cmake - Integrates an embedded Xerces-C into the project
#
# Special cases considered:
# - Create target XercesC::XercesC if it does not exist
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(XercesC
    SUBMODULE_NAME "xerces-c"
    PATCH_STEP
      "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/build/patch/XercesC-Tests-Examples-Docs.patch"
    CMAKE_EVAL_CODE
      "set(mfc-debug OFF)"
      "set(extra-warnings OFF)"
      "set(fatal-warnings OFF)"
      "set(network OFF)"
      "set(threads ON)"
)

if(NOT TARGET XercesC::XercesC)
  add_library(XercesC::XercesC ALIAS xerces-c)
endif()