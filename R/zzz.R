#' zzz
#'
#' @param libname libname
#' @param pkgname pkgname
#'
#' @keywords internal
#'
.onLoad <- function(libname, pkgname) {
  .top_env <<- new.env(parent = emptyenv())
  if (is.null(getOption("global"))) {
  options(global = FALSE)
  }
  if (is.null(getOption("save_data"))) {
  options(save_data = FALSE)
  }
}
