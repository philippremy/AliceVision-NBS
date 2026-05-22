# =============================================================================
# FixupTargetFolders.cmake - Retrospectively moves targets created before into
# the third-party folder IDE folder
# =============================================================================

function(alicevision_fixup_thirdparty_ide_folder START_DIR)
  # Normalize START_DIR to an absolute path so RELATIVE_PATH is stable.
  get_filename_component(_av_tp_start_abs "${START_DIR}" ABSOLUTE)

  # Track what we already processed to avoid re-setting targets multiple times.
  set(_av_tp_seen_targets "")

  # Inner recursive worker:
  #   DIR_ABS: absolute directory currently being visited
  function(_av_tp_visit DIR_ABS)
    # Compute the directory path relative to START_DIR
    file(RELATIVE_PATH _av_tp_rel "${_av_tp_start_abs}" "${DIR_ABS}")

    # Build the prefix folder (base is always "third-party")
    if(_av_tp_rel STREQUAL "" OR _av_tp_rel STREQUAL ".")
      set(_av_tp_prefix "third-party")
    else()
      # Convert filesystem separators to CMake/IDE-style forward slashes
      file(TO_CMAKE_PATH "${_av_tp_rel}" _av_tp_rel_norm)
      set(_av_tp_prefix "third-party/${_av_tp_rel_norm}")
    endif()

    # Fixup targets in this directory
    get_property(_av_tp_targets DIRECTORY "${DIR_ABS}" PROPERTY BUILDSYSTEM_TARGETS)
    foreach(_t IN LISTS _av_tp_targets)
      if(_t IN_LIST _av_tp_seen_targets)
        continue()
      endif()
      list(APPEND _av_tp_seen_targets "${_t}")
      set(_av_tp_seen_targets "${_av_tp_seen_targets}" PARENT_SCOPE)

      get_target_property(_existing_folder "${_t}" FOLDER)

      if(NOT _existing_folder)
        set_target_properties("${_t}" PROPERTIES FOLDER "${_av_tp_prefix}")
      else()
        # Append existing folder AFTER the computed "third-party/<relative path>" prefix.
        # If someone already set "third-party/..." we won't try to be clever—this is a pure prepend.
        set_target_properties("${_t}" PROPERTIES FOLDER "${_av_tp_prefix}/${_existing_folder}")
      endif()
    endforeach()

    # Recurse into subdirectories
    get_property(_av_tp_subdirs DIRECTORY "${DIR_ABS}" PROPERTY SUBDIRECTORIES)
    foreach(_sd IN LISTS _av_tp_subdirs)
      _av_tp_visit("${_sd}")
    endforeach()
  endfunction()

  _av_tp_visit("${_av_tp_start_abs}")
endfunction()