#' @title Creates a polygon
#' @description The function generates a map on which users create a polygon by point-and-click.
#' @param countries character string. Specify a country for the map
#' @param regions numeric. Specify the level of regional borders. By default \code{0} displaying only country borders.
#' @param region_name character string. Specify region names of a country requested by \code{countries}. Only the regions will be displayed for mapping.
#' @param retrieve  logical. If set to \code{TRUE}, the coordinates of the region or country are output. No map will be drawn.
#' @export
#' @details
#' This function uses the function clickpoly provided by the spatstat.geom package. The maps are retrieved by the geodata package.
#'
#' It is meant as simple and quick tool to create polygons which can later be used by the functions such as topComp and topCompOut().
#'
#' For further details on the point-and-click mechanic refer to the help page for clickpoly.
#'
#' WARNING: If you use RStudio and increased the zoom level, points will be shifted. Check.... global options and make sure it is set to 100%
#'
#' @return A list with the coordinates of the polygon.
createPolygon <- function(countries, ...) {
  map_path <- paste0(system.file(package = "geodata"), "/extdata")

  opt <- list(...)
  if(is.null(opt$regions)) opt$regions <- 0
  if(is.null(opt$retrieve)) opt$retrieve <- FALSE

  if (any(countries == "world")) {
    countries <- "world"
    map <- world(path = map_path) # world map
  } else if (is.null(opt$region_name)) { # if no region provided
    map <- gadm(country = countries, level = opt$regions, path = map_path) # country map
  } else { # if region name is provided
    if (opt$regions == 0) {
      opt$regions <- 1
    } # admin level = regions needs to be at least 1 if specific regions are to be displayed
    map <- gadm(country = countries, level = opt$regions, path = map_path)
    map <- map[map$NAME_1 %in% opt$region_name, ]
  }

  if (opt$retrieve == TRUE) { # if polygon data is to be extracted
    if (length(countries) > 1) { # only one country at the same is allowed
      stop("The number of countries for polygon retrival may not exceed 1.")
    } else if (any(countries == "world")) { # world shouldn't be extracted
      stop("'world' is not a valid query for polygon retrival.")
    }
    polygon <- as.data.frame(crds(map)) # retrieves coordinates of subset or country from map data
  } else { # lets users draw on subset or country
    message("If you use RGui, you either have to middle-click or right-click and then press stop. ESC does not work.")

    sp::plot(map) # plots the map
    polygon <- spatstatLocator(type = "o") # lets users draw a polygon on the plotted map
    if(length(polygon$x) == 0) stop("No points were clicked.")
    segments(polygon$x[1], polygon$y[1], tail(polygon$x, n = 1), tail(polygon$y, n = 1))
    polygon <- data.frame(polygon$x, polygon$y) ## saves only lons and lats
  }

  names(polygon) <- c("lons", "lats")
  return(polygon)
}
