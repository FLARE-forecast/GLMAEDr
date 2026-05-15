GLM_DEFAULT_REPO      <- "https://github.com/rqthomas/glm-aed"
aed_tools_default_repo <- "https://github.com/AquaticEcoDynamics/AED_Tools"
aed_tools_private_default_repo <-
  "https://github.com/AquaticEcoDynamics/AED_Tools_Private"

#' Install the GLM executable by compiling from source
#'
#' Downloads the GLM-AED source repository and compiles the GLM executable
#' for the current platform. The resulting binary is stored in a per-user
#' data directory so it survives package upgrades and requires no
#' administrator privileges. Only needs to be run once per machine (or after
#' a GLM version upgrade).
#'
#' ## System requirements
#'
#' **macOS** — install via Homebrew:
#' ```
#' brew install gcc netcdf
#' ```
#'
#' **Linux (Ubuntu/Debian)** — install via apt:
#' ```
#' sudo apt-get install gfortran libnetcdf-dev
#' ```
#'
#' **Windows** — install
#' [RTools](https://cran.r-project.org/bin/windows/Rtools/) for your R
#' version (provides `gfortran`, `make`, and NetCDF libraries).
#'
#' @param repo URL of any GLM-AED-style git repository. Forks and mirrors
#'   are supported as long as they preserve the `glm-source/build_glm.sh`
#'   structure.
#' @param ref What to check out after cloning. Accepts:
#'   * `"HEAD"` (default) — tip of the default branch
#'   * a branch name, e.g. `"develop"`
#'   * a tag, e.g. `"v3.9.107"`
#'   * a full or abbreviated commit SHA, e.g. `"a3f2c1d"`
#' @param no_gui Logical. Build the headless version of GLM (no graphical
#'   output window). Recommended for use from R. Default `TRUE`.
#' @param jobs Integer. Number of parallel `make` jobs. Defaults to `1L`.
#'   Fortran module compilations have implicit ordering dependencies that
#'   can race under parallel make; increase only if you have verified that
#'   the upstream Makefiles declare explicit module dependencies.
#' @param force Logical. Reinstall even when a binary already exists.
#' @param quiet Logical. Suppress build output. Default `FALSE`.
#'
#' @return Invisibly returns the path to the installed GLM executable.
#'
#' @examples
#' \dontrun{
#' glm_install()
#' }
#'
#' @export
glm_install <- function(
  repo    = GLM_DEFAULT_REPO,
  ref     = "HEAD",
  no_gui  = TRUE,
  jobs    = 1L,
  force   = FALSE,
  quiet   = FALSE
) {
  exe <- glm_exe_path()

  if (!force && file.exists(exe)) {
    cli::cli_inform(c(
      "GLM is already installed at {.file {exe}}.",
      "i" = "Use {.code glm_install(force = TRUE)} to reinstall.",
      "i" = "Run {.run GLMAEDr::glm_version()} to see the current version."
    ))
    return(invisible(exe))
  }

  check_build_tools()

  build_dir <- tempfile("GLMAEDr-build-")
  on.exit(unlink(build_dir, recursive = TRUE), add = TRUE)

  .clone_source(repo, ref, build_dir, quiet)
  .build_glm(build_dir, no_gui, jobs, quiet)

  built_exe_name <- if (.Platform$OS.type == "windows") "glm.exe" else "glm"
  built_exe <- file.path(build_dir, "glm-source", "GLM", built_exe_name)

  if (!file.exists(built_exe)) {
    cli::cli_abort(c(
      "Build appeared to succeed but binary not found at {.file {built_exe}}.",
      "i" = "Check the build output above for errors."
    ))
  }

  install_dir <- dirname(exe)
  dir.create(install_dir, recursive = TRUE, showWarnings = FALSE)
  file.copy(built_exe, exe, overwrite = TRUE)
  if (.Platform$OS.type == "unix") Sys.chmod(exe, "755")

  cli::cli_alert_success("GLM installed at {.file {exe}}")
  invisible(exe)
}


#' Check whether GLM is installed
#'
#' Returns `TRUE` if a GLM executable exists in the per-user data directory
#' (i.e. `glm_install()` has been run successfully).
#'
#' @return Logical scalar.
#' @export
glm_is_installed <- function() {
  file.exists(glm_exe_path())
}


#' Path to the installed GLM executable
#'
#' Returns the expected path of the GLM binary in the per-user data
#' directory. The file may not exist yet if `glm_install()` has not been run.
#'
#' @return Character string.
#' @export
glm_exe_path <- function() {
  data_dir <- tools::R_user_dir("GLMAEDr", which = "data")
  exe_name <- if (.Platform$OS.type == "windows") "glm.exe" else "glm"
  file.path(data_dir, exe_name)
}


#' Full path to the installed GLM executable
#'
#' Returns the absolute path to the compiled GLM binary, verified to exist.
#' Use this when you want to invoke GLM directly from a shell or external
#' script rather than through `run_glm()`.
#'
#' @return Character string — the absolute path to the GLM executable.
#' @export
#' @examples
#' \dontrun{
#' path <- glm_path()
#' system2(path, "--version")
#' }
glm_path <- function() {
  exe <- glm_exe_path()
  if (!file.exists(exe)) {
    cli::cli_abort(c(
      "GLM is not installed.",
      "i" = "Run {.run GLMAEDr::glm_install()} to compile and install GLM."
    ))
  }
  exe
}


#' Register a pre-downloaded GLM binary
#'
#' Copies an existing GLM executable into the per-user data directory so that
#' `run_glm()` and all other package functions can find it. Use this when you
#' have obtained a GLM binary by some other means (e.g. downloaded from a
#' release page, received from a colleague, or built manually outside R) and
#' do not want to compile from source.
#'
#' @param path Path to the GLM executable to register. Must be an existing
#'   file. On POSIX systems the file will be made executable after copying.
#' @param force Logical. Overwrite an existing installation. Default `FALSE`.
#'
#' @return Invisibly returns the path to the installed GLM executable.
#'
#' @examples
#' \dontrun{
#' glm_register_binary("~/Downloads/glm")
#' }
#'
#' @export
glm_register_binary <- function(path, force = FALSE) {
  path <- normalizePath(path, mustWork = TRUE)

  if (!file.exists(path)) {
    cli::cli_abort("File not found: {.file {path}}")
  }

  exe <- glm_exe_path()

  if (!force && file.exists(exe)) {
    cli::cli_inform(c(
      "GLM is already installed at {.file {exe}}.",
      "i" = "Use {.code glm_register_binary(path, force = TRUE)} to replace it."
    ))
    return(invisible(exe))
  }

  install_dir <- dirname(exe)
  dir.create(install_dir, recursive = TRUE, showWarnings = FALSE)
  ok <- file.copy(path, exe, overwrite = TRUE)

  if (!ok) {
    cli::cli_abort(c(
      "Failed to copy {.file {path}} to {.file {exe}}.",
      "i" = "Check that you have write access to {.file {install_dir}}."
    ))
  }

  if (.Platform$OS.type == "unix") Sys.chmod(exe, "755")

  cli::cli_alert_success("GLM registered at {.file {exe}}")
  invisible(exe)
}


#' Check that all tools required to build GLM are available
#'
#' Verifies that `git`, a Fortran compiler (`gfortran`), a C compiler
#' (`gcc`/`cc`), `make`, and the NetCDF development headers are present.
#' Aborts with platform-specific installation instructions if anything is
#' missing.
#'
#' @return Invisibly `TRUE` when all tools are found.
#' @export
check_build_tools <- function() {
  missing_tools <- character(0)

  required <- list(
    git     = "git",
    make    = "make",
    gfortran = "gfortran"
  )

  for (name in names(required)) {
    cmd <- required[[name]]
    found <- nzchar(Sys.which(cmd))
    if (!found) missing_tools <- c(missing_tools, cmd)
  }

  # NetCDF: Unix uses nc-config/netcdf-config; Windows bundles it with RTools
  if (.Platform$OS.type != "windows") {
    has_netcdf <- nzchar(Sys.which("nc-config")) ||
                  nzchar(Sys.which("netcdf-config"))
    if (!has_netcdf) missing_tools <- c(missing_tools, "netcdf headers")
  }

  if (length(missing_tools) == 0L) return(invisible(TRUE))

  platform <- tryCatch(get_platform(), error = function(e) "unknown")

  if (startsWith(platform, "macos-")) {
    install_hint <- c(
      "i" = "Install via Homebrew:",
      " " = "{.code brew install gcc netcdf}"
    )
  } else if (startsWith(platform, "ubuntu-")) {
    install_hint <- c(
      "i" = "Install via apt:",
      " " = "{.code sudo apt-get install gfortran libnetcdf-dev}"
    )
  } else if (platform == "windows") {
    install_hint <- c(
      "i" = paste0(
        "Install RTools from ",
        "{.url https://cran.r-project.org/bin/windows/Rtools/}"
      ),
      "i" = "Make sure RTools is on your PATH."
    )
  } else {
    install_hint <- c(
      "i" = "Install gfortran, make, and NetCDF development headers."
    )
  }

  cli::cli_abort(c(
    paste0(
      "Missing build tool{?s} required to compile GLM: ",
      "{.val {missing_tools}}"
    ),
    install_hint
  ))
}


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

.clone_source <- function(repo, ref, build_dir, quiet) {
  cli::cli_progress_step("Cloning GLM source from {.url {repo}}")

  is_sha <- grepl("^[0-9a-f]{7,40}$", ref)

  if (is_sha) {
    clone_args <- c("clone", "--recurse-submodules", repo, build_dir)
  } else if (identical(ref, "HEAD")) {
    clone_args <- c("clone", "--recurse-submodules", "--depth", "1",
                    repo, build_dir)
  } else {
    clone_args <- c("clone", "--recurse-submodules", "--branch", ref,
                    "--depth", "1", repo, build_dir)
  }

  result <- processx::run(
    "git", clone_args,
    echo            = !quiet,
    error_on_status = FALSE
  )

  if (result$status != 0L) {
    cli::cli_abort(c(
      "Failed to clone {.url {repo}}.",
      "x" = if (nzchar(trimws(result$stderr))) result$stderr else result$stdout,
      "i" = "Check your internet connection and that the repository URL is correct."
    ))
  }

  if (is_sha) {
    for (git_args in list(
      c("checkout", ref),
      c("submodule", "update", "--init", "--recursive")
    )) {
      res <- processx::run(
        "git", git_args,
        wd              = build_dir,
        echo            = !quiet,
        error_on_status = FALSE
      )
      if (res$status != 0L) {
        cli::cli_abort(c(
          "Failed to checkout {.val {ref}}.",
          "x" = if (nzchar(trimws(res$stderr))) res$stderr else res$stdout
        ))
      }
    }
  }
}

.build_glm <- function(build_dir, no_gui, jobs, quiet) {
  cli::cli_progress_step(
    "Building GLM (this may take a few minutes…)"
  )

  src_dir   <- file.path(build_dir, "glm-source")
  build_sh  <- file.path(src_dir, "build_glm.sh")

  if (!file.exists(build_sh)) {
    cli::cli_abort(c(
      "Build script not found at {.file {build_sh}}.",
      "i" = "The repository structure may have changed."
    ))
  }

  # git clone does not guarantee execute bits on shell scripts; set them
  # explicitly so build_glm.sh and any scripts it calls can run.
  if (.Platform$OS.type == "unix") {
    sh_files <- list.files(
      build_dir, pattern = "\\.sh$", recursive = TRUE, full.names = TRUE
    )
    Sys.chmod(sh_files, "755")
  }

  sh_cmd  <- Sys.which("sh")
  if (!nzchar(sh_cmd)) sh_cmd <- "sh"

  build_args <- character(0)
  if (no_gui) build_args <- c(build_args, "--no-gui")

  result <- processx::run(
    sh_cmd, c(build_sh, build_args),
    wd              = src_dir,
    echo            = !quiet,
    error_on_status = FALSE
  )

  if (result$status != 0L) {
    cli::cli_abort(c(
      "GLM build failed (exit status {result$status}).",
      "x" = if (nzchar(trimws(result$stderr))) result$stderr else result$stdout,
      "i" = "Ensure all build dependencies are installed.",
      "i" = paste0(
        "See {.url https://github.com/FLARE-forecast/GLMAEDr#system-requirements}",
        " for details."
      )
    ))
  }
}


#' Install GLM from the AED_Tools repository
#'
#' Clones the
#' [AED_Tools](https://github.com/AquaticEcoDynamics/AED_Tools) repository
#' (or its private counterpart), fetches GLM source via `fetch_sources.sh`,
#' optionally switches the GLM sub-repository to a specific branch or tag,
#' then compiles GLM with `build_glm.sh`. The resulting binary is stored in
#' the same per-user data directory as `glm_install()`.
#'
#' ## System requirements
#'
#' Same as `glm_install()` — see `?glm_install` for details.
#'
#' @param repo URL of the AED_Tools git repository. Ignored when `private =
#'   TRUE`.
#' @param ref Branch or tag to check out inside the `GLM/` sub-repository
#'   after fetching sources. Accepts:
#'   * `"HEAD"` (default) — whatever branch `fetch_sources.sh` leaves checked
#'     out
#'   * a branch name, e.g. `"v4alpha"`
#'   * a tag, e.g. `"v4.0.0"`
#'   * a full or abbreviated commit SHA, e.g. `"a3f2c1d"`
#' @param private Logical. Clone from `AED_Tools_Private` instead of the
#'   public `AED_Tools` repository. Requires that your git credentials
#'   (SSH key or personal access token) have read access to
#'   `github.com/AquaticEcoDynamics/AED_Tools_Private`. Default `FALSE`.
#' @param no_gui Logical. Build the headless version of GLM. Default `TRUE`.
#' @param jobs Integer. Number of parallel `make` jobs. Default `1L`.
#' @param force Logical. Reinstall even when a binary already exists.
#' @param quiet Logical. Suppress build output. Default `FALSE`.
#'
#' @return Invisibly returns the path to the installed GLM executable.
#'
#' @examples
#' \dontrun{
#' glm_install_aed_tools(ref = "v4alpha")
#' glm_install_aed_tools(private = TRUE, ref = "v4alpha")
#' }
#'
#' @export
glm_install_aed_tools <- function(
  repo    = aed_tools_default_repo,
  ref     = "HEAD",
  private = FALSE,
  no_gui  = TRUE,
  jobs    = 1L,  # nolint: unused_argument. Reserved for future parallel builds.
  force   = FALSE,
  quiet   = FALSE
) {
  if (private) repo <- aed_tools_private_default_repo
  exe <- glm_exe_path()

  if (!force && file.exists(exe)) {
    cli::cli_inform(c(
      "GLM is already installed at {.file {exe}}.",
      "i" = "Use {.code glm_install_aed_tools(force = TRUE)} to reinstall.",
      "i" = "Run {.run GLMAEDr::glm_version()} to see the current version."
    ))
    return(invisible(exe))
  }

  check_build_tools()

  build_dir <- tempfile("GLMAEDr-aed-build-")
  on.exit(unlink(build_dir, recursive = TRUE), add = TRUE)

  .clone_aed_tools(repo, build_dir, quiet)
  .fetch_glm_sources(build_dir, quiet)
  if (!identical(ref, "HEAD")) .checkout_glm_ref(build_dir, ref, quiet)
  .build_glm_aed_tools(build_dir, no_gui, quiet)

  built_exe_name <- if (.Platform$OS.type == "windows") "glm.exe" else "glm"
  built_exe <- file.path(build_dir, "GLM", built_exe_name)

  if (!file.exists(built_exe)) {
    cli::cli_abort(c(
      "Build appeared to succeed but binary not found at {.file {built_exe}}.",
      "i" = "Check the build output above for errors."
    ))
  }

  install_dir <- dirname(exe)
  dir.create(install_dir, recursive = TRUE, showWarnings = FALSE)
  file.copy(built_exe, exe, overwrite = TRUE)
  if (.Platform$OS.type == "unix") Sys.chmod(exe, "755")

  cli::cli_alert_success("GLM installed at {.file {exe}}")
  invisible(exe)
}


# ---------------------------------------------------------------------------
# Internal helpers for glm_install_aed_tools()
# ---------------------------------------------------------------------------

.clone_aed_tools <- function(repo, build_dir, quiet) {
  cli::cli_progress_step("Cloning AED_Tools from {.url {repo}}")

  result <- processx::run(
    "git", c("clone", repo, build_dir),
    echo            = !quiet,
    error_on_status = FALSE
  )

  if (result$status != 0L) {
    cli::cli_abort(c(
      "Failed to clone {.url {repo}}.",
      "x" = if (nzchar(trimws(result$stderr))) result$stderr else result$stdout,
      "i" = "Check your internet connection and that the repository URL is correct."
    ))
  }
}

.fetch_glm_sources <- function(build_dir, quiet) {
  cli::cli_progress_step("Fetching GLM sources via fetch_sources.sh")

  fetch_sh <- file.path(build_dir, "fetch_sources.sh")
  if (!file.exists(fetch_sh)) {
    cli::cli_abort(c(
      "fetch_sources.sh not found at {.file {fetch_sh}}.",
      "i" = "The repository structure may have changed."
    ))
  }

  sh_cmd <- Sys.which("sh")
  if (!nzchar(sh_cmd)) sh_cmd <- "sh"

  result <- processx::run(
    sh_cmd, c(fetch_sh, "glm"),
    wd              = build_dir,
    echo            = !quiet,
    error_on_status = FALSE
  )

  if (result$status != 0L) {
    cli::cli_abort(c(
      "fetch_sources.sh failed (exit status {result$status}).",
      "x" = if (nzchar(trimws(result$stderr))) result$stderr else result$stdout
    ))
  }
}

.checkout_glm_ref <- function(build_dir, ref, quiet) {
  cli::cli_progress_step("Checking out {.val {ref}} in GLM source")

  glm_dir <- file.path(build_dir, "GLM")

  for (args in list(c("fetch", "origin"), c("checkout", ref))) {
    res <- processx::run(
      "git", args,
      wd              = glm_dir,
      echo            = !quiet,
      error_on_status = FALSE
    )
    if (res$status != 0L) {
      cli::cli_abort(c(
        "git {args[[1L]]} failed in GLM sub-repository.",
        "x" = if (nzchar(trimws(res$stderr))) res$stderr else res$stdout
      ))
    }
  }
}

.build_glm_aed_tools <- function(build_dir, no_gui, quiet) {
  cli::cli_progress_step("Building GLM (this may take a few minutes…)")

  clean_sh <- file.path(build_dir, "clean.sh")
  build_sh <- file.path(build_dir, "build_glm.sh")

  if (!file.exists(build_sh)) {
    cli::cli_abort(c(
      "build_glm.sh not found at {.file {build_sh}}.",
      "i" = "The repository structure may have changed."
    ))
  }

  if (.Platform$OS.type == "unix") {
    sh_files <- list.files(
      build_dir, pattern = "\\.sh$", recursive = TRUE, full.names = TRUE
    )
    Sys.chmod(sh_files, "755")
  }

  sh_cmd <- Sys.which("sh")
  if (!nzchar(sh_cmd)) sh_cmd <- "sh"

  if (file.exists(clean_sh)) {
    res <- processx::run(
      sh_cmd, clean_sh,
      wd              = build_dir,
      echo            = !quiet,
      error_on_status = FALSE
    )
    if (res$status != 0L) {
      cli::cli_warn("clean.sh exited with status {res$status}; proceeding.")
    }
  }

  build_args <- character(0)
  if (no_gui) build_args <- c(build_args, "--no-gui")

  result <- processx::run(
    sh_cmd, c(build_sh, build_args),
    wd              = build_dir,
    echo            = !quiet,
    error_on_status = FALSE
  )

  if (result$status != 0L) {
    cli::cli_abort(c(
      "GLM build failed (exit status {result$status}).",
      "x" = if (nzchar(trimws(result$stderr))) result$stderr else result$stdout,
      "i" = "Ensure all build dependencies are installed."
    ))
  }
}
