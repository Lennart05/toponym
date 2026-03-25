#' zzz
#'
#' @param libname libname
#' @param pkgname pkgname
#'
#' @keywords internal
#'
.onLoad <- function(libname, pkgname) {
  options(timeout = max(6000, getOption("timeout")))
}
