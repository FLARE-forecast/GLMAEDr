# Register a pre-downloaded GLM binary

Copies an existing GLM executable into the per-user data directory so
that
[`run_glm()`](https://flare-forecast.github.io/GLMAEDr/reference/run_glm.md)
and all other package functions can find it. Use this when you have
obtained a GLM binary by some other means (e.g. downloaded from a
release page, received from a colleague, or built manually outside R)
and do not want to compile from source.

## Usage

``` r
glm_register_binary(path, force = FALSE)
```

## Arguments

- path:

  Path to the GLM executable to register. Must be an existing file. On
  POSIX systems the file will be made executable after copying.

- force:

  Logical. Overwrite an existing installation. Default `FALSE`.

## Value

Invisibly returns the path to the installed GLM executable.

## Examples

``` r
if (FALSE) { # \dontrun{
glm_register_binary("~/Downloads/glm")
} # }
```
