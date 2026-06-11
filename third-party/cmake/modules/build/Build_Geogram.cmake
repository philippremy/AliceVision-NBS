# =============================================================================
# Build_Geogram.cmake - Integrates an embedded Geogram into the project
#
# NOTE:
# I have yet to encounter a CMake build system so intransparent as the one from
# Geogram. It really does *everything* to make cross-platform builds unstable
# and unpredictable. Globbing source files? Yes. Randomly including other
# dependency sources? Done. Can we turn that off reliably? No.
# 
#   :°[   (cries in build system)
# 
# Special cases considered:
# - Create target Geogram::geogram if it does not exist
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

# Geogram requires VORPALINE_PLATFORM to be detected and set, so we include it
# here (this is just a copy of the upstream Geogram file)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/SetVorpalinePlatform.cmake)

alicevision_integrate_dependency(Geogram
    SUBMODULE_NAME "geogram"
    PATCH_STEP
      "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/build/patch/Geogram-CPack-InternalZLIB-RelativeLinkLibraryDir-Docs.patch"
    CMAKE_EVAL_CODE
      "set(GEOGRAM_SUB_BUILD ON)"
      "set(GEOGRAM_WITH_GRAPHICS OFF)"
      "set(GEOGRAM_WITH_LEGACY_NUMERICS OFF)"
      "set(GEOGRAM_WITH_HLBFGS OFF)"
      "set(GEOGRAM_WITH_TETGEN OFF)"
      "set(GEOGRAM_WITH_TRIANGLE OFF)"
      "set(GEOGRAM_WITH_LUA OFF)"
      "set(GEOGRAM_LIB_ONLY ON)"
      "set(GEOGRAM_WITH_FPG OFF)"
      "set(GEOGRAM_USE_SYSTEM_GLFW3 OFF)"
      "set(GEOGRAM_WITH_GARGANTUA OFF)"
      "set(GEOGRAM_WITH_TBB ON)"
      "set(GEOGRAM_FOR_DEBIAN OFF)"
      "set(GEOGRAM_WITH_GEOGRAMPLUS OFF)"
      "set(GEOGRAM_WITH_EXPLORAGRAM OFF)"
      "set(VORPALINE_BUILD_DYNAMIC ${BUILD_SHARED_LIBS})"
      "set(GEOGRAM_USE_BUILTIN_DEPS ON)"
)

if(NOT TARGET Geogram::geogram)
  add_library(Geogram::geogram ALIAS geogram)
endif()