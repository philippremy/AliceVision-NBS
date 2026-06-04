# Utility modules

These modules provide shared helpers for dependency integration and configuration
behavior.

---

## ApplyGitPatchSafe.cmake
- Safe patch application wrapper for FetchContent.
- Expected `-D` variables:
  - `PATCH_WORKDIR`, `PATCH_FILE`, optional `GIT_EXECUTABLE`, `QUIET`.
- Behavior:
  - If patch already applied → success (silent if `QUIET=ON`).
  - If patch can apply → apply it.
  - Otherwise → succeed silently.
- Requires CMake >= 3.30.

---

## BeQuiet.cmake
- Intended for use via `CMAKE_PROJECT_INCLUDE_BEFORE`.
- Temporarily sets `CMAKE_MESSAGE_LOG_LEVEL=ERROR` to silence subproject
  messages, unless `ALICEVISION_LOG_THIRD_PARTY_CONFIGURE` is ON.
- Uses `cmake_language(DEFER ...)` to restore the original log level.

---

## CheckDependencyVersion.cmake
- Provides semver‑ish range parsing and version checks.
- Public API:
  - `vr_parse(<range> OUT_MIN ... OUT_EXACT ...)`
  - `alicevision_check_dependency_version(<range> <version> <out_var>)`
- Supports prefix ranges like `3`, `3.5` and ranges like
  `1.2...<3`, `1.2...<=3`.
- Note: header comment still says “VersionRange.cmake”.

---

## EnsureDependency.cmake
- Primary entry point for dependency resolution.
- `alicevision_ensure_dependency(<name> ...)`:
  - tries CONFIG `find_package()` first,
  - optionally falls back to MODULE mode,
  - optionally retries with `LEGACY_SUPPORT_VERSION`,
  - otherwise includes `Build_<name>.cmake` and uses FetchContent.
- Includes `alicevision_push_appleclang_openmp()` /
  `alicevision_pop_appleclang_openmp()` helpers to temporarily add known
  package‑manager OpenMP prefixes on macOS.
- Apple universal builds always attempt system BLAS/LAPACK first.

---

## FixupTargetFolders.cmake
- Defines `alicevision_fixup_thirdparty_ide_folder(...)`.
- Moves existing targets into a `third-party/...` folder tree in IDEs.
- See `post-configure-fixups.md` for details.

---

## FixupTargetWarningFlags.cmake
- Defines `alicevision_ensure_target_nowarn(...)`.
- Disables warnings on third‑party targets (unless
  `ALICEVISION_PRINT_THIRD_PARTY_WARNINGS` is ON).
- See `post-configure-fixups.md` for details.

---

## IntegrateDependency.cmake
- `alicevision_integrate_dependency(<dep> ...)` wraps FetchContent integration.
- Supports:
  - `CMAKE_EVAL_CODE` to set upstream options before configuration.
  - `PATCH_STEP` to apply a Git patch via `ApplyGitPatchSafe.cmake`.
  - `SOURCE_SUBDIR` / `SUBMODULE_NAME`.
  - `CMAKE_EVAL_COMPAT_CODE` for post‑configure compatibility tweaks.
- Silences noisy third‑party configure output via `BeQuiet.cmake`.

---

## OpenMPFlags.cmake
- Minimal extraction from CMake’s `FindOpenMP` to detect **compiler flags**
  only (no libraries or version discovery).
- Uses `try_compile()` with `STATIC_LIBRARY` target type to avoid link steps.
- Supports `C`, `CXX`, `CUDA`, `Fortran`.

---

## Licensing
- `utils/LICENSE.md` applies to `OpenMPFlags.cmake` (BSD‑3-Clause).
