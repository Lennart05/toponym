#' @title Creates a polygon
#' @description
#' This function lets users create a polygon by point-and-click or directly retrieve polygon data.
#' @param countries character string vector with country designations (names or ISO-codes).
#' @param ... Additional parameters:
#' \itemize{
#' \item\code{regions} numeric. Specifies the level of administrative borders. By default \code{0} for displaying only country borders.
#' \item\code{region_ID} character string vector with region IDs.
#' \item\code{region_name} character string vector with region names.
#' \item\code{retrieve} logical. If \code{TRUE}, the coordinates of the region or country are returned. No map will be drawn.
#' \item\code{toponym_path} character string. Path name for downloaded data.
#' }
#' @export
#' @details
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#'
#' \code{region_ID} and \code{region_name} accepts region designations for the selected countries, which can be retrieved by \code{country()}.
#' The function prioritizes any \code{region_ID} and ignores \code{region_name} if users provide both.
#' The matrix from \code{country()} listing all region designations may be incomplete as the \code{geodata} map data is incomplete in this regard. For mapping purposes, \code{geodata} is used throughout this package.
#'
#' Parameter \code{toponym_path} accepts `"pkgdir"` for the package directory or a full, alternative path.
#' With \code{toponymOptions()}, users can specify the path for toponym and map data downloaded by this package across sessions. See `help(toponymOptions)`.
#'
#' In RGui, users exit the point selection by middle-clicking or right-clicking and then pressing stop.
#'
#' In RStudio, users exit the point selection by pressing ESC or Finish in the top right corner of the plot.
#' Users whose points are shifted away, are advised to set the zoom settings of RStudio and of their device to 100%:
#'
#' Tools -> Global Options -> Appearance -> Zoom
#'
#' This function uses the function \code{spatstatLocator} provided by the \code{spatstat.utils} package for the point-and-click functionality.
#' For further details on the point-and-click mechanism, please refer to the help page for \code{spatstatLocator}.
#'
#' @examples
#' ## We recommend setting a persistent path for downloaded data by using toponymOptions()
#' ## Users can always set the path manually when a function is used
#' ## For illustration purposes in the following examples,
#' ## 1. the path is manually set each time
#' ## 2. and wrapped in donttest because data will be downloaded
#' ## 3. or if(interactive) because it is interactive:
#' if(interactive()){
#' createPolygon("NA", region_ID = "NAM.7_1", toponym_path = tempdir())
#' # a plot of the region Ohangwena in Namibia appears.
#' # by point-and-click a polygon can be created
#' # upon completion, a data frame with the coordinates of the polygon returns
#' }
#' 
#' \donttest{
#' Ohangwena_polygon <- createPolygon(
#' "NA", region_ID = "NAM.7_1", retrieve = TRUE, toponym_path = tempdir())
#' # no plot appears
#' # the coordinates of the whole region are stored in the object named `Ohangwena_polygon`
#' # and can be used by other functions
#' }
#' @return A data frame with the coordinates of the polygon.
createPolygon <- function(countries, ...) {
  if(missing(countries)) stop("Parameter 'countries' must be defined.")

  ##### store additional parameters and set defaults
  opt <- list(...)
  if(is.null(opt$regions)) opt$regions <- 0
  if(is.null(opt$retrieve)) opt$retrieve <- FALSE
  if(!is.numeric(opt$regions)) stop("Parameter `regions` must be numeric.")
  if(!is.logical(opt$retrieve)) stop("Parameter `retrieve` must be logical.")
  toponym_path <- checkPath(toponym_path = opt$toponym_path)
  if (any(countries == "world")) {
    countries <- "world"
    map <- world(path = toponym_path) # world map
  } else if (all(is.null(opt$region_ID), is.null(opt$region_name))) { # if no region provided
    map <- gadm(country = countries, level = opt$regions, path = toponym_path) # country map




  } else if(!all(is.null(opt$region_ID), is.null(opt$region_name))) { # if region designation is provided
    if (opt$regions == 0) opt$regions <- 1 # admin level = regions needs to be at least 1 if specific regions are to be displayed

    map <- gadm(country = countries, level = opt$regions, path = toponym_path)  ## country map first
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

  names(polygon) <- c("longitude", "latitude")
  return(polygon)
}
