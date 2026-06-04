# Patch overview

This file documents the patches applied during FetchContent integration. Each
patch is referenced by one or more `Build_<Dep>.cmake` modules.

---

## Expat-CPack.patch
- Applied by: `Build_Expat.cmake`
- Files touched: `expat/CMakeLists.txt`
- Summary:
  - Removes the entire CPack configuration block to avoid generating packaging
    targets in a subproject context.

---

## Imath-CMakeDebugPostfixNoCacheVar.patch
- Applied by: `Build_Imath.cmake`
- Files touched: `config/ImathSetup.cmake`
- Summary:
  - Changes `CMAKE_DEBUG_POSTFIX` from a cache variable to a normal variable,
    preventing cache pollution by the subproject.

---

## LZ4-BundledMode-CMakeMinimumRequired.patch
- Applied by: `Build_LZ4.cmake`
- Files touched: `build/cmake/CMakeLists.txt`
- Summary:
  - Raises `cmake_minimum_required` from 3.5 → 3.10.
  - Makes `BUILD_SHARED_LIBS` a normal option (not dependent on bundled mode).

---

## OpenBLAS-CMakeBinaryDir-ArchiveOutputFolder.patch
- Applied by: `Build_BLAS.cmake`
- Files touched: `CMakeLists.txt` (OpenBLAS)
- Summary:
  - Uses `CMAKE_CURRENT_BINARY_DIR` instead of `CMAKE_BINARY_DIR` for generated
    headers, response file paths, and helper files.
  - Fixes static library output path on Apple Makefiles to honor build‑type
    subdirectories.
  - Sets shared library `LINKER_LANGUAGE` to C for LLVMFlang on Apple.
  - Ensures lapacke/lapack headers are generated in the current binary dir.

---

## OpenColorIO-sse2neonBaseDir-CMakeBinaryDir.patch
- Applied by: `Build_OpenColorIO.cmake`
- Files touched:
  - `share/cmake/modules/install/InstallDirectX-Headers.cmake`
  - `share/cmake/modules/install/Installsse2neon.cmake`
  - `share/cmake/utils/CheckSupport*.cmake`
- Summary:
  - Moves FetchContent and `CMakeTmp` work dirs from `CMAKE_BINARY_DIR` to
    `CMAKE_CURRENT_BINARY_DIR` / `PROJECT_BINARY_DIR`, preventing collisions
    in subproject builds.
  - Updates all SIMD capability checks (AVX/SSE/F16C/SSE2NEON) to use the
    current binary dir.

---

## SuiteSparse-TryCompileBLAS-ExportTargets.patch
- Applied by: `Build_SuiteSparse.cmake` (when `AV_BLAS_IS_EMBEDDED`)
- Files touched:
  - `AMD/CMakeLists.txt`, `CAMD/CMakeLists.txt`, `CCOLAMD/CMakeLists.txt`,
    `CHOLMOD/CMakeLists.txt`, `COLAMD/CMakeLists.txt`, `SPQR/CMakeLists.txt`
  - `SuiteSparse_config/cmake_modules/SuiteSparse__blas_threading.cmake`
- Summary:
  - Removes intermediate `export()` calls that generate temporary target files.
  - Replaces OpenBLAS try_compile/try_run checks with a fixed assumption of
    OpenBLAS ≥ 0.3.27, avoiding run‑time tests during configure.
  - Cleans `CMAKE_REQUIRED_*` variables after the check.

---

## flann-CMake-GTest-CPack.patch
- Applied by: `Build_flann.cmake`
- Files touched:
  - `CMakeLists.txt`
  - `cmake/flann.pc.in`
  - `cmake/flann_utils.cmake`
  - `src/cpp/CMakeLists.txt`
- Summary:
  - Raises `cmake_minimum_required` from 2.8.12 → 3.10.
  - Removes uninstall target and all CPack packaging configuration.
  - Replaces `pkg-config` LZ4 lookup with `find_package(LZ4 REQUIRED)`.
  - Removes ExternalProject googletest and gtest helper macros.
  - Links `flann_cpp` libs to `lz4::lz4` and `OpenMP::OpenMP_CXX` when available.
  - Updates `.pc` file to link `-llz4`.

---

## oneTBB-LLVMClang-OSXArchitectures.patch
- Applied by: `Build_TBB.cmake`
- Files touched: `cmake/compilers/Clang.cmake`
- Summary:
  - Uses `CMAKE_OSX_ARCHITECTURES` (if set) to determine target architectures,
    ensuring proper flag selection for universal builds with LLVM Clang.

---

## openjph-IncludeDirs-CMakeBinaryDir.patch
- Applied by: `Build_openjph.cmake`
- Files touched:
  - `CMakeLists.txt`
  - `src/core/CMakeLists.txt`
  - `target_arch.cmake`
- Summary:
  - Writes the pkg‑config file into `CMAKE_CURRENT_BINARY_DIR`.
  - Adds `src/core` as a build‑interface include directory for `openjph`.
  - Uses `CMAKE_CURRENT_BINARY_DIR` for `target_arch` probe file generation.

---

## zlib-CPack.patch
- Applied by: `Build_ZLIB.cmake`
- Files touched: `CMakeLists.txt`
- Summary:
  - Removes `include(CPack)` to prevent packaging targets in subprojects.
