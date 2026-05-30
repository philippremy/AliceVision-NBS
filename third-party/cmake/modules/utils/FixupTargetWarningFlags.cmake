# =============================================================================
# FixupTargetWarningFlags.cmake - Retrospectively ensures that targets in the
# the folder do not emit any warnings.
# =============================================================================

function(alicevision_ensure_target_nowarn AV_START_FOLDER)

  # Return early if the fixup was explicitly disabled
  if(ALICEVISION_PRINT_THIRD_PARTY_WARNINGS)
    return()
  endif()

  # Get targets in this directory and iteratively fix them up
  get_property(AV_DIRECTORY_TARGETS DIRECTORY ${AV_START_FOLDER} PROPERTY BUILDSYSTEM_TARGETS)
  foreach(AV_TARGET IN LISTS AV_DIRECTORY_TARGETS)

    # Check if the target is a supported type
    # We skip any internal targets as well as INTERFACE_LIBRARY, because it is
    # not compiled
    get_property(AV_TARGET_TYPE TARGET ${AV_TARGET} PROPERTY TYPE)
    if(NOT AV_TARGET_TYPE MATCHES "(STATIC_LIBRARY|MODULE_LIBRARY|SHARED_LIBRARY|OBJECT_LIBRARY|EXECUTABLE)")
      message(TRACE "[alicevision_ensure_target_nowarn] Skipping fixup for warnings on target: ${AV_TARGET} (target is of type ${AV_TARGET_TYPE})")
      continue()
    endif()

    message(TRACE "[alicevision_ensure_target_nowarn] Disabling warnings on target: ${AV_TARGET}")

    # C/C++
    if(MSVC OR (CMAKE_C_COMPILER_ID MATCHES "(GNU|AppleClang|Clang)" AND CMAKE_CXX_COMPILER_ID MATCHES "(GNU|AppleClang|Clang)"))
      target_compile_options(${AV_TARGET}
          PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:$<IF:$<BOOL:${MSVC}>,/W0,-w>>
      )
      message(TRACE "[alicevision_ensure_target_nowarn] Fixed C/C++ warnings on target: ${AV_TARGET}")
    endif()

    # Fortran
    if(CMAKE_Fortran_COMPILER_ID MATCHES "(Flang|LLVMFlang|G95|GNU)")
      target_compile_options(${AV_TARGET}
          PRIVATE $<$<COMPILE_LANGUAGE:Fortran>:-w>
      )
      message(TRACE "[alicevision_ensure_target_nowarn] Fixed Fortran warnings on target: ${AV_TARGET}")
    endif()

  endforeach()

  # Recursively call self for any subdirectories
  get_property(AV_DIRECTORY_SUBDIRS DIRECTORY "${AV_START_FOLDER}" PROPERTY SUBDIRECTORIES)
  foreach(AV_SUBDIRECTORY IN LISTS AV_DIRECTORY_SUBDIRS)
    alicevision_ensure_target_nowarn(${AV_SUBDIRECTORY})
  endforeach()

endfunction()