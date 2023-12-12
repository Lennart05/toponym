#' @title ztest
#' @description The functions lets users apply a z-test (two proportion test), comparing the frequency of a given string in an area (polygon) to the frequency in the rest of the country.
#' @param strings character strings in form of regular expression that filter the data frames.
#' @param countries character string with country code abbreviations to be read (check \url{https://www.geonames.org/countries/} for the list of available countries).
#' @param feat.class character string with feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list and names of all feature classes in the data). By default, it is \code{P}.
#' @param lons numeric. Vector of longitudinal coordinates defining the polygon.
#' @param lats numeric. Vector of latitudinal coordinates defining the polygon.
#' @export
#' @return Result of \code{prop.test}
z.test <- function(strings, countries, feat.class = "P", lons, lats) {

  for(i in 1:length(countries)){countries[i] <- country.data(query = countries[i])[,1]} #converts input into ISO2 codes
  countries <- countries[!is.na(countries)] # removes incorrect country names


  get.data(countries) # gets data
  gn <- read.files(countries, feat.class)  # stands for GeoNames


  con.hull <- poly(lons = lons, lats = lats)

  poly_log <- as.logical(point.in.polygon(gn$rlongitude, gn$rlatitude, con.hull$X, con.hull$Y)) # check which places are in the polygon

  poly_log <- as.vector(table(poly_log))

  top_in_cc <- poly_log[1]   # total number of *places* in the country (but not in the polygon)
  top_in_poly <- poly_log[2] # total number of *places* in the polygon


  strings_ID  <- unique(grep(strings, gn$name))
  lat_strings <- gn$rlatitude[strings_ID]
  lon_strings <- gn$rlongitude[strings_ID]
  # logical vectors storing if each place is within the given area
  loc_log <- as.logical(point.in.polygon(lon_strings, lat_strings, con.hull$X, con.hull$Y))

  loc_log <- as.vector(table(loc_log))

  string_in_cc <- loc_log[1]   # total number of occurrences in the country but not the polygon
  string_in_poly <- loc_log[2] # total number of occurrences in the polygon




  results <- prop.test(x = c(string_in_poly, string_in_cc),
                       n = c(top_in_poly, top_in_cc),
                       alternative = "greater")


  return(results)
}
