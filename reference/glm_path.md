# Full path to the installed GLM executable

Returns the absolute path to the compiled GLM binary, verified to exist.
Use this when you want to invoke GLM directly from a shell or external
script rather than through
[`run_glm()`](https://flare-forecast.github.io/GLMAEDr/reference/run_glm.md).

## Usage

``` r
glm_path()
```

## Value

Character string – the absolute path to the GLM executable.

## Examples

``` r
if (FALSE) { # \dontrun{
path <- glm_path()
system2(path, "--version")
} # }
```
