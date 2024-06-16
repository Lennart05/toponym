#' @title Plots data onto a map
#' @description
#' This function plots a user-specific data frame onto a map.
#'
#' @param mapdata data frame. A user-specific data frame with coordinates.
#' @param ... Additional parameters:
#' \itemize{
#' \item\code{color} character string vector indicating, which color is assigned to each string.
#' \item\code{regions} numeric. Specifies the level of administrative borders. By default \code{0} for displaying only country borders.
#' \item\code{plot} logical. If \code{FALSE}, the plot will not be printed but saved as .png in the current working directory.
#' \item\code{title} character string. Text for the title of the plot.
#' \item\code{legend_title} character string. Text for the title of the legend. It is prioritized over titles based on the `color` column or parameter and the `group` column.
#' }
#' @details
#' This function's purpose is to allow users to provide own data frames or edited ones exported by this package.
#'
#' The data frame must have \emph{at least} two columns called `latitude` & `longtitude`.
#'
#' Data frames output by the function \code{top()} consist of, among others, a `latitude`, `longitude`, `country code` and `group` column.
#'
#' If the input data frame has a column `color`, the function will assign every value in that column to the respective coordinates and ignore the additional parameter \code{color} (see above).
#'
#' If the input data frame has a column `group`, the function will group data and display a legend.
#'
#' If the input data frame has a `color` and a `group` column, the assignment must match each other. Every `group` (every unique string in that column) must be assigned a unique color throughout the data frame.
#'
#' If `regions`  is set to a value higher than \code{0}, the data frame must have a column `country code`.
#' @return A plot.
#' @export
#'
mapper <- function(mapdata, ...){

opt <- list(...)
if (is.null(opt$regions)) opt$regions <- 0
if (is.null(opt$plot)) opt$plot <- TRUE

if(!is.data.frame(mapdata)) stop("Parameter 'mapdata' must be a data frame.")
if(!all(c("latitude", "longitude") %in% colnames(mapdata))) stop("Parameter `mapdata` must have the following columns: `latitude` & `longitude`.")
if(!any(is.numeric(c(mapdata$latitude, mapdata$longitude)))) stop("The columns  `latitude` & `longitude` must be numeric.")
if(!"country code" %in% colnames(mapdata) && opt$regions > 0) stop("Since no country codes were provided, parameter `regions` cannot exceed 0.")
if(!is.null(mapdata$group) && is.logical(mapdata$group)) stop("The column `group` cannot be logical.")

if(sum(is.na(mapdata$`color`)) > 0){
if("color" %in% colnames(mapdata)) warning(paste(sum(is.na(mapdata$`color`))), " entries are empty in the color column.")
}

if(!is.null(mapdata$color) &&  !is.null(mapdata$group)){
  G <- match(unique(mapdata$group), mapdata$group)
  C <- match(unique(mapdata$color), mapdata$color)
  if(!identical(G, C)) stop("The columns `group` and `color` contain a mismatch.")

}


coordinates <- list(latitude = mapdata$`latitude`, longitude = mapdata$`longitude`, "country code" = mapdata$`country code`, group = mapdata$`group`, color = mapdata$`color`)



simpleMap(strings = opt$title, #optional title
          coordinates = coordinates,
          color = opt$color,
          regions = opt$regions,
          plot = opt$plot,
          legend_title = opt$legend_title #optional legend title
          )


}
