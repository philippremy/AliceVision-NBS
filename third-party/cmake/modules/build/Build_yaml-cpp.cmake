# =============================================================================
# Build_yaml-cpp.cmake - Integrates an embedded yaml-cpp into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(yaml-cpp
    CMAKE_EVAL_CODE
      "set(YAML_CPP_BUILD_CONTRIB ON)"
      "set(YAML_CPP_BUILD_TOOLS OFF)"
      "set(YAML_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})"
      "set(YAML_CPP_INSTALL ${ALICEVISION_INSTALL_THIRD_PARTY})"
      "set(YAML_CPP_FORMAT_SOURCE OFF)"
      "if(NOT ${ALICEVISION_INSTALL_THIRD_PARTY})
        set(YAML_CPP_DISABLE_UNINSTALL ON)
      else()
        set(YAML_CPP_DISABLE_UNINSTALL OFF)
      endif()"
      "set(YAML_USE_SYSTEM_GTEST OFF)"
      "set(YAML_ENABLE_PIC ON)"
      "set(YAML_CPP_USE_STRICT_FLAGS OFF)"
      "set(YAML_CPP_BUILD_TESTS OFF)"
)