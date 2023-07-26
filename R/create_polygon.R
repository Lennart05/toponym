#' @title Creates a polygon
#' @description The function generate a map on which the user creates a polygon by point-and-click.
#' @param continents Character string. Specify a continent for the map
#' @param strings Character string. Specify a country for the map
#' @importFrom rnaturalearth ne_countries
#' @importFrom spatstat.geom clickpoly
#' @importFrom sp plot
#' @return A list with the coordinates of the polygon.
create.polygon <- function(continents, countries) {

if(missing(countries) && missing(continents)) {
map <- ne_countries(scale = 50) # gets a map from pkg "rnaturalearth"
}
else if(missing(countries)){
  map <- ne_countries(continent = continents, scale = 50)
}
else if(missing(continents)){
  map <- ne_countries(country = countries, scale = 50)
}


sp::plot(map)
polygon <- clickpoly(add=TRUE)
return(polygon)
}
