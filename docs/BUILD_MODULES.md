# Build modules (embedded dependencies)

Each `Build_<Dep>.cmake` calls `alicevision_integrate_dependency(...)` and sets
upstream CMake variables via `CMAKE_EVAL_CODE`. This file lists the settings
applied per component, plus patches and extra behavior.

---

## Build_BLAS.cmake (OpenBLAS + LAPACK)
**Two modes:**

**A) Prebuilt (Windows)**
- Trigger: `ALICEVISION_OPENBLAS_PREBUILT=ON`
- Downloads OpenBLAS 0.3.33 ZIP from GitHub depending on architecture:
  - x64: `OpenBLAS-0.3.33-x64.zip`
  - ARM64 static: `OpenBLAS-0.3.33-woa64-static.zip`
  - ARM64 shared: `OpenBLAS-0.3.33-woa64-dll.zip`
- Sets:
  - `BLA_VENDOR=OpenBLAS`
  - `BLA_SIZEOF_INTEGER=4`
  - `LIB=<extracted>/lib` (used by `FindBLAS`)
- Then runs:
  - `find_package(BLAS QUIET REQUIRED MODULE GLOBAL)`
  - `find_package(LAPACK QUIET REQUIRED MODULE GLOBAL)`

**B) Embedded build (OpenBLAS submodule)**
- Submodule: `OpenBLAS`
- Patch: `OpenBLAS-CMakeBinaryDir-ArchiveOutputFolder.patch`
- Settings:
  - `INTERFACE64=OFF`
  - `BUILD_WITHOUT_LAPACK=OFF`
  - `BUILD_WITHOUT_LAPACKE=ON`
  - `BUILD_LAPACK_DEPRECATED=ON`
  - `BUILD_TESTING=OFF`
  - `BUILD_BENCHMARKS=OFF`
  - `C_LAPACK=${ALICEVISION_USE_C_LAPACK}`
  - `NOFORTRAN=${ALICEVISION_USE_C_LAPACK}`
  - `BUILD_WITHOUT_CBLAS=ON`
  - `DYNAMIC_ARCH=OFF`
  - `DYNAMIC_OLDER=OFF`
  - `BUILD_RELAPACK=OFF`
  - `USE_LOCKING=OFF`
  - `USE_PERL=OFF`
  - `FIXED_LIBNAME=OFF`
  - `CPP_THREAD_SAFETY_TEST=OFF`
  - `CPP_THREAD_SAFETY_GEMV=OFF`
  - `BUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}`
  - `BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}`
  - `USE_THREAD=OFF`
  - `USE_OPENMP=OFF`
- Extra behavior:
  - Sets `AV_BLAS_IS_EMBEDDED=ON`.
  - Creates `BLAS::BLAS` alias target if missing.
  - Sets `BLAS_*` cache variables (incl. `BLA_VENDOR=OpenBLAS`,
    `BLA_SIZEOF_INTEGER=4`).
  - Writes `lapack-config.cmake` and `lapack-config-version.cmake` in
    `CMAKE_FIND_PACKAGE_REDIRECTS_DIR` and creates `LAPACK::LAPACK`.

---

## Build_Boost.cmake (Boost)
- Submodule: `boost`
- Settings:
  - `BOOST_INCLUDE_LIBRARIES=atomic;container;date_time;graph;headers;json;log;program_options;regex;serialization;system;thread;timer;test`
  - `BUILD_TESTING=OFF`
  - `BOOST_IOSTREAMS_ENABLE_ZLIB=OFF`
  - `BOOST_IOSTREAMS_ENABLE_BZIP2=OFF`
  - `BOOST_IOSTREAMS_ENABLE_LZMA=OFF`
  - `BOOST_IOSTREAMS_ENABLE_ZSTD=OFF`
  - `BOOST_SKIP_INSTALL_RULES=ON` (only if `ALICEVISION_INSTALL_THIRD_PARTY`)

---

## Build_Ceres.cmake (Ceres Solver)
- Submodule: `ceres-solver`
- Special handling:
  - Temporarily sets `CMAKE_FIND_USE_CMAKE_SYSTEM_PATH=ON` on macOS when
    `ALICEVISION_IGNORE_XCODE_PACKAGES=ON` so Ceres can locate
    `Accelerate.framework`.
- Settings:
  - `SUITESPARSE=ON` only if `ALICEVISION_ALLOW_GPL` and
    `(NOT APPLE OR ALICEVISION_SUITESPARSE_ON_APPLE)`, else `OFF`
  - `ACCELERATESPARSE=ON` on Apple, otherwise `OFF`
  - `USE_CUDA=OFF`
  - `LAPACK=ON`
  - `SCHUR_SPECIALIZATIONS=ON`
  - `CUSTOM_BLAS=ON`
  - `EIGENSPARSE=ON`
  - `EIGENMETIS=OFF`
  - `BUILD_TESTING=OFF`
  - `BUILD_DOCUMENTATION=OFF`
  - `BUILD_EXAMPLES=OFF`
  - `BUILD_BENCHMARKS=OFF`
  - `PROVIDE_UNINSTALL_TARGET=${ALICEVISION_INSTALL_THIRD_PARTY}`
  - `ABSL_ENABLE_INSTALL=${ALICEVISION_INSTALL_THIRD_PARTY}`

---

## Build_E57Format.cmake (libE57Format)
- Submodule: `libE57Format`
- Settings:
  - `E57_VERBOSE=OFF`
  - `E57_ENABLE_DIAGNOSTIC_OUTPUT=OFF`
  - `E57_WRITE_CRAZY_PACKET_MODE=OFF`
  - `E57_RELEASE_LTO=OFF`
  - `E57_BUILD_TEST=OFF`
  - `E57FORMAT_SANITIZE_ALL=OFF`
  - `E57FORMAT_SANITIZE_ADDRESS=OFF`
  - `E57FORMAT_SANITIZE_UNDEFINED=OFF`
  - `E57_GIT_SUBMODULE_UPDATE=OFF`

---

## Build_Eigen.cmake (Eigen)
- Submodule: `eigen`
- Settings:
  - `PROJECT_IS_TOP_LEVEL=OFF`
  - `BUILD_TESTING=OFF`
  - `EIGEN_BUILD_TESTING=OFF`
  - `EIGEN_LEAVE_TEST_IN_ALL_TARGET=OFF`
  - `EIGEN_BUILD_BLAS=OFF`
  - `EIGEN_BUILD_LAPACK=OFF`
  - `EIGEN_BUILD_DOC=OFF`
  - `EIGEN_BUILD_DEMOS=OFF`
  - `EIGEN_BUILD_PKGCONFIG=${ALICEVISION_INSTALL_THIRD_PARTY}`
  - `EIGEN_BUILD_CMAKE_PACKAGE=${ALICEVISION_INSTALL_THIRD_PARTY}`

---

## Build_Expat.cmake (Expat)
- Submodule: `libexpat` (source subdir: `expat`)
- Patch: `Expat-CPack.patch`
- Settings:
  - `EXPAT_BUILD_TOOLS=OFF`
  - `EXPAT_BUILD_EXAMPLES=OFF`
  - `EXPAT_BUILD_TESTS=OFF`
  - `EXPAT_SHARED_LIBS=ON` if `BUILD_SHARED_LIBS`, else `OFF`
  - `EXPAT_BUILD_DOCS=OFF`
  - `EXPAT_BUILD_FUZZERS=OFF`
  - `EXPAT_BUILD_PKGCONFIG=${ALICEVISION_INSTALL_THIRD_PARTY}`
  - `EXPAT_OSSFUZZ_BUILD=OFF`
  - `EXPAT_ENABLE_INSTALL=${ALICEVISION_INSTALL_THIRD_PARTY}`

---

## Build_Imath.cmake (Imath)
- Patch: `Imath-CMakeDebugPostfixNoCacheVar.patch`
- Settings:
  - `IMATH_IS_SUBPROJECT=ON`
  - `IMATH_HALF_USE_LOOKUP_TABLE=ON`
  - `IMATH_INSTALL_PKG_CONFIG=${ALICEVISION_INSTALL_THIRD_PARTY}`

---

## Build_LAPACK.cmake (LAPACK)
- No settings. LAPACK is built as part of OpenBLAS.

---

## Build_LEMON.cmake (LEMON)
- Settings:
  - `LEMON_ENABLE_GLPK=OFF`
  - `LEMON_ENABLE_ILOG=OFF`
  - `LEMON_ENABLE_COIN=OFF`
  - `LEMON_ENABLE_SOPLEX=OFF`

---

## Build_LZ4.cmake (LZ4)
- Submodule: `lz4` (source subdir: `build/cmake`)
- Patch: `LZ4-BundledMode-CMakeMinimumRequired.patch`
- Settings:
  - `LZ4_BUILD_CLI=OFF`
  - `LZ4_BUILD_LEGACY_LZ4C=OFF`
  - `LZ4_BUNDLED_MODE=ON`
  - `BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}`
  - `BUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}`
  - `LZ4_POSITION_INDEPENDENT_LIB=ON`
- Compatibility:
  - Adds `lz4::lz4` alias to `lz4_shared` or `lz4_static` if missing.
- Note: file header comment still says “Build_ZLIB”.

---

## Build_OpenColorIO.cmake (OpenColorIO)
- Patch: `OpenColorIO-sse2neonBaseDir-CMakeBinaryDir.patch`
- Settings:
  - `OCIO_BUILD_APPS=OFF`
  - `OCIO_BUILD_OPENFX=OFF`
  - `OCIO_BUILD_NUKE=OFF`
  - `OCIO_BUILD_TESTS=OFF`
  - `OCIO_BUILD_GPU_TEST=OFF`
  - `OCIO_BUILD_DOCS=OFF`
  - `OCIO_BUILD_PYTHON=OFF`
  - `OCIO_BUILD_JAVA=OFF`
  - `OCIO_USE_WINDOWS_UNICODE=ON`
  - `OCIO_VERBOSE=OFF`
  - `OCIO_USE_SOVERSION=ON`
  - `OCIO_WARNING_AS_ERROR=OFF`
  - `OCIO_ENABLE_SANITIZER=OFF`
  - `OCIO_USE_SIMD=ON`
  - `OCIO_USE_OIIO_FOR_APPS=OFF`
  - `OCIO_DIRECTX_ENABLED=OFF`
  - `OCIO_VULKAN_ENABLED=OFF`
  - `OCIO_INSTALL_EXT_PACKAGES=MISSING`

---

## Build_OpenEXR.cmake (OpenEXR)
- Submodule: `openexr`
- Settings:
  - `OPENEXR_INSTALL_PKG_CONFIG=${ALICEVISION_INSTALL_THIRD_PARTY}`
  - `OPENEXR_ENABLE_THREADING=ON`
  - `OPENEXR_USE_TBB=ON`
  - `OPENEXR_INSTALL=${ALICEVISION_INSTALL_THIRD_PARTY}`
  - `OPENEXR_BUILD_LIBS=ON`
  - `OPENEXR_BUILD_TOOLS=OFF`
  - `OPENEXR_INSTALL_TOOLS=OFF`
  - `OPENEXR_INSTALL_DEVELOPER_TOOLS=OFF`
  - `OPENEXR_BUILD_EXAMPLES=OFF`
  - `OPENEXR_BUILD_PYTHON=OFF`
  - `OPENEXR_BUILD_OSS_FUZZ=OFF`
  - `OPENEXR_TEST_LIBRARIES=OFF`
  - `OPENEXR_TEST_TOOLS=OFF`
  - `OPENEXR_TEST_PYTHON=OFF`
  - `OPENEXR_IS_SUBPROJECT=ON`
  - `OPENEXR_FORCE_INTERNAL_DEFLATE=OFF`
  - `OPENEXR_FORCE_INTERNAL_OPENJPH=OFF`
  - `OPENEXR_FORCE_INTERNAL_IMATH=OFF`

---

## Build_OpenMP.cmake (LLVM OpenMP)
- Submodule: `llvm-project` (source subdir: `openmp`)
- Settings:
  - `LIBOMP_FORTRAN_MODULES=OFF`
  - `LIBOMP_FORTRAN_MODULES_ONLY=OFF`
  - `OPENMP_ENABLE_LIBOMPTARGET=OFF`
  - `OPENMP_ENABLE_OMPT_TOOLS=OFF`
  - `OPENMP_STANDALONE_BUILD=ON`
  - `LIBOMP_ENABLE_SHARED=OFF` when `BUILD_STATIC_LIBS` and not `WIN32`, else `ON`
- Extra behavior:
  - Creates `OpenMP::OpenMP_C` and `OpenMP::OpenMP_CXX` interface targets.
  - Uses `OpenMPFlags.cmake` to detect compiler flags.
  - Sets OpenMP cache variables:
    - `OpenMP_VERSION=5.1`
    - `OpenMP_C/CXX_VERSION=5.1`
    - `OpenMP_C/CXX_VERSION_MAJOR=5`
    - `OpenMP_C/CXX_VERSION_MINOR=1`
    - `OpenMP_C/CXX_SPEC_DATE=202011`
    - `OpenMP_C/CXX_FLAGS` and `OpenMP_C/CXX_INCLUDE_DIRS`
    - `OpenMP_C/CXX_LIBRARIES=OpenMP::OpenMP_C/CXX`

---

## Build_SuiteSparse.cmake (SuiteSparse)
- Patch: `SuiteSparse-TryCompileBLAS-ExportTargets.patch`
  (only when `AV_BLAS_IS_EMBEDDED=ON`)
- Settings:
  - `SUITESPARSE_ENABLE_PROJECTS=suitesparse_config;amd;camd;ccolamd;cholmod;colamd;spqr`
  - `SUITESPARSE_USE_CUDA=OFF`
  - `BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}`
  - `BUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}`
  - `SUITESPARSE_USE_64BIT_BLAS=OFF`
  - `SUITESPARSE_USE_PYTHON=OFF`
  - `SUITESPARSE_USE_OPENMP=ON`
  - `SUITESPARSE_USE_FORTRAN=OFF`
  - `SUITESPARSE_C_TO_FORTRAN="(name,NAME) name##_"`
  - `CHOLMOD_GPL=ON`
  - `CHOLMOD_PARTITION=ON`
  - `CHOLMOD_CAMD=ON`
  - `SUITESPARSE_LOCAL_INSTALL=${ALICEVISION_INSTALL_THIRD_PARTY}`
  - `SUITESPARSE_DEMOS=OFF`

---

## Build_TBB.cmake (oneTBB)
- Submodule: `oneTBB`
- Patch: `oneTBB-LLVMClang-OSXArchitectures.patch`
- Settings:
  - `TBB_TEST=OFF`
  - `TBB_EXAMPLES=OFF`
  - `TBB_STRICT=OFF`
  - `TBB_WINDOWS_DRIVER=OFF`
  - `TBB_NO_APPCONTAINER=OFF`
  - `TBB4PY_BUILD=OFF`
  - `TBB_BUILD=ON`
  - `TBBMALLOC_BUILD=OFF`
  - `TBBMALLOC_PROXY_BUILD=OFF`
  - `TBB_FIND_PACKAGE=OFF`
  - `TBB_DISABLE_HWLOC_AUTOMATIC_SEARCH=ON`
  - `TBB_ENABLE_IPO=ON`
  - `TBB_CONTROL_FLOW_GUARD=OFF`
  - `TBB_FUZZ_TESTING=OFF`
  - `TBB_INSTALL=${ALICEVISION_INSTALL_THIRD_PARTY}`
  - `TBB_BUILD_APPLE_FRAMEWORKS=OFF`
  - `TBB_OUTPUT_DIR_BASE=_deps/tbb-build/out`

---

## Build_ZLIB.cmake (zlib)
- Submodule: `zlib`
- Patch: `zlib-CPack.patch`
- Settings:
  - `ZLIB_BUILD_TESTING=OFF`
  - `ZLIB_BUILD_SHARED=${BUILD_SHARED_LIBS}`
  - `ZLIB_BUILD_STATIC=${BUILD_STATIC_LIBS}`
  - `ZLIB_INSTALL=${ALICEVISION_INSTALL_THIRD_PARTY}`
  - `ZLIB_PREFIX=OFF`
  - `ZLIB_BUILD_GVMAT64=OFF`
  - `ZLIB_BUILD_INFBACK9=OFF`
  - `ZLIB_BUILD_CRC32VX=OFF`
  - `ZLIB_BUILD_ADA=OFF`
  - `ZLIB_BUILD_BLAST=OFF`
  - `ZLIB_BUILD_IOSTREAM3=OFF`
  - `ZLIB_BUILD_MINIZIP=OFF`
  - `ZLIB_BUILD_PUFF=OFF`
  - `ZLIB_BUILD_TESTZLIB=OFF`
  - `ZLIB_BUILD_ZLIB1_DLL=OFF`
- Extra behavior:
  - If `ZLIB::ZLIB` is missing, creates an alias from `ZLIB::ZLIBSTATIC`.

---

## Build_flann.cmake (flann)
- Patch: `flann-CMake-GTest-CPack.patch`
- Settings:
  - `BUILD_C_BINDINGS=OFF`
  - `BUILD_PYTHON_BINDINGS=OFF`
  - `BUILD_MATLAB_BINDINGS=OFF`
  - `BUILD_CUDA_LIB=OFF`
  - `BUILD_EXAMPLES=OFF`
  - `BUILD_TESTS=OFF`
  - `BUILD_DOC=OFF`
  - `USE_OPENMP=ON`
  - `USE_MPI=OFF`
  - `HDF5_FOUND=OFF`
  - `HDF5_IS_PARALLEL=OFF`

---

## Build_libdeflate.cmake (libdeflate)
- Settings:
  - `LIBDEFLATE_IS_TOP_LEVEL_PROJECT=OFF`
  - `LIBDEFLATE_BUILD_STATIC_LIB=${BUILD_STATIC_LIBS}`
  - `LIBDEFLATE_BUILD_SHARED_LIB=${BUILD_SHARED_LIBS}`
  - `LIBDEFLATE_COMPRESSION_SUPPORT=ON`
  - `LIBDEFLATE_DECOMPRESSION_SUPPORT=ON`
  - `LIBDEFLATE_ZLIB_SUPPORT=ON`
  - `LIBDEFLATE_GZIP_SUPPORT=ON`
  - `LIBDEFLATE_FREESTANDING=OFF`
  - `LIBDEFLATE_BUILD_GZIP=OFF`
  - `LIBDEFLATE_BUILD_TESTS=OFF`
  - `LIBDEFLATE_INSTALL=${ALICEVISION_INSTALL_THIRD_PARTY}`
  - `LIBDEFLATE_APPLE_FRAMEWORK=OFF`

---

## Build_nanoflann.cmake (nanoflann)
- Settings:
  - `MASTER_PROJECT=OFF`
  - `NANOFLANN_BUILD_EXAMPLES=OFF`
  - `NANOFLANN_BUILD_TESTS=OFF`
  - `MASTER_PROJECT_HAS_TARGET_UNINSTALL=OFF`

---

## Build_openjph.cmake (OpenJPH)
- Submodule: `OpenJPH`
- Patch: `openjph-IncludeDirs-CMakeBinaryDir.patch`
- Settings:
  - `OJPH_ENABLE_TIFF_SUPPORT=OFF`
  - `OJPH_BUILD_TESTS=OFF`
  - `OJPH_BUILD_EXECUTABLES=OFF`
  - `OJPH_BUILD_STREAM_EXPAND=OFF`
  - `OJPH_BUILD_FUZZER=OFF`
- Compatibility:
  - Sets `openjph_VERSION=0.27.3` (cache, FORCE) for OpenEXR’s version checks.
