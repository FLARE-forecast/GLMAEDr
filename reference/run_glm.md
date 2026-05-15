# Run a GLM simulation

Runs the installed GLM-AED executable on the simulation stored in
`sim_folder`. The folder must contain a valid NML configuration file. If
GLM is not yet installed, an error with instructions is raised.

## Usage

``` r
run_glm(
  sim_folder = ".",
  nml_file = "glm3.nml",
  verbose = TRUE,
  args = character()
)
```

## Arguments

- sim_folder:

  Path to the directory containing the simulation files. Defaults to the
  current working directory.

- nml_file:

  Name of the NML configuration file inside `sim_folder`. Defaults to
  `"glm3.nml"`.

- verbose:

  Logical. Whether to echo GLM stdout/stderr to the console. Defaults to
  `TRUE`.

- args:

  Character vector of additional command-line arguments to pass to the
  GLM executable.

## Value

Invisibly returns the
[`processx::run()`](http://processx.r-lib.org/reference/run.md) result
list with elements `status`, `stdout`, and `stderr`.

## Examples

``` r
if (FALSE) { # \dontrun{
sim_folder <- system.file("extdata", package = "GLMAEDr")
run_glm(sim_folder)
} # }
```
