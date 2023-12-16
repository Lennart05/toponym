#' @title Transforms coordinates into a convex hull
#'
#' @param lons numeric. Vector of longitudinal coordinates defining the polygon.
#' @param lats numeric. Vector of latitudinal coordinates defining the polygon.
#' @keywords internal
#'
#' @return a convex hull
#'
poly <- function(lons, lats) {
  # store coordinates of the polygon in a df
  pol <- data.frame(X = lons, Y = lats)
  # chull function from package grDevices
  pos <- chull(pol)
  con.hull <- rbind(pol[pos, ], pol[pos[1], ]) # convex hull

  return(con.hull)
}
