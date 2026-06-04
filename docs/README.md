# CMake modules overview

This folder collects AliceVision’s third‑party integration helpers. It groups
FetchContent-based build wrappers, custom Find modules, and utility helpers for
dependency resolution and post‑configure cleanup.

## Layout

- `build/`
  - `Build_<Dep>.cmake` modules that integrate embedded dependencies via
    `FetchContent`.
  - `patch/` contains Git patches applied during FetchContent integration.
- `find/`
  - `Find<Package>.cmake` modules for system dependency discovery.
  - `LICENSE.md` covers FindLZ4/FindOpenMP (BSD‑3-Clause) and FindSuiteSparse
    (Apache‑2.0 from Ceres).
- `utils/`
  - Helper functions/macros for dependency integration, quiet configure, version
    checking, OpenMP flags detection, and fixups.
  - `LICENSE.md` covers `OpenMPFlags.cmake` (BSD‑3-Clause).

## Typical flow

1. `alicevision_ensure_dependency(<name>)` (in `utils/EnsureDependency.cmake`)
   tries `find_package()` in CONFIG mode (and MODULE mode when allowed).
2. If not found and embedded builds are permitted, it includes
   `build/Build_<name>.cmake`.
3. Build modules call `alicevision_integrate_dependency()` (in
   `utils/IntegrateDependency.cmake`), which:
   - sets upstream cache variables (`CMAKE_EVAL_CODE`),
   - applies patches when requested (`PATCH_STEP` → `ApplyGitPatchSafe.cmake`),
   - suppresses noisy configure output via `BeQuiet.cmake`.

## Licensing

- `find/LICENSE.md` covers `FindLZ4.cmake`, `FindOpenMP.cmake`, and
  `FindSuiteSparse.cmake` (Ceres Apache‑2.0 text).
- `utils/LICENSE.md` covers `OpenMPFlags.cmake`.
