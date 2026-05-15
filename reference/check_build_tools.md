# Check that all tools required to build GLM are available

Verifies that `git`, a Fortran compiler (`gfortran`), a C compiler
(`gcc`/`cc`), `make`, and the NetCDF development headers are present.
Aborts with platform-specific installation instructions if anything is
missing.

## Usage

``` r
check_build_tools()
```

## Value

Invisibly `TRUE` when all tools are found.
