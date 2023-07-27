#' @title Creates a polygon
#' @description The function generates a map on which the user creates a polygon by point-and-click.
#' @param continents Character string. Specify a continent for the map
#' @param strings Character string. Specify a country for the map
#' @importFrom rnaturalearth ne_countries
#' @importFrom spatstat.geom clickpoly
#' @importFrom sp plot
#' @export
#' @details
#' This function uses the function \code{clickpoly} provided by the \code{spatstat.geom} package. The maps are retrieved by the package \code{rnaturalearth}.
#'
#' It is meant as simple and quick tool to create polygons which can later be used by the functions \code{top.candidates} and \code{candidates.maps}.
#'
#' For further details on the point-and-click mechanic refer to the help page for \code{clickpoly}.
#'
#' @return A list with the coordinates of the polygon.
create.polygon <- function(continents, countries) {

if(missing(countries) && missing(continents)) {
map <- ne_countries(scale = 50) # gets a map from pkg "rnaturalearth"
}
else if(missing(countries)){ # only continent provided by user
  map <- ne_countries(continent = continents, scale = 50)
}
else if(missing(continents)){ # only country provided by user
  map <- ne_countries(country = countries, scale = 50)
}


sp::plot(map)
polygon <- clickpoly(add=TRUE)
return(polygon)
}
