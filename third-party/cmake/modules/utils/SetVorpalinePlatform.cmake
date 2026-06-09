# =============================================================================
# SetVorpalinePlatform.cmake - Automatically sets the correct platform for
# Geogram
# 
# Currently only works for Apple, Linux and Windows. Using MinGW or
# architectures other than arm64/x86_64 is brittle (thanks Geogram ._.)
# 
# =============================================================================

if(APPLE)

  if(BUILD_SHARED_LIBS)
    if(DEFINED CMAKE_OSX_ARCHITECTURES AND NOT CMAKE_OSX_ARCHITECTURES STREQUAL "")
      if(CMAKE_OSX_ARCHITECTURES MATCHES "x86_64")
        set(VORPALINE_PLATFORM "Darwin-clang-dynamic")
      elseif(CMAKE_OSX_ARCHITECTURES MATCHES "(aarch64|arm64)")
        set(VORPALINE_PLATFORM "Darwin-aarch64-clang-dynamic")
      endif()
    else()
      if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
        set(VORPALINE_PLATFORM "Darwin-clang-dynamic")
      elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "(aarch64|arm64)")
        set(VORPALINE_PLATFORM "Darwin-clang-dynamic")
      endif()
    endif()
  elseif(BUILD_STATIC_LIBS)
    if(DEFINED CMAKE_OSX_ARCHITECTURES AND NOT CMAKE_OSX_ARCHITECTURES STREQUAL "")
      if(CMAKE_OSX_ARCHITECTURES MATCHES "x86_64")
        set(VORPALINE_PLATFORM "Darwin-clang")
      elseif(CMAKE_OSX_ARCHITECTURES MATCHES "arm64")
        set(VORPALINE_PLATFORM "Darwin-aarch64-clang")
      endif()
    else()
      if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
        set(VORPALINE_PLATFORM "Darwin-clang")
      elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
      message(HERE)
        set(VORPALINE_PLATFORM "Darwin-aarch64-clang")
      endif()
    endif()
  endif()

elseif(LINUX)

  if(CMAKE_SYSTEM_PROCESSOR MATCHES "(x86_64|x64|ia64)")  # TODO: remove ia64?
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
      if(BUILD_SHARED_LIBS)
        set(VORPALINE_PLATFORM "Linux64-gcc-dynamic")
      elseif(BUILD_STATIC_LIBS)
        set(VORPALINE_PLATFORM "Linux64-gcc")
      endif()
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
      if(BUILD_SHARED_LIBS)
        set(VORPALINE_PLATFORM "Linux64-clang-dynamic")
      elseif(BUILD_STATIC_LIBS)
        set(VORPALINE_PLATFORM "Linux64-clang")
      endif()
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "(Intel|IntelLLVM)")
      if(BUILD_SHARED_LIBS)
        set(VORPALINE_PLATFORM "Linux64-icc-dynamic")
      elseif(BUILD_STATIC_LIBS)
        set(VORPALINE_PLATFORM "Linux64-icc")
      endif()
    endif()
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "(arm64|aarch64_be|aarch64|armv8b|armv8l|)")
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
      set(VORPALINE_PLATFORM "Linux64-gcc-aarch64")
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
      set(VORPALINE_PLATFORM "Linux64-nonx86-clang-dynamic")
    endif()
  else()
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
      set(VORPALINE_PLATFORM "Linux64-nonx86-gcc-dynamic")
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
      set(VORPALINE_PLATFORM "Linux64-nonx86-clang-dynamic")
    endif()
  endif()

elseif(WIN32)

  if(MSVC)
    if(BUILD_SHARED_LIBS)
      set(VORPALINE_PLATFORM "Win-vs-dynamic-generic")
    elseif(BUILD_STATIC_LIBS)
      set(VORPALINE_PLATFORM "Win-vs-dynamic")
    endif()
  else()
    # We *hope* that the compiler is GCC compatible
    # Shared/Static libs are determined by VORPALINE_BUILD_DYNAMIC
    set(VORPALINE_PLATFORM "Win64-gcc")
  endif()

else()

  message(FATAL_ERROR "Cannot determine vorpaline platform for Geogram! Supported OSes are Darwin, Linux and Windows.")
  
endif()

if(NOT DEFINED VORPALINE_PLATFORM)

  message(FATAL_ERROR "[SetVorpalinePlatform] Unable to determine fitting VORPALINE_PLATFORM for Geogram.")

else()

  message(TRACE "[SetVorpalinePlatform] Using VORPALINE_PLATFORM for Geogram: ${VORPALINE_PLATFORM}")

endif()