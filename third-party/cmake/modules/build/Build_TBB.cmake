# =============================================================================
# Build_TBB.cmake - Integrates an embedded oneTBB into the project
#
# Special cases considered:
# - Patches the Clang.cmake file in oneTBB's compiler helpers to allow building
# a universal binary on Apple platforms when an LLVM Clang is used instead of
# AppleClang provided by Xcode.
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/IntegrateDependency.cmake)

alicevision_integrate_dependency(TBB
    SUBMODULE_NAME "oneTBB"
    PATCH_STEP
      # Required to support building universal binaries with LLVM Clang on
      # Apple platforms
      "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/build/patch/oneTBB-LLVMClang-OSXArchitectures.patch"
    CMAKE_EVAL_CODE
      "set(TBB_TEST OFF)"
      "set(TBB_EXAMPLES OFF)"
      "set(TBB_STRICT OFF)"
      "set(TBB_WINDOWS_DRIVER OFF)"
      "set(TBB_NO_APPCONTAINER OFF)"
      "set(TBB4PY_BUILD OFF)"
      "set(TBB_BUILD ON)"
      "set(TBBMALLOC_BUILD OFF)"
      "set(TBBMALLOC_PROXY_BUILD OFF)"
      "set(TBB_FIND_PACKAGE OFF)"
      "set(TBB_DISABLE_HWLOC_AUTOMATIC_SEARCH ON)"
      "set(TBB_ENABLE_IPO ON)"
      "set(TBB_CONTROL_FLOW_GUARD OFF)"
      "set(TBB_FUZZ_TESTING OFF)"
      "set(TBB_INSTALL ${ALICEVISION_INSTALL_THIRD_PARTY})"
      "set(TBB_BUILD_APPLE_FRAMEWORKS OFF)"
      "set(TBB_OUTPUT_DIR_BASE _deps/tbb-build/out)"
)