# Package index

## Install GLM

Functions for compiling and installing the GLM executable. Run one of
these once before using
[`run_glm()`](https://flare-forecast.github.io/GLMAEDr/reference/run_glm.md).

- [`glm_install()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_install.md)
  : Install the GLM executable by compiling from source
- [`glm_install_aed_tools()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_install_aed_tools.md)
  : Install GLM from the AED_Tools repository
- [`glm_register_binary()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_register_binary.md)
  : Register a pre-downloaded GLM binary
- [`check_build_tools()`](https://flare-forecast.github.io/GLMAEDr/reference/check_build_tools.md)
  : Check that all tools required to build GLM are available

## Run simulations

Functions for executing GLM simulations from R.

- [`run_glm()`](https://flare-forecast.github.io/GLMAEDr/reference/run_glm.md)
  : Run a GLM simulation
- [`glm_version()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_version.md)
  : Return the GLM version string

## Paths and status

Inspect and locate the installed GLM binary.

- [`glm_exe_path()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_exe_path.md)
  : Path to the installed GLM executable
- [`glm_path()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_path.md)
  : Full path to the installed GLM executable
- [`glm_is_installed()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_is_installed.md)
  : Check whether GLM is installed
- [`nml_template_path()`](https://flare-forecast.github.io/GLMAEDr/reference/nml_template_path.md)
  : Path to the bundled NML template
