#' @title Plots data onto a map
#' @description
#' This function plots a user-specific data frame onto a map.
#'
#' @param mapdata data frame. A user-specific data frame with coordinates.
#' @param ... Additional parameters:
#' \itemize{
#' \item\code{color} character string vector indicating, which color is assigned to each string. It is prioritized over colors based on the column `color`.
#' \item\code{regions} numeric. Specifies the level of administrative borders. By default \code{0} for displaying only country borders.
#' \item\code{plot_name} character string. If specified, the plot will not be printed but saved as .png in the current working directory. The given character string defines the name of the .png file.
#' \item\code{title} character string. Text for the title of the plot.
#' \item\code{legend_title} character string. Text for the title of the legend. It is prioritized over titles based on column `group`.
#' \item\code{show_legend} logical. If \code{TRUE}, a legend with all unique strings in  the column `group` will be displayed, provided there is a column `group`. If \code{FALSE}, no legend will be displayed. By default, \code{TRUE}.
#' \item\code{frame} data frame. Sets the frame of the map.
#' \item\code{plot_size} numeric. Specifies the value by which the size of the map is scaled.
#' }
#' @details
#' This function's purpose is to allow users to provide data frames by the function \code{top()}, edited ones as well as own data frames.
#'
#' The data frame must have \emph{at least} two columns called `latitude` & `longtitude`.
#'
#' Data frames output by the function \code{top()} consist of, among others, a `latitude`, `longitude`, `country code` and `group` column.
#'
#' If the input data frame has a column `color`, the function will assign every value in that column to the respective coordinates. However, if specified, the additional parameter \code{color} will be used instead of the column `color` (see above).
#'
#' If the input data frame has a column `group`, the function will group data and display a legend.
#'
#' If the input data frame has a `color` and a `group` column, the assignment must match each other. Every `group` (every unique string in that column) must be assigned a unique color throughout the data frame.
#'
#' If `regions`  is set to a value greater than \code{0}, the data frame must have a column `country code`.
#' 
#' Parameter \code{frame} accepts data frames containing coordinates which define the frame of the plot. The data frame must have a column called `latitude` & a column called `longitude`. The latitudinal and longitudinal ranges define the frame of the plot.
#' 
#' Parameter \code{plot_size} accepts numeric values of greater than -1. The plot's size is scaled by the given value. Thus, a value of 0 extends the size by 0%. A value of .1 extends the size by 10%. A value of -.1 reduces the size by 10% and so on.
#' 
#' 
#' @examples
#' \dontrun{
#' mapper(top("itz$", "DE"))
#' # returns a plot with all populated places
#' # in Germany ending in "itz"
#' 
#' 
#' UG_data <- top(c("et$", "wa$"), "UG")
#' UG_data$color <- "blue"
#' UG_data[UG_data$group == "wa", "color"] <- "grey"
#' mapper(UG_data, legend_title = "two strings", title = "Some locations in grey and blue")
#' # returns a plot with all populated places
#' # in Uganda ending in "wa" (grey) and "et" (blue)
#' # the plot is titled "Some locations in grey and blue"
#' # the legend title is "two strings"
#' 
#' }
#' 
#' @return A plot.
#' @export
#'
mapper <- function(mapdata, ...){
opt <- list(...)

 if (is.null(opt$regions)) opt$regions <- 0
 if (!is.null(opt$plot_name) && !is.character(opt$plot_name)) stop("Parameter `plot_name` must be a character string.")
 if (is.null(opt$show_legend)) opt$show_legend <- TRUE
 if (!is.logical(opt$show_legend)) stop("Parameter `show_legend` must be logical.")
 if (!is.data.frame(mapdata)) stop("Parameter `mapdata` must be a data frame.")
 if (!all(c("latitude", "longitude") %in% colnames(mapdata))) stop("Parameter `mapdata` must have the following columns: `latitude` & `longitude`.")
 if (!any(is.numeric(c(mapdata$latitude, mapdata$longitude)))) stop("The columns `latitude` & `longitude` of the data frame in parameter `mapdata` must be numeric.")
 if (!"country code" %in% colnames(mapdata) && opt$regions > 0) stop("Since no country codes were provided, parameter `regions` cannot exceed 0.")
 if (!is.null(mapdata$group) && is.logical(mapdata$group)) stop("The column `group` cannot be logical.")
 if (!is.null(opt$legend_title) && !is.character(opt$legend_title)) stop("Parameter `legend_title` must be a character string.")
 if (!is.null(opt$title) && !is.character(opt$title)) stop("Parameter `title` must be a character string.")
 
  mapper_group <- is.null(mapdata$group)
 if (sum(is.na(mapdata$color)) > 0){
 if ("color" %in% colnames(mapdata)) warning(paste(sum(is.na(mapdata$color))), " entries are empty in the color column.")
  }

 if (!is.null(mapdata$color) &&  !is.null(mapdata$group)){
  G <- match(unique(mapdata$group), mapdata$group)
  C <- match(unique(mapdata$color), mapdata$color)
 if (!identical(G, C)) stop("The columns `group` and `color` contain a mismatch.")
 }
  
  
  mapper_color <- is.null(mapdata$color) # checks if mapper data contains color specification. TRUE if there is no color in map data
  if(all(!is.null(opt$color), mapper_color, is.null(mapdata$group))) { # if the `color` parameter is specified AND if there is neither a color nor a group column in mapdata
    if(length(opt$color) != length(mapdata$latitude) && length(opt$color) != 1) stop("Length of parameter `color` must be either equal to the number of points or 1 if no `group` column is given.")
  }
  

  # color. Priority: optional paremter color, then color column, then group color, then default color (first of rainbow set)
  if(is.null(opt$color)){ # no col parameter
  if(mapper_color){ # no col column
  if(mapper_group){ # no group column
    color <- "#FF0000" # default color
  } else color <- rainbow(length(unique(mapdata$group))) # use rainbow color set if group column
  } else color <- mapdata$color # if col column
  } else {
    if(!mapper_group){ # check if col parameter matches number of groups
    if(length(opt$color) != length(unique(mapdata$group))) stop("The number of colors in parameter `color` must match the number of groups in column `group`.")
    }
    color <- opt$color # if col parameter
    }
  
  
  group <- mapdata$group
  if(mapper_group) 
  {
    opt$show_legend <- FALSE
  }
  
  if (!is.null(opt$frame)){ # TRUE, if frame is specified
  if (!is.data.frame(opt$frame)) stop("Parameter `frame` must be a data frame.")
  if (!all(c("latitude", "longitude") %in% colnames(opt$frame))) stop("The data frame in parameter `frame` must have the following columns: `latitude` & `longitude`.")
  if (!any(is.numeric(c(opt$frame$latitude, opt$frame$longitude)))) stop("The columns `latitude` & `longitude` of the data frame in parameter `frame` must be numeric.")
  }
  if (!is.null(opt$plot_size)) {# TRUE, if plot_size is specified 
  if (!is.numeric(opt$plot_size)) stop("Parameter `plot_size` must be numeric.")
  if (opt$plot_size <= -1) stop("Parameter `plot_size` must be greater than -1.")
  } else opt$plot_size <- .1 # if plot_size is not specified, use default of .1 / 10%
  opt$plot_size <- opt$plot_size / 2
  # Since the range is extended by the factor on both size, the value is halved.
  # Otherwise, e.g., a factor of .1 extends the overall size of the map by 20%.
    
    
  nas <- unique(which(is.na(mapdata$latitude)), which(is.na(mapdata$longitude))) # checks for NAs
  if (length(nas) > 0) {
    mapdata$latitude  <- mapdata$latitude[-nas]
    mapdata$longitude <- mapdata$longitude[-nas]
  }
  
  if(is.data.frame(opt$frame)){ # uses user provided frame if specified
    frame_lats <- opt$frame$latitude
    frame_lons <- opt$frame$longitude
  } else{ # else uses coordinates of map data
    frame_lats <- mapdata$latitude
    frame_lons <- mapdata$longitude
  }
  # get max min long and lat and extend the frame by the value of opt$plot_size around the points
  lat_range <- extendrange(r = range(frame_lats), f = opt$plot_size)
  lng_range <- extendrange(r = range(frame_lons), f = opt$plot_size)

  cc <- unique(mapdata$`country code`) # only store unique 
  
  # list for mapping with map_simple()
  mapdata <- list(latitude = mapdata$`latitude`,
                  longitude = mapdata$`longitude`,
                  group = group,
                  color = color,
                  cc = cc,
                  lng_range = lng_range,
                  lat_range = lat_range,
                  legend_title = opt$legend_title,
                  title = opt$title,
                  show_legend = opt$show_legend,
                  mapper_group = mapper_group,
                  mapper_color = mapper_color,
                  regions = opt$regions
                  )
  
  p <- map_simple(mapdata)
  
  
  # saves or prints plot
  if (is.character(opt$plot_name)) {
    plot_name <- paste0(opt$plot_name, ".png", collapse = "_")
    ggsave(plot_name, path = file.path(getwd(), "plots"))
    message(paste("\nPlot", plot_name, "saved in `plots` folder of the working directory.\n"))
  } else {
    print(p)
  }
}

