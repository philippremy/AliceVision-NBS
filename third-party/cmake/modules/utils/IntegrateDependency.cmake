# =============================================================================
# IntegrateDependency.cmake - Contains a helper function to build a specific
# dependency from source by integrating it into the project tree with
# CMake's FetchContent module.
# =============================================================================

include_guard(DIRECTORY)

# =============================================================================
# Integrates a dependency into the project tree as a subproject

# Call signature:
# alicevision_integrate_dependency(<DEP_NAME>
#    [CMAKE_EVAL_CODE...]
#    [PATCH_STEP...]
#    [SOURCE_SUBDIR <SOURCE_DIR>]
#    [SUBMODULE_NAME <NAME>]
# )
# =============================================================================
function(alicevision_integrate_dependency AV_DEP_NAME)

  include(FetchContent)

  # Parse the key value pairs which we should set
  cmake_parse_arguments(PARSE_ARGV 0 AV_DEP
      ""
      "SOURCE_SUBDIR;SUBMODULE_NAME"
      "CMAKE_EVAL_CODE;PATCH_STEP"
  )

  # Extract the key and value for each passed option
  foreach(AV_DEP_OPTION_KV IN LISTS AV_DEP_CMAKE_EVAL_CODE)
    message(TRACE "[alicevision_integrate_dependency] Evaluating option: ${AV_DEP_OPTION_KV}")
    cmake_language(EVAL CODE "${AV_DEP_OPTION_KV}")
  endforeach()

  # The user may have provided a special name because submodule and dependency
  # name differ
  if(NOT DEFINED AV_DEP_SUBMODULE_NAME)
    set(AV_DEP_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${AV_DEP_NAME}")
  else()
    set(AV_DEP_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${AV_DEP_SUBMODULE_NAME}")
  endif()

  # The user may have provided a special directory where the CMakeLists.txt is
  # located
  set(AV_DEP_SOURCE_SUBDIR_ARGS)
  if(DEFINED AV_DEP_SOURCE_SUBDIR)
    list(APPEND AV_DEP_SOURCE_SUBDIR_ARGS "SOURCE_SUBDIR")
    list(APPEND AV_DEP_SOURCE_SUBDIR_ARGS "${AV_DEP_SOURCE_SUBDIR}")
  endif()

  # Build the patch step arguments if required
  set(AV_DEP_PATCH_STEP_FC_EXPANDED)
  if(DEFINED AV_DEP_PATCH_STEP)
    list(APPEND AV_DEP_PATCH_STEP_FC_EXPANDED "UPDATE_DISCONNECTED")
    list(APPEND AV_DEP_PATCH_STEP_FC_EXPANDED "1")
    list(APPEND AV_DEP_PATCH_STEP_FC_EXPANDED "PATCH_STEP")
    list(APPEND AV_DEP_PATCH_STEP_FC_EXPANDED "${AV_DEP_PATCH_STEP}")
  endif()

  # Declare the dependency
  FetchContent_Declare(${AV_DEP_NAME}
      SOURCE_DIR ${AV_DEP_SOURCE_DIR}
      ${AV_DEP_SOURCE_SUBDIR_ARGS}
      OVERRIDE_FIND_PACKAGE
      EXCLUDE_FROM_ALL
      ${AV_DEP_PATCH_STEP_FC_EXPANDED}
  )

  # Make it available and configure it
  message(STATUS "Configuring third-party dependency ${AV_DEP_NAME}...")

  # Add the BeQuiet option
  set(CMAKE_PROJECT_INCLUDE_BEFORE "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/utils/BeQuiet.cmake")

  # Make FetchContent_MakeAvailable silent as well
  if(NOT ALICEVISION_LOG_THIRD_PARTY_CONFIGURE)
    cmake_language(GET_MESSAGE_LOG_LEVEL AV_GLOBAL_LOG_LEVEL)
    set(CMAKE_MESSAGE_LOG_LEVEL "ERROR" CACHE STRING "The CMake Message log level" FORCE)
  endif()

  # FetchContent_MakeAvailable
  FetchContent_MakeAvailable(${AV_DEP_NAME})

  # Reset CMAKE_PROJECT_INCLUDE_BEFORE
  unset(CMAKE_PROJECT_INCLUDE_BEFORE)

  # Reset log level
  if(NOT ALICEVISION_LOG_THIRD_PARTY_CONFIGURE)
    set(CMAKE_MESSAGE_LOG_LEVEL ${AV_GLOBAL_LOG_LEVEL} CACHE STRING "The CMake Message log level" FORCE)
  endif()

  message(STATUS "Configured third-party dependency ${AV_DEP_NAME}.")

endfunction()