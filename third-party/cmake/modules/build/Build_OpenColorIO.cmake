# =============================================================================
# Build_OpenColorIO.cmake - Integrates an embedded OpenColorIO into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(OpenColorIO
    CMAKE_EVAL_CODE
      "set(OCIO_BUILD_APPS OFF)"
      "set(OCIO_BUILD_OPENFX OFF)"
      "set(OCIO_BUILD_NUKE OFF)"
      "set(OCIO_BUILD_TESTS OFF)"
      "set(OCIO_BUILD_GPU_TEST OFF)"
      "set(OCIO_BUILD_DOCS OFF)"
      "set(OCIO_BUILD_PYTHON OFF)"
      "set(OCIO_BUILD_JAVA OFF)"
      "set(OCIO_USE_WINDOWS_UNICODE ON)"
      "set(OCIO_VERBOSE OFF)"
      "set(OCIO_USE_SOVERSION ON)"
      "set(OCIO_WARNING_AS_ERROR OFF)"
      "set(OCIO_ENABLE_SANITIZER OFF)"
      "set(OCIO_USE_SIMD ON)"
      "set(OCIO_USE_OIIO_FOR_APPS OFF)"
      "set(OCIO_DIRECTX_ENABLED OFF)"
      "set(OCIO_VULKAN_ENABLED OFF)"
      "set(OCIO_INSTALL_EXT_PACKAGES MISSING)"
)