# =============================================================================
# ApplyGitPatchSafe.cmake - Ensures a Git patch is applied safely (without
# failing because it already has been applied) in a cross-platform way.
#
# Expected -D variables:
#   PATCH_WORKDIR : directory where git should run
#   PATCH_FILE    : patch file to apply
#   GIT_EXECUTABLE: git binary (optional; defaults to "git")
#   QUIET         : "ON"/"OFF" (optional; defaults ON)
#
# Semantics:
# - If patch is already applied => success (no output if QUIET=ON)
# - If patch can be applied => apply it (no output if QUIET=ON)
# - Otherwise => success (silent). (You can flip this to fatal if desired.)
# =============================================================================

cmake_minimum_required(VERSION 3.30)

message(TRACE "[ApplyGitPatchSafe] Invoked with PATCH_WORKDIR=${PATCH_WORKDIR}, PATCH_FILE=${PATCH_FILE}, GIT_EXECUTABLE=${GIT_EXECUTABLE}, QUIET=${QUIET}")

if(NOT DEFINED PATCH_WORKDIR OR PATCH_WORKDIR STREQUAL "")
  message(FATAL_ERROR "[ApplyGitPatchSafe] PATCH_WORKDIR is required")
endif()
if(NOT DEFINED PATCH_FILE OR PATCH_FILE STREQUAL "")
  message(FATAL_ERROR "[ApplyGitPatchSafe] PATCH_FILE is required")
endif()

if(NOT DEFINED GIT_EXECUTABLE OR GIT_EXECUTABLE STREQUAL "")
  set(GIT_EXECUTABLE git)
endif()

if(NOT DEFINED QUIET)
  set(QUIET ON)
endif()

# Make paths absolute for safety
get_filename_component(_workdir "${PATCH_WORKDIR}" ABSOLUTE)
get_filename_component(_patch   "${PATCH_FILE}" ABSOLUTE)

if(NOT EXISTS "${_patch}")
  # Per your requirement: fail silently / no-op if missing.
  if(NOT QUIET)
    message(STATUS "[ApplyGitPatchSafe] Patch file not found: ${_patch} (skipping)")
  endif()
  return()
endif()

# Helper to run git and optionally silence output
function(_run_git out_var)
  if(QUIET)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} ${ARGN}
        WORKING_DIRECTORY "${_workdir}"
        RESULT_VARIABLE _rv
        OUTPUT_VARIABLE _out
        ERROR_VARIABLE  _err
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE
    )
  else()
    execute_process(
        COMMAND ${GIT_EXECUTABLE} ${ARGN}
        WORKING_DIRECTORY "${_workdir}"
        RESULT_VARIABLE _rv
    )
  endif()
  set(${out_var} "${_rv}" PARENT_SCOPE)
  set(${out_var}_ERR "${_err}" PARENT_SCOPE)
endfunction()

# 1) Is it already applied?
_run_git(_rv_rev apply --ignore-whitespace --reverse --check "${_patch}")
if(_rv_rev EQUAL 0)
  message(TRACE "[ApplyGitPatchSafe] Patch already applied")
  return()
endif()

# 2) Can it be applied?
_run_git(_rv_chk apply --ignore-whitespace --check "${_patch}")
if(NOT _rv_chk EQUAL 0)
  # can't apply (changed sources etc.) -> succeed silently
  message(TRACE "[ApplyGitPatchSafe] Patch cannot be applied")
  return()
endif()

# 3) Apply it
_run_git(_rv_apply apply --ignore-whitespace "${_patch}")

if(NOT _rv_apply EQUAL 0)
  message(FATAL_ERROR
    "[ApplyGitPatchSafe] Failed to apply patch: ${_patch}\n${_rv_apply_ERR}")
endif()

return()