#' Run a GLM simulation
#'
#' Runs the installed GLM-AED executable on the simulation stored in
#' `sim_folder`. The folder must contain a valid NML configuration file.
#' If GLM is not yet installed, an error with instructions is raised.
#'
#' @param sim_folder Path to the directory containing the simulation files.
#'   Defaults to the current working directory.
#' @param nml_file Name of the NML configuration file inside `sim_folder`.
#'   Defaults to `"glm3.nml"`.
#' @param verbose Logical. Whether to echo GLM stdout/stderr to the console.
#'   Defaults to `TRUE`.
#' @param args Character vector of additional command-line arguments to pass
#'   to the GLM executable.
#'
#' @return Invisibly returns the `processx::run()` result list with elements
#'   `status`, `stdout`, and `stderr`.
#'
#' @examples
#' \dontrun{
#' sim_folder <- system.file("extdata", package = "GLMAEDr")
#' run_glm(sim_folder)
#' }
#'
#' @importFrom utils packageName
#' @export
run_glm <- function(sim_folder = ".", nml_file = "glm3.nml",
                    verbose = TRUE, args = character()) {
  sim_folder <- normalizePath(sim_folder, mustWork = TRUE)
  nml_path   <- file.path(sim_folder, nml_file)

  if (!file.exists(nml_path)) {
    cli::cli_abort(c(
      "NML configuration file not found: {.file {nml_path}}",
      "i" = "{.arg sim_folder} must contain a file named {.file {nml_file}}."
    ))
  }

  exe <- get_glm_exe()
  env <- get_lib_env()

  result <- processx::run(
    command         = exe,
    args            = c("--nml", nml_file, args),
    wd              = sim_folder,
    env             = env,
    echo            = verbose,
    error_on_status = FALSE
  )

  if (result$status != 0L) {
    cli::cli_abort(c(
      "GLM simulation failed with exit status {result$status}.",
      "x" = if (nzchar(trimws(result$stderr))) result$stderr else result$stdout
    ))
  }

  invisible(result)
}


#' Return the GLM version string
#'
#' Invokes the installed GLM executable with `-help` and returns the
#' captured output, which includes the version number.
#'
#' @return A character string with the GLM version information.
#'
#' @examples
#' \dontrun{
#' glm_version()
#' }
#'
#' @importFrom utils packageName
#' @export
glm_version <- function() {
  exe <- get_glm_exe()
  env <- get_lib_env()

  result <- processx::run(
    command         = exe,
    args            = "-help",
    env             = env,
    error_on_status = FALSE
  )

  trimws(paste0(result$stdout, result$stderr))
}


#' Path to the bundled NML template
#'
#' Returns the absolute path to the example `glm3.nml` template shipped
#' with the package. Copy this file to your simulation directory as a
#' starting point for new configurations.
#'
#' @return A character string giving the file path.
#'
#' @examples
#' nml_template_path()
#'
#' @importFrom utils packageName
#' @export
nml_template_path <- function() {
  system.file("extdata", "glm3.nml", package = packageName())
}
