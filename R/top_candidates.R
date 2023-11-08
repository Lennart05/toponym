#' @title Retrieves the most frequent toponyms in a given polygon relative to the countries
#' @description
#' The function sorts the toponyms in the given countries by frequency. It then tests which  ones lie in the given polygon, printing out a data frame with those toponyms that match the ratio criteria and are, thus, potential candidates for further examination. The coordinates can be defined using create.polygon.
#' @param countries character string. Country code abbreviations or names (use \code{country.data()} for a list of available countries) specifying the countries of which toponyms are checked.
#' @param count numeric. The number of the most frequent toponyms which are included. If unspecified all toponyms satisfying the search criteria are included.
#' @param len numeric. The character length of the toponyms
#' @param rat numeric. The ratio of how many occurrences of one toponym need to be in the polygon. If freq.type is "abs" the ratio is between 0 and 1, if freq.type is "rel" it is between 0 and indefinite.
#' @param type character string. Either "$" (suffixes) or "^" (prefixes)
#' @param lons numeric. Vector of longitudinal coordinates defining the polygon.
#' @param lats numeric. Vector of latitudinal coordinates defining the polygon.
#' @param feat.class character string with feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list and names of all feature classes in the data). By default, it is \code{P}.
#' @param freq.type character string. If set to "abs" (the default), ratios of absolute frequencies inside the area and in the countries as a whole are computed. If set to "rel", ratios of relative frequencies inside the area and outside the area will be computed.
#'
#' @return A data frame printed out and saved in the global environment. It shows the toponyms surpassing the ratio, the ratio (expressed as percentage if freq.type is "abs") and the frequency.
#' @export
#'
#' @examples
#' \dontrun{
#' top.candidates("GB", count = 100, len = 4, rat = .9,
#'  lons = toponym::danelaw_polygon$lons,
#'  lats = toponym::danelaw_polygon$lats)
#' ## prints and saves a data frame of the top 100 four-character-long endings in Great Britain
#' ## if more than 90% of the places lie in the newly defined polygon
#' ## which frames the Danelaw
#'
#'
#' top.candidates("GB", len = 3, rat = 1,
#'  lons = toponym::danelaw_polygon$lons,
#'  lats = toponym::danelaw_polygon$lats,
#'  freq.type="rel")
#' ## prints and saves a data frame of all three-character-long endings in Great Britain
#' ## if they have greater relative frequencies within Danelaw than outside of Danelaw
#'
#'
#' top.candidates(c("BE", "NL"), rat = .8,
#'  lons = toponym::flanders_polygon$lons,
#'  lats = toponym::flanders_polygon$lats)
#'
#' ## prints and saves a data frame of the top 10 three-character-long endings in Belgium
#' ## and Netherlands viewed as a unit if more than 80% of the places lie
#' ## in the newly defined polygon which frames Flanders.
#'
#' .
#'}
#'
top.candidates <- function(countries, count = 0, len, rat, type = "$", lons, lats, feat.class = "P", freq.type = "abs")
  {
  for(i in 1:length(countries)){countries[i] <- country.data(query = countries[i])[,1]} #converts input into ISO2 codes
  countries <- countries[!is.na(countries)] # removes incorrect country names

  get.data(countries) # gets data
  gn <- read.files(countries, feat.class)
  toponyms_o <- top.freq(countries, len, feat.class, type)
  if(count==0) {count <- length(toponyms_o)}

  toponyms_ID_o <- list()
  lat_strings <- list()
  lon_strings <- list()
  loc_log <- list()
  ratio <- list()  # ratio between absolute or relative frequencies, depending on freq.type
  dat <- list()

  con.hull <- poly(lons = lons, lats = lats)

  # for relative frequencies the number of toponyms within the area is needed
  if(freq.type=="rel") {
    n.tops <- nrow(gn)  # number of all toponyms anywhere
    in.poly <- rep(NA, n.tops)
    for (i in 1:n.tops) {
      in.poly[i] <- as.logical(point.in.polygon(gn$rlongitude[i], gn$rlatitude[i], con.hull$X, con.hull$Y))
    }
    n.tops.in.poly <- sum(in.poly)  # number of all toponyms in polygon
    n.tops.out.poly <- n.tops - n.tops.in.poly  # number of all toponyms outside polygon
  }

  for (i in 1:count) {
    # stores indices of all ordered toponyms
    toponyms_ID_o[[i]] <- unique(grep(toponyms_o[i], gn$name))

    lat_strings[[i]] <- gn$rlatitude[toponyms_ID_o[[i]]]
    lon_strings[[i]] <- gn$rlongitude[toponyms_ID_o[[i]]]

    # logical vectors storing if each place is within the given area
    loc_log[[i]] <- as.logical(point.in.polygon(lon_strings[[i]], lat_strings[[i]], con.hull$X, con.hull$Y))
    n.top.in.poly <- sum(loc_log[[i]])  # number of target toponym in polygon
    n.top <- length(loc_log[[i]])  # number of target toponym anywhere
    n.top.out.poly <- n.top - n.top.in.poly

    if(freq.type=="abs"){
      ratio[[i]] <- n.top.in.poly/n.top
    }

    if(freq.type=="rel"){
      ratio[[i]] <- (n.top.in.poly/n.tops.in.poly) / (n.top.out.poly/n.tops.out.poly)
    }

    # select only toponyms which surpass parameter rat
    if(ratio[[i]]>rat) {
      if(freq.type=="abs") {
        dat[[i]] <- cbind(toponyms_o[i], round(ratio[[i]], 4)*100,
                        paste0(sum(loc_log[[i]]),"/", length(loc_log[[i]])))
      }
      if(freq.type=="rel") {
        dat[[i]] <- cbind(toponyms_o[i], round(ratio[[i]], 4),
                          paste0(sum(loc_log[[i]]),"/", length(loc_log[[i]])))
      }
    }
  }

  # transforms list into a df for printout
  if(length(dat)>0) {
    dat <- as.data.frame(cbind(unlist(dat)[c(TRUE, FALSE, FALSE)],
                               unlist(dat)[c(FALSE, TRUE, FALSE)],
                               unlist(dat)[c(FALSE, FALSE, TRUE)]))
    if(freq.type=="abs") {
      colnames(dat) <- c("toponym", "ratio_perc", "frequency")
      dat <- dat[order(as.numeric(dat$ratio_perc), decreasing=TRUE),]
    }
    if(freq.type=="rel") {
      colnames(dat) <- c("toponym", "ratio", "frequency")
      dat <- dat[order(as.numeric(dat$ratio), decreasing=TRUE),]
    }
    dat_name <- paste0("data_top_", count)
    assign(dat_name, dat, envir = .GlobalEnv)
    cat(paste("\nDataframe",dat_name ,"saved in global environment.\n"))

    return(dat)
  }
  else {
   print("No toponyms satisfy the criteria")
  }
}
