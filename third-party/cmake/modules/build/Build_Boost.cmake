# =============================================================================
# Build_Boost.cmake - Integrates an embedded Boost into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(Boost
    CMAKE_EVAL_CODE
      "set(BOOST_INCLUDE_LIBRARIES
        atomic
        container
        date_time
        graph
        headers
        json
        log
        program_options
        regex
        serialization
        system
        thread
        timer
        test)"
      "set(BUILD_TESTING OFF)"
      "set(BOOST_IOSTREAMS_ENABLE_ZLIB OFF)"
      "set(BOOST_IOSTREAMS_ENABLE_BZIP2 OFF)"
      "set(BOOST_IOSTREAMS_ENABLE_LZMA OFF)"
      "set(BOOST_IOSTREAMS_ENABLE_ZSTD OFF)"
      "if(${ALICEVISION_INSTALL_THIRD_PARTY})
        set(BOOST_SKIP_INSTALL_RULES ON)
       endif()"
)