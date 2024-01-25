#' @title Creates a polygon
#' @description
#' This function lets users create a polygon by point-and-click or directly retrieve polygon data.
#' @param countries a character string vector with country designations (names or ISO-codes).
#' @param ... Additional parameters:
#' \itemize{
#' \item\code{regions} numeric. Specifies the level of administrative borders. By default \code{0} for displaying only country borders.
#' \item\code{region_name} a character string vector with region names.
#' \item\code{region_ID} a character string vector with region IDs.
#' \item\code{retrieve} logical. If \code{TRUE}, the coordinates of the region or country are returned. No map will be drawn.
#' }
#' @export
#' @details
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#' \code{region_ID} and \code{region_name} accepts region designations for the selected countries, which can be retrieved by \code{country()}.
#' The function prioritizes any \code{region_ID} and ignores \code{region_name} if users provide both.
#' The matrix listing all region designations may be incomplete as the \code{geodata} mapa data is incomplete in this regard. For mapping purposes, \code{geodata} is used throughout this package.
#'
#'
#' This function uses the function \code{spatstatLocator} provided by the \code{spatstat.utils} package for the point-and-click functionality.
#'
#' In RGui, users exit the point selection by middle-clicking or right-clicking and then pressing stop.
#'
#' In RStudio, users exit the point selection by pressing ESC or Finish in the top right corner of the plot.
#' Users whose points are shifted away, are advised to set the zoom settings of RStudio and of their device to 100%:
#'
#' Tools -> Global Options -> Appearance -> Zoom
#'
#'
#' For further details on the point-and-click mechanism, please refer to the help page for \code{spatstatLocator}.
#'
#' @examples
#' \dontrun{
#' createPolygon("NA", region_ID = "NAM.7_1")
#'
#' # a plot of the region Ohangwena in Namibia
#' # by point-and-click a polygon can be created
#' # use country() to find all acceptable region IDs
#' Ohangwena_polygon <- createPolygon(
#' "NA", region_ID = "NAM.7_1", retrieve = TRUE
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
  if(!is.numeric(opt$regions)) stop("Parameter `regions` must be numeric.")
  if(!is.logical(opt$retrieve)) stop("Parameter `retrieve` must be logical.")

  if (any(countries == "world")) {
    countries <- "world"
    map <- world(path = map_path) # world map
  } else if (all(is.null(opt$region_ID), is.null(opt$region_name))) { # if no region provided
    map <- gadm(country = countries, level = opt$regions, path = map_path) # country map




  } else if(!all(is.null(opt$region_ID), is.null(opt$region_name))) { # if region designation is provided
    if (opt$regions == 0) opt$regions <- 1 # admin level = regions needs to be at least 1 if specific regions are to be displayed

    map <- gadm(country = countries, level = opt$regions, path = map_path)  ## country map first
    if(is.null(map)) stop(paste("Map data could not be retrieved.", if(opt$regions >= 1) "Parameter 'regions' parameter may be set too high"))

    if(!is.null(opt$region_ID)){ # FIRST region ID
    map <- map[map$GID_1 %in% opt$region_ID]   ## selection of region within country
    }else if(!is.null(opt$region_name)){ # ELSE region name
    map <- map[map$NAME_1 %in% opt$region_name]   ## selection of region within country
    }

    if(length(map) == 0) stop("Map data could not be retrieved. Region designation may be invalid.")
  }

  if (opt$retrieve == TRUE) { # if polygon data is to be extracted
    if (length(countries) > 1) { # only one country at the same is allowed
      stop("The number of countries for polygon retrival may not exceed 1.")
    } else if (any(countries == "world")) { # world shouldn't be extracted
      stop("'world' is not a valid query for polygon retrival.")
    }
    polygon <- as.data.frame(crds(map)) # retrieves coordinates of subset or country from map data

  } else { # lets users draw on subset or country
    terra::plot(map) # plots the map
    polygon <- spatstatLocator(type = "o") # lets users draw a polygon on the plotted map
    if(length(polygon$x) == 0) stop("No points were clicked.")
    segments(polygon$x[1], polygon$y[1], tail(polygon$x, n = 1), tail(polygon$y, n = 1))
    polygon <- data.frame(polygon$x, polygon$y) ## saves only lons and lats
  }

  names(polygon) <- c("lons", "lats")
  return(polygon)
}
