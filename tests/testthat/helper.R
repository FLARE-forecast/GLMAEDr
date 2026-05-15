# Returns a temporary copy of the bundled extdata directory so integration
# tests can write output files without dirtying the package install tree.
sim_folder_fixture <- function() {
  src <- system.file("extdata", package = "GLMAEDr")
  dst <- file.path(tempdir(), paste0("glm_test_", Sys.getpid()))
  dir.create(dst, recursive = TRUE, showWarnings = FALSE)
  file.copy(list.files(src, full.names = TRUE), dst)
  dst
}
