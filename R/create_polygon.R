#' @title Creates a polygon
#' @description The function generates a map on which the user creates a polygon by point-and-click.
#' @param continents Character string. Specify a continent for the map
#' @param countries Character string. Specify a country for the map
#' @param regions logical. If \code{TRUE} domestic state boundaries are displayed
#' @importFrom rnaturalearth ne_countries
#' @importFrom spatstat.geom clickpoly
#' @importFrom sp plot
#' @export
#' @details
#' This function uses the function clickpoly provided by the spatstat.geom package. The maps are retrieved by the package rnaturalearth.
#'
#' It is meant as simple and quick tool to create polygons which can later be used by the functions top.candidates and candidates.maps.
#'
#' For further details on the point-and-click mechanic refer to the help page for clickpoly.
#'
#' @return A list with the coordinates of the polygon.
create.polygon <- function(countries, continents, regions = FALSE) {

if(!missing(countries)){ # converts country codes into country names required by ne_countries
country_names <- country.names(country_code = countries)
}



if(regions == FALSE){ # if state borders are not asked for (default)

if(missing(countries) && missing(continents)) {
map <- ne_countries(scale = 50) # gets a map from pkg "rnaturalearth"

}else if(missing(countries)){ # only continent provided by user
  map <- ne_countries(continent = continents, scale = 50)

}else if(missing(continents)){ # only country provided by user
  map <- ne_countries(country = country_names, scale = 50)
}


  ### if state borders are asked for
}else if(!missing(continents)) { # continent requests can't be fulfilled with state borders
 print("Continents cannot be specified with the domestic state boundary parameter active. Please enter at least one country code.")

}else if(missing(countries)){ # nothing provided
  print("No country specified. Please enter at least one country code.")

}else{ # countries provided by user
    map <- ne_states(country = country_names)
}





sp::plot(map) # plots the map
polygon <- clickpoly(add=TRUE) # lets the user draw a polygon on the plotted map

polygon <- data.frame(polygon[[4]][[1]][[1]], polygon[[4]][[1]][[2]]) ## saves only lons and lats
names(polygon) <- c("lons", "lats")
return(polygon)


}
