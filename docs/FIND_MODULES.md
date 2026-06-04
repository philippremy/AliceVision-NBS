# Find modules

These are custom or upstream-derived `Find<Package>.cmake` modules used when
system dependencies are allowed. Most define imported targets and parse version
info from headers.

---

## FindLZ4.cmake
- Upstream CMake module (BSD‑3-Clause; see `find/LICENSE.md`).
- Finds: `lz4` / `lz4d` libraries and headers.
- Version: parsed from `lz4.h` (`LZ4_VERSION_*`).
- Imported target: `lz4::lz4`.
- Output vars: `LZ4_FOUND`, `LZ4_INCLUDE_DIRS`, `LZ4_LIBRARIES`, `LZ4_VERSION`.

---

## FindOpenMP.cmake
- Upstream CMake module (BSD‑3-Clause; see `find/LICENSE.md`).
- Detects OpenMP flags, include dirs, and libraries for C/CXX/Fortran/CUDA.
- Defines imported targets: `OpenMP::OpenMP_<lang>`.
- Sets `OpenMP_*` variables for flags, include dirs, libs, and versions.
- Supports `OpenMP_RUNTIME_MSVC` for MSVC runtime selection.

---

## FindSuiteSparse.cmake
- Derived from Ceres’ FindSuiteSparse (Apache‑2.0; see `find/LICENSE.md`).
- If `SuiteSparse_NO_CMAKE` is **not** set, it first attempts:
  - `find_package(SuiteSparse NO_MODULE QUIET)`
  - If found, it **returns early**.
- Otherwise, it manually locates components and constructs
  `SuiteSparse::<Component>` imported targets.
- Components: AMD, CAMD, CCOLAMD, CHOLMOD, COLAMD, SPQR, Config.
- Resolves external deps:
  - BLAS and LAPACK are required.
  - SPQR optionally links to TBB if found.
  - CHOLMOD optionally links to METIS (and exposes `SuiteSparse::Partition`).
  - `librt` is linked to `SuiteSparse::Config` if available.
- Version parsing: extracts `SuiteSparse_VERSION` from `SuiteSparse_config.h`.
