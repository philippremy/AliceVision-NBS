# =============================================================================
# SuiteSparseConfig.cmake - A helper module to wrap the Ceres call to
# find_package(SuiteSparse) to the actual calls to find_package(<COMPONENT>),
# which are provided by SuiteSparse. This allows us to use CONFIG mode for a
# more robust solution on finding SuiteSparse without breaking the
# FindSuiteSparse.cmake module that Ceres uses.
# =============================================================================

# Ceres expects the following SuiteSparse components to be available:
#
# AMD
# CAMD
# CCOLAMD
# CHOLMOD
# COLAMD
# SPQR

include(CMakeFindDependencyMacro)

# These must be in the order of their dependencies, i.e., CHOLMOD must be found
# after COLAMD, because CHOLMOD depends on COLAMD and expects the target to be
# available already.
set(SuiteSparse_COMPONENTS
  SuiteSparse_config
  AMD
  CAMD
  CCOLAMD
  COLAMD
  CHOLMOD
  SPQR
)

foreach(SuiteSparse_COMPONENT IN LISTS SuiteSparse_COMPONENTS)

  # Try a quiet find_dependency call to try find the components
  # individually
  find_dependency(${SuiteSparse_COMPONENT})
  if(NOT ${SuiteSparse_COMPONENT}_FOUND)
    set(SuiteSparse_FOUND FALSE)
    return()
  endif()

  # If the component is SuiteSparse_config, we must create an ALIAS library
  # because Ceres expects SuiteSparse::Config to be defined as a target.
  if(${SuiteSparse_COMPONENT} STREQUAL "SuiteSparse_config"
     AND TARGET SuiteSparse::SuiteSparseConfig
     AND NOT TARGET SuiteSparse::Config)

    add_library(SuiteSparse::Config ALIAS SuiteSparse::SuiteSparseConfig)

  endif()

endforeach()

set(SuiteSparse_FOUND TRUE)
