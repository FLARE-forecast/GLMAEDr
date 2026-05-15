# Install GLM from the AED_Tools repository

Clones the [AED_Tools](https://github.com/AquaticEcoDynamics/AED_Tools)
repository (or its private counterpart), fetches GLM source via
`fetch_sources.sh`, optionally switches the GLM sub-repository to a
specific branch or tag, then compiles GLM with `build_glm.sh`. The
resulting binary is stored in the same per-user data directory as
[`glm_install()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_install.md).

## Usage

``` r
glm_install_aed_tools(
  repo = aed_tools_default_repo,
  ref = "HEAD",
  private = FALSE,
  no_gui = TRUE,
  jobs = 1L,
  force = FALSE,
  quiet = FALSE
)
```

## Arguments

- repo:

  URL of the AED_Tools git repository. Ignored when `private = TRUE`.

- ref:

  Branch or tag to check out inside the `GLM/` sub-repository after
  fetching sources. Accepts:

  - `"HEAD"` (default) — whatever branch `fetch_sources.sh` leaves
    checked out

  - a branch name, e.g. `"v4alpha"`

  - a tag, e.g. `"v4.0.0"`

  - a full or abbreviated commit SHA, e.g. `"a3f2c1d"`

- private:

  Logical. Clone from `AED_Tools_Private` instead of the public
  `AED_Tools` repository. Requires that your git credentials (SSH key or
  personal access token) have read access to
  `github.com/AquaticEcoDynamics/AED_Tools_Private`. Default `FALSE`.

- no_gui:

  Logical. Build the headless version of GLM. Default `TRUE`.

- jobs:

  Integer. Number of parallel `make` jobs. Default `1L`.

- force:

  Logical. Reinstall even when a binary already exists.

- quiet:

  Logical. Suppress build output. Default `FALSE`.

## Value

Invisibly returns the path to the installed GLM executable.

## Details

### System requirements

Same as
[`glm_install()`](https://flare-forecast.github.io/GLMAEDr/reference/glm_install.md)
— see
[`?glm_install`](https://flare-forecast.github.io/GLMAEDr/reference/glm_install.md)
for details.

## Examples

``` r
if (FALSE) { # \dontrun{
glm_install_aed_tools(ref = "v4alpha")
glm_install_aed_tools(private = TRUE, ref = "v4alpha")
} # }
```
