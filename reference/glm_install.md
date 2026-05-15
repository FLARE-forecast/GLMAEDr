# Install the GLM executable by compiling from source

Downloads the GLM-AED source repository and compiles the GLM executable
for the current platform. The resulting binary is stored in a per-user
data directory so it survives package upgrades and requires no
administrator privileges. Only needs to be run once per machine (or
after a GLM version upgrade).

## Usage

``` r
glm_install(
  repo = GLM_DEFAULT_REPO,
  ref = "HEAD",
  no_gui = TRUE,
  jobs = 1L,
  force = FALSE,
  quiet = FALSE
)
```

## Arguments

- repo:

  URL of any GLM-AED-style git repository. Forks and mirrors are
  supported as long as they preserve the `glm-source/build_glm.sh`
  structure.

- ref:

  What to check out after cloning. Accepts:

  - `"HEAD"` (default) — tip of the default branch

  - a branch name, e.g. `"develop"`

  - a tag, e.g. `"v3.9.107"`

  - a full or abbreviated commit SHA, e.g. `"a3f2c1d"`

- no_gui:

  Logical. Build the headless version of GLM (no graphical output
  window). Recommended for use from R. Default `TRUE`.

- jobs:

  Integer. Number of parallel `make` jobs. Defaults to `1L`. Fortran
  module compilations have implicit ordering dependencies that can race
  under parallel make; increase only if you have verified that the
  upstream Makefiles declare explicit module dependencies.

- force:

  Logical. Reinstall even when a binary already exists.

- quiet:

  Logical. Suppress build output. Default `FALSE`.

## Value

Invisibly returns the path to the installed GLM executable.

## Details

### System requirements

**macOS** — install via Homebrew:

    brew install gcc netcdf

**Linux (Ubuntu/Debian)** — install via apt:

    sudo apt-get install gfortran libnetcdf-dev

**Windows** — install
[RTools](https://cran.r-project.org/bin/windows/Rtools/) for your R
version (provides `gfortran`, `make`, and NetCDF libraries).

## Examples

``` r
if (FALSE) { # \dontrun{
glm_install()
} # }
```
