#' @title Transforms coordinates into a window
#' @description
#' This function transforms polygonal data into an object of class `owin` for \code{spatstat.geom} functions.
#' If data points run clockwise, data will be reversed for \code{owin} function. It requires counterclockwise data.
#' @param polygon data frame, coordinates of the polygon.
#' @keywords internal
#'
#' @return An object of class `owin` which is a polygonal window.
#'
poly <- function(polygon) {
  pol <- list(x = polygon$lons, y = polygon$lats)

  x.coords <- c(pol$x, pol$x[1])
  y.coords <- c(pol$y, pol$y[1])

  double.area <- sum(sapply(2:length(x.coords), function(i) {
    (x.coords[i] - x.coords[i-1])*(y.coords[i] + y.coords[i-1])
  }))

  if(double.area > 0) pol = lapply(pol, rev) # check if points run clockwise. If so, reverse it
  #owin function require polygon data to be COUNTER clockwise

  #owin function from spatstat.geom
  poly_owin <- owin(poly = pol)

  return(poly_owin)
}
