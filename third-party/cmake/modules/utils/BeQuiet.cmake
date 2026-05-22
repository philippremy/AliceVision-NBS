# =============================================================================
# BeQuiet.cmake -  Causes a project to not emit any message() calls (error
# messages are printed).
#
# Can be disabled if the user specifies ALICEVISION_LOG_THIRD_PARTY_CONFIGURE
# to be TRUE.
#
# To be used with CMAKE_PROJECT_INCLUDE_BEFORE.
# =============================================================================

# Only print hard errors unless the user opted-out
if(NOT ALICEVISION_LOG_THIRD_PARTY_CONFIGURE)

  # Query the current logging level
  cmake_language(GET_MESSAGE_LOG_LEVEL __AV_GLOBAL_LOG_LEVEL)

  # ===========================================================================
  # Resets the log level at the end of the current CMakeLists.txt file to reset
  # the log level to the global standard
  # ===========================================================================
  function(__alicevision_reset_log_level)
    # Runs through a deferred call at the end
    set(CMAKE_MESSAGE_LOG_LEVEL ${__AV_GLOBAL_LOG_LEVEL} CACHE STRING "The CMake Message log level" FORCE)
  endfunction()

  # Temporarily sets the message log level to ERROR
  set(CMAKE_MESSAGE_LOG_LEVEL "ERROR" CACHE STRING "The CMake Message log level" FORCE)

  # Registers the reset function to be run at the very end of the top-level
  # CMakeLists.txt file of the subproject.
  cmake_language(DEFER CALL __alicevision_reset_log_level)
endif()