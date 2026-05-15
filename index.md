# GLMAEDr

GLMAEDr is an R package for running the [General Lake Model
(GLM)](https://github.com/AquaticEcoDynamics/GLM) coupled with the
[Aquatic EcoDynamics
(AED)](https://github.com/AquaticEcoDynamics/libaed-water) library.
Rather than bundling pre-compiled executables, GLMAEDr compiles GLM from
source on your machine — avoiding code-signing restrictions on macOS and
producing a binary that is tuned for your system.

## System requirements

Install these **before** calling
[`glm_install()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_install.md).

| Platform | Command |
|----|----|
| **macOS** ([Homebrew](https://brew.sh)) | `brew install gcc netcdf` |
| **Ubuntu / Debian** | `sudo apt-get install gfortran libnetcdf-dev debhelper` |
| **Windows** | Install [RTools](https://cran.r-project.org/bin/windows/Rtools/) for your R version |

To check whether all build dependencies are present:

``` r

GLMAEDr::check_build_tools()
```

## Installation

Install the package from GitHub with pak:

``` r

# install.packages("pak")
pak::pkg_install("FLARE-forecast/GLMAEDr")
```

## Getting started

### Step 1 — compile GLM

Run this once after installing the package. It clones the GLM-AED source
repository and compiles the binary (~2 minutes):

``` r

library(GLMAEDr)
glm_install()
```

The binary is stored in a per-user data directory
(`tools::R_user_dir("GLMAEDr", "data")`), so it survives package
upgrades and requires no administrator privileges.

Confirm the installation succeeded:

``` r

glm_is_installed()   # TRUE
glm_version()        # prints the GLM version string
```

### Step 2 — set up a simulation

Each simulation lives in its own folder and must contain a `glm3.nml`
configuration file. Copy the bundled template as a starting point:

``` r

dir.create("my_lake")
file.copy(nml_template_path(), "my_lake/glm3.nml")
```

Edit `glm3.nml` to configure your lake geometry, meteorological inputs,
and output settings.

### Step 3 — run the simulation

``` r

run_glm("my_lake")
```

GLM writes its output to `my_lake/output/output.nc` by default. Verbose
output is printed to the console; pass `verbose = FALSE` to suppress it.

## Installing from AED_Tools

If you need the v4 development branch or have access to the private
AED_Tools repository, use
[`glm_install_aed_tools()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_install_aed_tools.md)
instead:

``` r

# Public AED_Tools repo, v4alpha branch
glm_install_aed_tools(ref = "v4alpha")

# Private AED_Tools_Private repo (requires GitHub credentials)
glm_install_aed_tools(private = TRUE, ref = "v4alpha")
```

## Registering a pre-built binary

If you already have a GLM executable (e.g. built manually or received
from a colleague), register it directly without compiling from source:

``` r

glm_register_binary("~/Downloads/glm")
```

## Upgrading GLM

Recompile with the latest source at any time:

``` r

glm_install(force = TRUE)
```

Pin a specific tag or branch:

``` r

glm_install(ref = "v3.9.107", force = TRUE)
```

## Using GLM outside R

[`glm_path()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_path.md)
returns the full path to the binary, useful for calling GLM from a shell
script or other tool:

``` r

glm_path()
#> /Users/you/Library/Application Support/R/GLMAEDr/glm
```

## Troubleshooting

| Problem | Fix |
|----|----|
| `Missing build tools` error | Run [`check_build_tools()`](https://flare-forecast.github.io/GLMAEDr/reference/check_build_tools.md) for platform-specific install instructions |
| Build fails on macOS | Ensure Homebrew `gcc` is on your PATH: `echo $PATH` |
| Build fails on Linux | Check that `libnetcdf-dev` is installed: `dpkg -l libnetcdf-dev` |
| `GLM is not installed` when calling [`run_glm()`](https://flare-forecast.github.io/GLMAEDr/reference/run_glm.md) | Run [`glm_install()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_install.md) first |
| Want to try a different GLM version | `glm_install(ref = "v3.9.107", force = TRUE)` |

## License

MIT © R. Quinn Thomas
