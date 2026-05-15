# Returns a platform identifier string used in user-facing messages.
# Possible values: "macos-<name>", "ubuntu-<ver>", "windows", "linux".
get_platform <- function() {
  sysname <- Sys.info()[["sysname"]]
  switch(sysname,
    Darwin  = paste0("macos-", .macos_name()),
    Windows = "windows",
    Linux   = paste0("ubuntu-", .ubuntu_version()),
    sysname   # fall-through: return the raw name
  )
}

# Darwin kernel major version -> macOS release name (for messages only).
.darwin_map <- c(
  "20" = "Big_Sur",
  "21" = "Monterey",
  "22" = "Monterey",
  "23" = "Sonoma",
  "24" = "Sequoia",
  "25" = "Tahoe_26"
)

.macos_name <- function() {
  major <- strsplit(Sys.info()[["release"]], ".", fixed = TRUE)[[1L]][1L]
  name  <- .darwin_map[major]
  if (is.na(name)) unname(.darwin_map[[length(.darwin_map)]]) else unname(name)
}

.ubuntu_version <- function() {
  lines <- tryCatch(
    readLines("/etc/os-release", warn = FALSE),
    error = function(e) character(0)
  )
  parse_ubuntu_version(lines)
}

# Pure version parser — accepts /etc/os-release lines as a character vector.
# Separated so it can be tested without touching the filesystem.
parse_ubuntu_version <- function(lines) {
  ver_line <- grep("^VERSION_ID=", lines, value = TRUE)
  if (!length(ver_line)) return("unknown")
  ver <- gsub('^VERSION_ID="?([^"]+)"?.*', "\\1", ver_line[[1L]])
  ver
}

# Returns the absolute path to the installed GLM executable, setting
# executable permissions on POSIX. Aborts with a helpful message if the
# binary has not been installed yet.
get_glm_exe <- function() {
  exe <- glm_exe_path()

  if (!file.exists(exe)) {
    cli::cli_abort(c(
      "GLM executable not found at {.file {exe}}.",
      "i" = paste0(
        "Run {.run GLMAEDr::glm_install()} to compile and install GLM."
      )
    ))
  }

  if (.Platform$OS.type == "unix") Sys.chmod(exe, "755")
  exe
}

# Returns a copy of the current environment, optionally with no
# modifications (compiled binaries link against system libraries directly).
get_lib_env <- function() {
  Sys.getenv()
}
