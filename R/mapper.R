#' @title Plots data onto a map
#' @description
#' This function plots a user-specific data frame onto a map.
#'
#' @param mapdata data frame. A user-specific data frame with coordinates.
#' @param ... Additional parameters:
#' \itemize{
#' \item\code{color} character string indicating, which color is assigned to each string.
#' \item\code{regions} numeric. Specifies the level of administrative borders. By default \code{0} for displaying only country borders.
#' \item\code{plot} logical. If \code{FALSE}, the plot will not be printed but saved as .png in the current working directory.
#' \item\code{label} character string. Text for the title of plot.
#' }
#' @details
#' This function's purpose is to allow users to provide own data frames or curated ones exported by this package.
#' The data frame must have at least two columns called `latitude` & `longtitude`. If the data frame has a column `color`, the function will assign every value in that column to the respective coordinates and ignore the optional parameter \code{color}.
#' If `regions`  is set to a value higher than 0, either the data frame must have a column `country codes` or the parameter \code{countries} must be defined.
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#' @return A plot.
#' @export
#'
mapper <- function(mapdata, ...){

opt <- list(...)
if (is.null(opt$regions)) opt$regions <- 0
if (is.null(opt$plot)) opt$plot <- TRUE

if(!is.data.frame(mapdata)) stop("'mapdata' must be a data frame.")
if(!all(c("name", "latitude", "longitude") %in% colnames(mapdata))) stop("'mapdata' must have the following columns: `latitude' & 'longitude'.")
if(!"country code" %in% colnames(mapdata) && opt$regions > 0) stop("Since no country codes were provided, parameter `regions` cannot exceed 0.")

if("color" %in% colnames(mapdata)) warning(paste("sum(is.na(mapdata$`color`) entries are empty in the color column."))



coordinates <- list(latitude = mapdata$`latitude`, longitude = mapdata$`longitude`, "country code" = mapdata$`country code`, matches = mapdata$`matches`, color = mapdata$`color`)



simpleMap(opt$label, #optional labels
          coordinates, opt$color, opt$regions, opt$plot)


}
