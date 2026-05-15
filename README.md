# GLMAEDr

An R interface to the [General Lake Model (GLM)](https://github.com/AquaticEcoDynamics/GLM)
coupled with the Aquatic EcoDynamics (AED) library. GLM is compiled from
source on first use, producing a native binary with no code-signing
restrictions. Supports macOS, Ubuntu Linux, and Windows.

## System requirements

Install these before calling `glm_install()`.

**macOS** (via [Homebrew](https://brew.sh)):
```bash
brew install gcc netcdf
```

**Ubuntu / Debian**:
```bash
sudo apt-get install gfortran libnetcdf-dev
```

**Windows**: install [RTools](https://cran.r-project.org/bin/windows/Rtools/)
for your R version — it provides `gfortran`, `make`, and NetCDF libraries.

## Installation

```r
# install.packages("pak")
pak::pkg_install("FLARE-forecast/GLMAEDr")
```

## First-time setup

After installing the package, compile GLM once:

```r
library(GLMAEDr)
glm_install()   # downloads source and compiles (~2 min)
```

The binary is stored in a per-user data directory
(`tools::R_user_dir("GLMAEDr", "data")`), survives package upgrades, and
requires no administrator privileges.

## Usage

```r
library(GLMAEDr)

# Verify the installed version
glm_version()

# Run a simulation (sim_folder must contain a glm3.nml file)
run_glm("path/to/my/simulation")

# Copy the bundled NML template as a starting point
file.copy(nml_template_path(), "my_simulation/glm3.nml")

# Check whether GLM is compiled and ready
glm_is_installed()

# Show where the binary lives
glm_exe_path()
```

## Upgrading GLM

When new GLM source is available, reinstall with:

```r
glm_install(force = TRUE)
```

To pin a specific release tag:

```r
glm_install(ref = "v3.9.107", force = TRUE)
```

## Troubleshooting

`check_build_tools()` reports which build dependencies are missing with
platform-specific installation instructions:

```r
check_build_tools()
```

## License

MIT © R. Quinn Thomas
