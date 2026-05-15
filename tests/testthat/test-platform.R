test_that("get_platform() returns a non-empty string", {
  platform <- GLMAEDr:::get_platform()
  expect_type(platform, "character")
  expect_true(nzchar(platform))
})

test_that("get_platform() returns a recognised prefix on current OS", {
  platform <- GLMAEDr:::get_platform()
  valid <- platform == "windows" ||
    startsWith(platform, "macos-") ||
    startsWith(platform, "ubuntu-")
  expect_true(valid, label = paste("platform =", platform))
})

test_that("parse_ubuntu_version() extracts the VERSION_ID field", {
  pv <- GLMAEDr:::parse_ubuntu_version
  expect_equal(pv(c('VERSION_ID="22.04"')), "22.04")
  expect_equal(pv(c('VERSION_ID="24.04"')), "24.04")
  expect_equal(pv(c('VERSION_ID=20.04')),   "20.04")
  expect_equal(pv(character(0)),            "unknown")
})

test_that("glm_exe_path() returns a character path ending in glm or glm.exe", {
  path <- glm_exe_path()
  expect_type(path, "character")
  expect_true(
    endsWith(path, "glm") || endsWith(path, "glm.exe"),
    label = paste("path =", path)
  )
})

test_that("glm_is_installed() returns a logical", {
  result <- glm_is_installed()
  expect_type(result, "logical")
  expect_length(result, 1L)
})
