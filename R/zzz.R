.onAttach <- function(libname, pkgname) {
  if (!glm_is_installed()) {
    packageStartupMessage(
      "GLMAEDr: GLM is not yet installed on this machine.\n",
      "  Run GLMAEDr::glm_install() to compile and install GLM from source.\n",
      "  See ?glm_install for system requirements."
    )
  }
}
