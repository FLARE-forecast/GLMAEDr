test_that("run_glm() errors with a clear message when NML file is missing", {
  expect_error(
    run_glm(tempdir(), nml_file = "nonexistent.nml"),
    regexp = "NML configuration file not found"
  )
})

test_that("run_glm() errors when sim_folder does not exist", {
  expect_error(
    run_glm("/no/such/path"),
    regexp = "no/such/path"
  )
})

test_that("get_glm_exe() aborts helpfully when GLM is not installed", {
  exe <- glm_exe_path()
  if (file.exists(exe)) {
    skip("GLM is installed; cannot test the not-installed path")
  }
  expect_error(
    GLMAEDr:::get_glm_exe(),
    regexp = "glm_install"
  )
})

test_that("get_lib_env() returns the current environment unchanged", {
  env <- GLMAEDr:::get_lib_env()
  expect_type(env, "character")
  expect_true("PATH" %in% names(env))
  expect_equal(env[["PATH"]], Sys.getenv("PATH"))
})

test_that("run_glm() runs a complete simulation successfully", {
  skip_on_cran()
  skip_if_not(glm_is_installed(), "GLM not installed — run glm_install() first")

  sim <- sim_folder_fixture()
  expect_no_error(result <- run_glm(sim, verbose = FALSE))
  expect_equal(result$status, 0L)
  expect_true(
    file.exists(file.path(sim, "output", "output.nc")),
    label = "output/output.nc was created"
  )
})

test_that("run_glm() respects verbose = FALSE", {
  skip_on_cran()
  skip_if_not(glm_is_installed(), "GLM not installed — run glm_install() first")

  sim <- sim_folder_fixture()
  out <- capture.output(run_glm(sim, verbose = FALSE))
  expect_length(out, 0L)
})
