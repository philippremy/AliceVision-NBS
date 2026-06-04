# =============================================================================
# SuiteSparseConfigVersion.cmake - A helper module to accompany the
# SuiteSparseConfig.cmake helper file, which checks the installed SuiteSparse
# version and provides the find_package(SuiteSparse) call with a version from
# SuiteSparse_config.
# =============================================================================

# This is *very* dirty what we are doing here, because we should not try to
# find a dependency here. But we are trying for SuiteSparse_config, which
# holds the version number

include(CMakeFindDependencyMacro)

find_dependency(SuiteSparse_config)

if(SuiteSparse_config_FOUND)
  if(DEFINED SUITESPARSE_CONFIG_VERSION)
    if(${SUITESPARSE_CONFIG_VERSION} VERSION_GREATER_EQUAL ${PACKAGE_FIND_VERSION})
      set(SuiteSparse_VERSION ${SUITESPARSE_CONFIG_VERSION} CACHE STRING "SuiteSparse Version" FORCE)
      set(PACKAGE_VERSION_COMPATIBLE TRUE)
    endif()
  endif()
endif()
