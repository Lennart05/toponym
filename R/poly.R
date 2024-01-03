#' @title Transforms coordinates into a convex hull
#'
#' @param polygon data frame, coordinates of the polygon
#' @keywords internal
#'
#' @return A convex hull.
#'
poly <- function(polygon) {
  pol <- data.frame(X = polygon$lons, Y = polygon$lats)
  # chull function from package grDevices
  pos <- chull(polygon)
  con.hull <- rbind(pol[pos, ], pol[pos[1], ]) # convex hull

  return(con.hull)
}
