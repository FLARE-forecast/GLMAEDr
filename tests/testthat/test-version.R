test_that("glm_version() returns a non-empty string containing 'GLM'", {
  skip_on_cran()
  skip_if_not(glm_is_installed(), "GLM not installed — run glm_install() first")

  ver <- glm_version()
  expect_type(ver, "character")
  expect_true(nzchar(ver))
  expect_match(ver, "GLM", ignore.case = TRUE)
})

test_that("nml_template_path() returns an existing file", {
  path <- nml_template_path()
  expect_true(file.exists(path))
  expect_true(endsWith(path, "glm3.nml"))
})
