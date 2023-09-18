#' @title Retrieves the most frequent toponyms in an area
#' @description
#' The function sorts the toponyms found by frequency. Either a polygon within a country or countries can be provided as input.
#' @param countries character string. Country code abbreviations or names (use \code{country.data()} for a list of available countries) specifying the toponyms of which countries are checked.
#' @param len numeric. The character length of the endings.
#' @param feat.class character string with feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list and names of all feature classes in the data). By default, it is \code{p}.
#' @param type character string. Either by default "$" (ending) or "^" (beginning)
#' @param count numeric. The number of the most frequent endings.
#' @param lons numeric. Vector of longitudinal coordinates defining the polygon.
#' @param lats numeric. Vector of latitudinal coordinates defining the polygon.
#' @importFrom sp point.in.polygon
#' @importFrom grDevices chull
#'
#' @return Returns a table with toponym names and their frequency
#' @export
#'
#' @examples
#' \dontrun{
#' top.freq(countries = "Namibia", len = 3, count = 10)
#' ## returns the top ten most frequent toponym endings in Namibia
#'
#' top.freq(countries = "GB", len = 3, count = 10,
#' lons = toponym::danelaw_polygon$lons, lats = toponym::danelaw_polygon$lats)
#' ## returns the top ten most frequent toponym endings in the polygon which is inside the United Kingdom.
#' }
top.freq <- function(countries, len, feat.class = "P", type = "$", count, lons, lats)
{
  for(i in 1:length(countries)){countries[i] <- country.data(query = countries[i])[,1]} #converts input into ISO2 codes
  countries <- countries[!is.na(countries)]

  get.data(countries)
  gn <- read.files(countries, feat.class)

  if(!missing(lons) && !missing(lats)){
  # store coordinates of the polygon in a df
  pol  <- data.frame(X = lons, Y = lats)
  # chull function from package grDevices
  pos <- chull(pol)
  con.hull <- rbind(pol[pos,],pol[pos[1],])   # convex hull

  poly_log <- as.logical(point.in.polygon(gn$rlongitude, gn$rlatitude, con.hull$X, con.hull$Y)) # check which places are in the polygon

  gn <- gn[poly_log,] #only those in the polygon left
  }


  # query all toponyms from the dataset
  toponyms <- paste(if(type == "^"){"^"},
                   # creates a reg expr looking for endings of length "len"
                   regmatches(gn$name,
                              regexpr(paste0(if(type == "^"){"^"},
                                             paste(replicate(len,"."), collapse = ""), if(type == "$"){"$"}),gn$name)
                   ), if(type == "$"){"$"}, sep = "")

  # order them by frequency
  if(missing(count)){
  toponyms_o <- names(table(toponyms)[order(table(toponyms), decreasing = TRUE)]) #only strings left
  }else{
  freq_top <- table(toponyms)[order(table(toponyms), decreasing = TRUE)][1:count] #only a selection of the most frequent toponyms
  return(freq_top)
  }


}
