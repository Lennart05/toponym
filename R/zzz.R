#' zzz
#'
#' @param libname libname
#' @param pkgname pkgname
#'
#' @keywords internal
#'
.onLoad <- function(libname, pkgname) {
  .top_env <<- new.env(parent = emptyenv())
}
