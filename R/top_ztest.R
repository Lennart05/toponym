#' @title Applies Z-test
#' @description
#' This function applies a Z-test.
#'
#' @details
#' This function lets users apply a Z-test (two proportion test), comparing the frequency of a given string in a polygon to the frequency in the rest of the country.
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#' Polygons passed through the \code{polygon} parameter need to intersect or be within a country specified by the \code{countries} parameter.
#' Parameter \code{toponym_path} accepts `"pkgdir"` for the package directory or a full, alternative path.
#' With \code{toponymOptions()}, users can specify the path for toponym and map data downloaded by this package across sessions. See `help(toponymOptions)`.
#' The data used is downloaded by \code{getData()} and is accessible on the [GeoNames download server](https://download.geonames.org/export/dump/).
#'
#' @param strings character string with a regular expression to be tested.
#' @param countries character string vector with country designations (names or ISO-codes).
#' @param polygon data frame. Defines the polygon for comparison with the remainder of a country (or countries).
#' @param ... Additional parameter:
#' \itemize{
#' \item\code{feat.class} character string vector. Selects data only of those feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list of all feature classes). By default, it is \code{P}.
#' \item\code{toponym_path} character string. Path name for downloaded data.
#' }
#' @export
#' @examples
#' ## We recommend setting a persistent path for downloaded data by using toponymOptions()
#' ## Users can always set the path manually when a function is used
#' ## For illustration purposes,
#' ## 1. the path is manually set each time
#' ## 2. and wrapped in donttest because data will be downloaded in the following example:
#' \donttest{
#' topZtest("thorpe$",
#'          "GB",
#'          toponym::danelaw_polygon,
#'          toponym_path = tempdir())
#' ## returns an object of class htest containing the results.
#' }
#' @return An object of class \code{htest} containing the results.
topZtest <- function(strings, countries, polygon, ...) {
  opt <- list(...)
  if(length(strings)>1) stop("This function only permits one string at a time.")
  path <- checkPath(toponym_path = opt$toponym_path)
  countries <- unlist(lapply(country(query = countries, toponym_path = path), function(x) x[, 1]))
  
  if(!all(c("longitude", "latitude") %in% colnames(polygon))) stop("Parameter `polygon` must consist of two columns named `longitude` and `latitude`.")


  if(is.null(opt$feat.class)) opt$feat.class <- "P"

  getData(countries, toponym_path = path) # gets data
  gn <- readFiles(countries, opt$feat.class, toponym_path = path) # stands for GeoNames


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
