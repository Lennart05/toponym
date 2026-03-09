#' @title Applies Z-test
#' @description
#' This function applies a Z-test.
#'
#' @details
#' This function lets users apply a Z-test (two proportion test), comparing the frequency of a given string in a polygon to the frequency in the rest of the country.
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#' Polygons passed through the \code{polygon} parameter need to intersect or be within a country specified by the \code{countries} parameter.
#'
#' @param strings character string with a regular expression to be tested.
#' @param countries character string vector with country designations (names or ISO-codes).
#' @param polygon data frame. Defines the polygon for comparison with the remainder of a country (or countries).
#' @param ... Additional parameter:
#' \itemize{
#' \item\code{feat.class} character string vector. Selects data only of those feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list of all feature classes). By default, it is \code{P}.
#' }
#' @export
#' @examples
#' \dontrun{
#' topZtest("thorpe$", "GB", toponym::danelaw_polygon)
#' )
#' ## returns an object of class \code{htest} containing the results.
#' }
#' 
#' @return An object of class \code{htest} containing the results.
topZtest <- function(strings, countries, polygon, ...) {

  if(length(strings)>1) stop("This function only permits one string at a time.")

  countries <- unlist(lapply(country(query = countries), function(x) x[, 1]))
  
  if(!all(c("longitude", "latitude") %in% colnames(polygon))) stop("Parameter `polygon` must consist of two columns named `longitude` and `latitude`.")

  ##### store additional parameters and set defaults
  opt <- list(...)
  if(is.null(opt$feat.class)) opt$feat.class <- "P"

  getData(countries) # gets data
  gn <- readFiles(countries, opt$feat.class) # stands for GeoNames


  poly_owin <- poly(polygon)

  poly_log <- inside.owin(x = gn$longitude, y = gn$latitude, w = poly_owin) # check which places are in the polygon

  poly_log <- as.vector(table(poly_log))

  top_in_cc <- poly_log[1] # total number of *places* in the country (but not in the polygon)
  top_in_poly <- poly_log[2] # total number of *places* in the polygon


  strings_ID <- unique(grep(strings, gn$name))
  lat_strings <- gn$latitude[strings_ID]
  lon_strings <- gn$longitude[strings_ID]
  # logical vectors storing if each place is within the given polygon
  loc_log <- inside.owin(x = lon_strings, y = lat_strings, w = poly_owin)

  loc_log <- as.vector(table(loc_log))

  string_in_cc <- loc_log[1] # total number of occurrences in the country but not the polygon
  string_in_poly <- loc_log[2] # total number of occurrences in the polygon




  results <- prop.test(
    x = c(string_in_poly, string_in_cc),
    n = c(top_in_poly, top_in_cc),
    alternative = "greater"
  )


  return(results)
}
