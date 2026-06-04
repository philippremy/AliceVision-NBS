# NOTES

### SuiteSparse Fortran Calling Convention

We usually want to use the Fortran compiler available, but if it is not (like on Windows) we might need to alter that. Especially the MSVC switch smells fishy, because we compile the C LAPACK so the symbols are very likely mangled.

EDIT: Confirmed using `dumpbin /EXPORTS` that OpenBLAS also generates `name##_` symbols, so this MSVC switch is wrong. Remember to reset that!

```cmake
# default C-to-Fortran name mangling if Fortran compiler not found
if ( MSVC )
# MS Visual Studio Fortran compiler does not mangle the Fortran name
set ( SUITESPARSE_C_TO_FORTRAN "(name,NAME) name"
CACHE STRING "C to Fortan name mangling" )
else ( )
# Other systems (Linux, Mac) typically append an underscore
set ( SUITESPARSE_C_TO_FORTRAN "(name,NAME) name##_"
CACHE STRING "C to Fortan name mangling" )
endif ( )
```

### OpenBLAS / SuiteSparse Integer Size

We always build OpenBLAS with an integer size of 4.
