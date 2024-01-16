#' @title Creates a polygon
#' @description
#' This function lets users create a polygon by point-and-click or directly retrieve polygon data.
#' @param countries character string with country designation (name or ISO-code).
#' @param ... Additional parameters:
#' \itemize{
#' \item\code{regions} numeric. Specifies the level of administrative borders. By default \code{0} for displaying only country borders.
#' \item\code{region_name} character string with region name.
#' \item\code{retrieve} logical. If \code{TRUE}, the coordinates of the region or country are returned. No map will be drawn.
#' }
#' @export
#' @details
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#' \code{region_name} accepts region names for the selected countries, which can also be retrieved by \code{country()}.
#' This function uses the function \code{spatstatLocator} provided by the \code{spatstat.utils} package. The maps are retrieved from the \code{geodata} package.
#'
#' In RGui, users either have to middle-click or right-click and then press stop.
#'
#' In RStudio, users exit the point selection by pressing ESC or Finish in the top right corner of the plot.
#' Users whose points are shifted away, are advised to set the zoom settings of RStudio and of their device to 100%:
#'
#' Tools -> Global Options -> Appearance -> Zoom
#'
#'
#' For further details on the point-and-click mechanisms refer to the help page for \code{spatstatLocator}.
#'
#' @examples
#' \dontrun{
#' createPolygon("NA", region_name = "Ohangwena")
#'
#' # a plot of the region Ohangwena in Namibia
#' # by point-and-click a polygon can be created
#'
#' Ohangwena_polygon <- createPolygon(
#' "NA", region_name = "Ohangwena", retrieve = TRUE
#' )
#' # no plot appears
#' # the coordinates of the region are stored in the object
#' }
#' @return A data frame with the coordinates of the polygon.
createPolygon <- function(countries, ...) {
  if(missing(countries)) stop("Parameter 'countries' must be defined.")

  map_path <- paste0(system.file(package = "geodata"), "/extdata")

  ##### store additional parameters and set defaults
  opt <- list(...)
  if(is.null(opt$regions)) opt$regions <- 0
  if(is.null(opt$retrieve)) opt$retrieve <- FALSE
  if(is.logical(opt$regions)) stop("Parameter `regions` must be numeric, not logical.")

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
    Encoding(map$NAME_1) <- "UTF-8"
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
    plot(map) # plots the map
    polygon <- spatstatLocator(type = "o") # lets users draw a polygon on the plotted map
    if(length(polygon$x) == 0) stop("No points were clicked.")
    segments(polygon$x[1], polygon$y[1], tail(polygon$x, n = 1), tail(polygon$y, n = 1))
    polygon <- data.frame(polygon$x, polygon$y) ## saves only lons and lats
  }

  names(polygon) <- c("lons", "lats")
  return(polygon)
}
