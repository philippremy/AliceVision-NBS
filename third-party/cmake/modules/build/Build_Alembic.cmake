# =============================================================================
# Build_Alembic.cmake - Integrates an embedded Alembic into the project
#
# Special cases considered:
# - Currently none
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(Alembic
    SUBMODULE_NAME "alembic"
    PATCH_STEP
      "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/build/patch/Alembic-CPack-ExportTargets.patch"
    CMAKE_EVAL_CODE
      "set(USE_ARNOLD OFF)"
      "set(USE_BINARIES OFF)"
      "set(USE_EXAMPLES OFF)"
      "set(USE_HDF5 OFF)"
      "set(USE_MAYA OFF)"
      "set(USE_PRMAN OFF)"
      "set(USE_PYALEMBIC OFF)"
      "set(USE_TESTS OFF)"
      "set(ALEMBIC_BUILD_LIBS ON)"
      "set(ALEMBIC_SHARED_LIBS ${BUILD_SHARED_LIBS})"
      "set(ALEMBIC_DEBUG_WARNINGS_AS_ERRORS OFF)"
      "set(DOCS_PATH OFF)"
      "set(CMAKE_UNAME OFF)"  # Alembic forgets to strip newlines
)