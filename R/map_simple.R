#' @title Plots toponyms onto a map
#' @description
#' This function generates a map plotting all locations in a given data frame. This function uses map data from the \code{geodata} package.
#' @details
#' This is an internal function which is only used by \code{mapper()}.
#' @param mapdata list. A list passed down by \code{mapper()}. It contains at least longitudinal and latitudinal data.
#' @keywords internal
#' @return A plot.
map_simple <- function(mapdata) {

  md <- as.data.frame(cbind(as.numeric(mapdata$longitude),
                            as.numeric(mapdata$latitude))) # creates df
  colnames(md) <- c("longitude", "latitude")
  
  
  # download map data
  map_path <- paste0(system.file(package = "geodata"), "/extdata")
  if (mapdata$regions == 0) {
    map <- world(path = map_path) # gets world map from pkg "geodata"
  } else {
    map <- gadm(country = mapdata$cc, level = mapdata$regions, path = map_path) # gets map of specified countries with domestic borders from pkg "geodata"
    # if(!missing(region_name)){map <- map[map$NAME_1 %in% region_name,]}
    if(is.null(map)) stop(paste("Map data could not be retrieved.", if(mapdata$regions >= 1) "`regions` parameter may be set too high"))
  }
  
  
  
  map <- sf::st_as_sf(map) # converts map into simple features map
  
  # creates plot
  if(mapdata$mapper_color){ # TRUE if no mapper color column
    p <- ggplot() +
      geom_sf(data = map) +
      theme_classic() +
      geom_point(data = md, mapping = aes(x = md[,"longitude"], y = md[,"latitude"], col = if(mapdata$mapper_group) mapdata$color else mapdata$group), show.legend = mapdata$show_legend) +
      coord_sf(
        xlim = c(min(mapdata$lng_range), max(mapdata$lng_range)),
        ylim = c(min(mapdata$lat_range), max(mapdata$lat_range))
      ) +
      scale_color_manual(values = mapdata$color, limits = unique(mapdata$group), name = if(!is.null(mapdata$legend_title)){mapdata$legend_title}else if(!mapdata$mapper_group){"strings"} else{""}) +
      labs(x = "longitude", y = "latitude", title = mapdata$title)
    
  } else if(!mapdata$mapper_color){ # TRUE if mapper color column
    p <- ggplot() +
      geom_sf(data = map) +
      theme_classic() +
      geom_point(data = md, mapping = aes(x = md[,"longitude"], y = md[,"latitude"], col = if(mapdata$mapper_group){mapdata$color} else{mapdata$group}), show.legend = mapdata$show_legend) +
      scale_color_manual(values = unique(mapdata$color), limits = if(mapdata$mapper_group){unique(mapdata$color)} else{unique(mapdata$group)}, name = if(!is.null(mapdata$legend_title)){mapdata$legend_title}else if(!mapdata$mapper_group){"strings"} else{""}) +
      coord_sf(
        xlim = c(min(mapdata$lng_range), max(mapdata$lng_range)),
        ylim = c(min(mapdata$lat_range), max(mapdata$lat_range))
      ) +
    labs(x = "longitude", y = "latitude", title = mapdata$title)
  }
  
 return(p) 
  
  
}