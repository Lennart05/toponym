#' @title Retrieves the most frequent toponyms in a given polygon
#' @description
#' The function sorts the toponyms in the given countries by frequency. It then tests which lie in the given polygon, printing out a data frame with those toponyms that match the ratio criteria and are, thus, potential candidates for further examination. The coordinates form the polygon, which roughly resembles the Slavic settlement zone in Germany. It is generated with [Google My Maps](https://www.google.com/maps/about/mymaps/).
#' @param countries Character string with country code abbreviations (check \url{https://www.geonames.org/countries/} for a list of available countries) specifying, the toponyms of which countries are checked.
#' @param count numeric. The number of the most frequent endings which will be tested, e.g. by default the top ten most frequent endings in Germany.
#' @param len numeric. The character length of the endings, e.g. by default three-character-long endings.
#' @param rat numeric. The ratio (a number between 0.0 and 1) of how many occurrences of one toponym need to be in the polygon.
#' @param type character string. Either "$" (suffixes) or "^" (prefixes)
#' @param lons numeric. Vector of longitudinal coordinates defining the polygon.
#' @param lats numeric. Vector of latitudinal coordinates defining the polygon.
#' @param feat.class character string with feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list and names of all feature classes in the data). By default, it is \code{p}.
#' @importFrom sp point.in.polygon
#' @importFrom grDevices chull
#'
#' @return A data frame printed out and saved in the global environment. It shows the toponyms surpassing the ratio, at what percentage and the frequency.
#' @export
#'
#' @examples
#' \dontrun{
#' top.candidates()
#' ## prints and saves a data frame of the top ten three-character-long endings in Germany
#' ## if more than 50% of the places lie in the default polygon.
#'
#'
#' top.candidates("GB", count = 100, len = 4, rat = .9,
#'  lons = toponym::danelaw_polygon$lons,
#'  lats = toponym::danelaw_polygon$lats,
#'  )
#' ## prints and saves a data frame of the top 100 four-character-long endings in Great Britian
#' ## if more than 90% of the places lie in the newly defined polygon
#' ## which frames the Danelaw
#'
#'
#' top.candidates(c("BE", "NL") rat = .8,
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
top.candidates <- function(countries, count, len, rat, type = "$", lons, lats, feat.class = "P")
  {
  get.data(countries)
  gn <- read.files(countries, feat.class)

  # query all endings from the dataset
  endings <- paste(if(type == "^"){"^"},
    # creates a reg expr looking for endings of length "len"
    regmatches(gn$name,
               regexpr(paste0(if(type == "^"){"^"},
      paste(replicate(len,"."), collapse = ""), if(type == "$"){"$"}),gn$name)
      ), if(type == "$"){"$"}, sep = "")
  # order them by frequency
  endings_o <- names(table(endings)[order(table(endings), decreasing = TRUE)])

  endings_ID_o <- list()
  lat_strings <- list()
  lon_strings <- list()
  loc_log <- list()
  ratio <- list()
  dat <- list()


  # store coordinates of the polygon in a df
  pol  <- data.frame(X = lons, Y = lats)
  # chull function from package grDevices
  pos <- chull(pol)
  con.hull <- rbind(pol[pos,],pol[pos[1],])   # convex hull


  for (i in 1:count) {
    # stores indices of all ordered endings
    endings_ID_o[[i]] <- unique(grep(endings_o[i], gn$name))

    lat_strings[[i]] <- gn$rlatitude[endings_ID_o[[i]]]
    lon_strings[[i]] <- gn$rlongitude[endings_ID_o[[i]]]
    # country[[i]] <- gn$rcountry_code[endings_ID_o[[i]]]

    # logical vectors storing if each place is within the given area
    loc_log[[i]] <- as.logical(point.in.polygon(lon_strings[[i]], lat_strings[[i]], con.hull$X, con.hull$Y))
    # percentage of places which are in the area
    ratio[[i]] <- sum(loc_log[[i]])/length(loc_log[[i]])

    # select only endings which surpass parameter rat
    if (ratio[[i]]>rat) {
      dat[[i]] <- cbind(endings_o[i], paste0(round(ratio[[i]], 4)*100, "%"),
                        paste0(sum(loc_log[[i]]),"/", length(loc_log[[i]])))

      }}
    # transforms list into a df for printout
  dat <- as.data.frame(cbind(unlist(dat)[c(TRUE, FALSE, FALSE)],
                             unlist(dat)[c(FALSE, TRUE, FALSE)],
                             unlist(dat)[c(FALSE, FALSE, TRUE)]))

  colnames(dat) <- c("ending", "ratio", "frequency")

  dat_name <- paste0("data_top_", count)
  assign(dat_name, dat, envir = .GlobalEnv)
  cat(paste("\nDataframe",dat_name ,"saved in global environment.\n"))

  invisible(return(dat))

  }
