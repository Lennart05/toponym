#' @title Creates a polygon
#' @description The function generates a map on which users create a polygon by point-and-click.
#' @param countries character string. Specify a country for the map
#' @param regions numeric. Specify the level of regional borders. By default \code{0} displaying only country borders.
#' @param region_name character string. Specify region names of a country requested by \code{countries}. Only the regions will be displayed for mapping.
#' @export
#' @details
#' This function uses the function clickpoly provided by the spatstat.geom package. The maps are retrieved by the geodata package.
#'
#' It is meant as simple and quick tool to create polygons which can later be used by the functions such as top.candidates and candidates.maps.
#'
#' For further details on the point-and-click mechanic refer to the help page for clickpoly.
#'
#' @return A list with the coordinates of the polygon.
create.polygon <- function(countries, regions = 0, region_name = NULL) {

map_path <- paste0(system.file(package = "geodata"),"/extdata")

if(countries == "world"){
  map <- world(path = map_path) # world map


  }else if(missing(region_name)){ # if no region provided
  map <- gadm(country = countries, level = regions, path = map_path) # country map

  }
  else{ # if region name is provided
  if(regions == 0){regions = 1} # admin level = regions needs to be at least 1 if specific regions are to be displayed
  map <- gadm(country = countries, level = regions, path = map_path)
  map <- map[map$NAME_1 %in% region_name,]
  }

print("If you use RGui, you either have to middle-click or right-click and then press stop. ESC does not work.")

sp::plot(map) # plots the map
polygon <- clickpoly(add=TRUE) # lets users draw a polygon on the plotted map


polygon <- data.frame(polygon[[4]][[1]][[1]], polygon[[4]][[1]][[2]]) ## saves only lons and lats
names(polygon) <- c("lons", "lats")
return(polygon)


}
