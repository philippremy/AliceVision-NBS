# =============================================================================
# Build_pystring.cmake - Integrates an embedded pystring into the project
# 
# Special cases considered:
# - Create pystring::pystring target, if it does not exist
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(pystring
    PATCH_STEP
      "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/build/patch/pystring-DisableTests-InlineDefinitions.patch"
    CMAKE_EVAL_CODE
      "set(PYSTRING_HEADER_ONLY ON)"
      "set(BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})"
)

# Create namespaced target if it does not yet exist
if(NOT TARGET pystring::pystring)
  add_library(pystring::pystring ALIAS pystring)
endif()