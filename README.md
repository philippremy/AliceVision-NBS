# [WIP] New build system for AliceVision

This repository contains a new work-in-progress CMake build system for AliceVision.

### Current status

It currently is in a very early state and does not even contain the actual AliceVision source code yet. It currently focuses on a solid and more robust implementation of the extensive dependency management required to build AliceVision. The following dependencies are currently handled correctly[^1]:

- [x] zlib
- [x] Boost
- [x] OpenMP
- [x] nanoflann
- [x] Expat
- [x] libdeflate
- [x] openjph
- [x] Imath
- [x] oneTBB/TBB
- [x] OpenEXR
- [x] yaml-cpp
- [x] pystring
- [x] minizip-ng
- [x] OpenColorIO
- [x] Eigen
- [x] LZ4
- [x] flann
- [x] OpenBLAS
- [x] SuiteSparse (if ALICEVISION_ALLOW_GPL)
- [x] Ceres
- [x] Xerces-C
- [x] libE57Format
- [x] assimp
- [x] Alembic
- [x] Geogram

[^1]: "Handled correctly" meaning that the build system is able to pick externally provided packages from any package manager provided environment supported by CMake and to build it as an embedded dependency in a cross-platform way. The build is facilitated by CMake's FetchContent functionality, embedded in customized wrappers. This allows for more consistent builds than with ExternalProject and does not require CMake to run twice, simplifiying option handling considerably.

### Dependency graph

To be created.

### Informative files

The project currently contains [some informative files in the docs folder](docs).
