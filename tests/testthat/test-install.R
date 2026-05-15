test_that("glm_register_binary() copies an executable to the install location", {
  tmp <- tempfile("fake-glm")
  writeLines("#!/bin/sh\necho GLM", tmp)
  on.exit(unlink(tmp))

  exe <- glm_register_binary(tmp, force = TRUE)
  expect_true(file.exists(exe))
  if (.Platform$OS.type == "unix") {
    mode <- file.info(exe)$mode
    exec_bits <- bitwAnd(as.integer(as.octmode(mode)), strtoi("111", 8L))
    expect_gt(exec_bits, 0L)
  }
})

test_that("glm_register_binary() reports already installed without force", {
  skip_if_not(glm_is_installed(), "GLM not installed")
  tmp <- tempfile("fake-glm")
  writeLines("#!/bin/sh\necho GLM", tmp)
  on.exit(unlink(tmp))
  expect_message(glm_register_binary(tmp), regexp = "already installed")
})

test_that("glm_register_binary() errors when source file does not exist", {
  expect_error(
    glm_register_binary("/no/such/binary"),
    regexp = "no/such"
  )
})

test_that("check_build_tools() returns TRUE invisibly when all tools present", {
  skip_if_not(nzchar(Sys.which("git")),     "git not available")
  skip_if_not(nzchar(Sys.which("make")),    "make not available")
  skip_if_not(nzchar(Sys.which("gfortran")), "gfortran not available")
  skip_if_not(
    nzchar(Sys.which("nc-config")) || nzchar(Sys.which("netcdf-config")),
    "netcdf headers not available"
  )
  result <- check_build_tools()
  expect_true(result)
})

test_that("check_build_tools() aborts with a helpful message when git missing", {
  local_mocked_bindings(
    Sys.which = function(names, ...) setNames(rep("", length(names)), names),
    .package = "base"
  )
  expect_error(check_build_tools(), regexp = "Missing build tool")
})

test_that("glm_install() reports already installed without force = TRUE", {
  skip_if_not(glm_is_installed(), "GLM not installed")
  expect_message(glm_install(), regexp = "already installed")
})

test_that("glm_install_aed_tools() reports already installed without force = TRUE", {
  skip_if_not(glm_is_installed(), "GLM not installed")
  expect_message(glm_install_aed_tools(), regexp = "already installed")
})

test_that("glm_install_aed_tools() compiles and installs GLM from AED_Tools", {
  skip_on_cran()
  skip_if_not(nzchar(Sys.which("git")),      "git not available")
  skip_if_not(nzchar(Sys.which("make")),     "make not available")
  skip_if_not(nzchar(Sys.which("gfortran")), "gfortran not available")
  skip_if_not(
    nzchar(Sys.which("nc-config")) || nzchar(Sys.which("netcdf-config")),
    "netcdf headers not available"
  )
  exe <- glm_install_aed_tools(force = TRUE, quiet = TRUE)
  expect_true(file.exists(exe))
  if (.Platform$OS.type == "unix") {
    mode <- file.info(exe)$mode
    exec_bits <- bitwAnd(as.integer(as.octmode(mode)), strtoi("111", 8L))
    expect_gt(exec_bits, 0L)
  }
})

test_that("glm_install_aed_tools() checks out a specific ref", {
  skip_on_cran()
  skip_if_not(nzchar(Sys.which("git")), "git not available")
  skip_if_not(nzchar(Sys.which("make")), "make not available")
  skip_if_not(nzchar(Sys.which("gfortran")), "gfortran not available")
  skip_if_not(
    nzchar(Sys.which("nc-config")) || nzchar(Sys.which("netcdf-config")),
    "netcdf headers not available"
  )
  exe <- glm_install_aed_tools(ref = "v4alpha", force = TRUE, quiet = TRUE)
  expect_true(file.exists(exe))
})

test_that("glm_install_aed_tools(private = TRUE) uses the private repo URL", {
  # Verify the repo argument is set correctly without actually cloning.
  # We intercept .clone_aed_tools() to capture the repo it receives.
  captured <- NULL
  local_mocked_bindings(
    .clone_aed_tools = function(repo, build_dir, quiet) {
      captured <<- repo
      cli::cli_abort("sentinel: stop after clone")
    },
    .package = "GLMAEDr"
  )
  expect_error(
    glm_install_aed_tools(private = TRUE, force = TRUE, quiet = TRUE),
    regexp = "sentinel"
  )
  expect_match(captured, "AED_Tools_Private", fixed = TRUE)
})

test_that("glm_install_aed_tools(private = TRUE) compiles GLM from private repo", {
  skip_on_cran()
  skip_if_not(nzchar(Sys.which("git")),      "git not available")
  skip_if_not(nzchar(Sys.which("make")),     "make not available")
  skip_if_not(nzchar(Sys.which("gfortran")), "gfortran not available")
  skip_if_not(
    nzchar(Sys.which("nc-config")) || nzchar(Sys.which("netcdf-config")),
    "netcdf headers not available"
  )
  # Skip if credentials don't allow access to the private repo.
  has_access <- tryCatch({
    res <- processx::run(
      "git",
      c("ls-remote", "--exit-code",
        "https://github.com/AquaticEcoDynamics/AED_Tools_Private"),
      error_on_status = FALSE
    )
    res$status == 0L
  }, error = function(e) FALSE)
  skip_if_not(has_access, "no access to AED_Tools_Private")

  exe <- glm_install_aed_tools(
    private = TRUE, ref = "v4alpha", force = TRUE, quiet = TRUE
  )
  expect_true(file.exists(exe))
})

test_that("glm_install() compiles and installs GLM from source", {
  skip_on_cran()
  skip_if_not(nzchar(Sys.which("git")),     "git not available")
  skip_if_not(nzchar(Sys.which("make")),    "make not available")
  skip_if_not(nzchar(Sys.which("gfortran")), "gfortran not available")
  skip_if_not(
    nzchar(Sys.which("nc-config")) || nzchar(Sys.which("netcdf-config")),
    "netcdf headers not available"
  )
  exe <- glm_install(force = TRUE, quiet = TRUE)
  expect_true(file.exists(exe))
  if (.Platform$OS.type == "unix") {
    mode <- file.info(exe)$mode
    exec_bits <- bitwAnd(as.integer(as.octmode(mode)), strtoi("111", 8L))
    expect_gt(exec_bits, 0L)
  }
})
