# Post‑configure fixups

These helpers are meant to be called **after** third‑party targets are created,
to adjust IDE organization and warning behavior.

---

## FixupTargetFolders.cmake
**Function:** `alicevision_fixup_thirdparty_ide_folder(START_DIR)`

- Recursively walks all subdirectories starting at `START_DIR`.
- Computes a folder prefix `third-party/<relative path>`.
- Prepends that prefix to each target’s `FOLDER` property.
- Uses a “seen targets” list to avoid duplicate adjustments.

**Use case:** keep third‑party targets grouped under a consistent `third-party/`
folder in IDEs (e.g., Visual Studio, Xcode).

---

## FixupTargetWarningFlags.cmake
**Function:** `alicevision_ensure_target_nowarn(AV_START_FOLDER)`

- Recursively enumerates targets in `AV_START_FOLDER`.
- Skips non‑compiled target types (e.g., INTERFACE libs, custom).
- Disables warnings for:
  - C/C++ targets (adds `/W0` on MSVC or `-w` on GCC/Clang).
  - Fortran targets (adds `-w` for supported compilers).
- No‑op when `ALICEVISION_PRINT_THIRD_PARTY_WARNINGS=ON`.

**Use case:** silence warnings emitted by embedded third‑party targets without
changing their sources.
