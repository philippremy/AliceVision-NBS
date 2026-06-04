cmake_minimum_required(VERSION 3.30)

if(NOT DEFINED AV_INPUT_FILE)
  message(FATAL_ERROR "AV_INPUT_FILE must be defined!")
endif()

message(STATUS "Gathering runtime dependencies required by ${AV_INPUT_FILE}...")

file(GET_RUNTIME_DEPENDENCIES
    RESOLVED_DEPENDENCIES_VAR RESOLVED
    UNRESOLVED_DEPENDENCIES_VAR UNRESOLVED
    LIBRARIES ${AV_INPUT_FILE}
)

message(STATUS "### Report for ${AV_INPUT_FILE} ###")
message(STATUS "")

foreach(RESOLVED_LIB IN LISTS RESOLVED)
  message(STATUS "  Resolved: ${RESOLVED_LIB}")
endforeach()

foreach(UNRESOLVED_LIB IN LISTS UNRESOLVED)
  message(STATUS "  Unresolved: ${UNRESOLVED_LIB}")
endforeach()

message(STATUS "### End report for ${AV_INPUT_FILE} ###")