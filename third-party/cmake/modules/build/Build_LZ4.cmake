# =============================================================================
# Build_ZLIB.cmake - Integrates an embedded zlib into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(LZ4
    SOURCE_SUBDIR "build/cmake"
    CMAKE_EVAL_CODE
      "set(LZ4_BUILD_CLI OFF)"
      "set(LZ4_BUILD_LEGACY_LZ4C OFF)"
      "set(LZ4_BUNDLED_MODE OFF)"   # Otherwise shared libraries are not available
      "set(BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})"
      "set(BUILD_STATIC_LIBS ${BUILD_STATIC_LIBS})"
      "set(LZ4_POSITION_INDEPENDENT_LIB ON)"
    CMAKE_EVAL_COMPAT_CODE
      "if(NOT TARGET lz4::lz4)
          if(TARGET lz4_shared)
            add_library(lz4::lz4 ALIAS lz4_shared)
          elseif(TARGET lz4_static)
            add_library(lz4::lz4 ALIAS lz4_static)
          endif()
       endif()"
)