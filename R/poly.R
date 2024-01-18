#' @title Transforms coordinates into a window
#' @description
#' This function transforms polygonal data into an object of class `owin` for \code{spatstat.geom} functions.
#'
#' @param polygon data frame, coordinates of the polygon.
#' @keywords internal
#'
#' @return An object of class `owin` which is a polygonal window.
#'
poly <- function(polygon) {
  pol <- list(x = polygon$lons, y = polygon$lats)

  #owin function from spatstat.geom
  poly_owin <- owin(poly = lapply(pol, rev))

  return(poly_owin)
}
