#' @title Transforms coordinates into a convex hull
#'
#' @param lons numeric. Vector of longitudinal coordinates defining the polygon.
#' @param lats numeric. Vector of latitudinal coordinates defining the polygon.
#' @keywords internal
#'
#' @return a convex hull
#'
poly <- function(polygon) {
  pol <- data.frame(X = polygon$lons, Y = polygon$lats)
  # chull function from package grDevices
  pos <- chull(polygon)
  con.hull <- rbind(pol[pos, ], pol[pos[1], ]) # convex hull

  return(con.hull)
}
