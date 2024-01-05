#' @title Compares toponyms of a polygon and countries
#' @description
#' This function retrieves the most frequent toponyms in a given polygon relative to the countries' frequency
#' @details
#' This function sorts the toponyms in the given countries by frequency. It then tests which lie in the given polygon and prints out a data frame with those frequent toponyms that match the ratio criteria.
#' Parameter \code{countries} accepts all references found in \code{country(query = "country table")}.
#' Polygons passed through the \code{polygon} parameter need to intersect a country of \code{countries}.
#' @param countries character string with country reference (name or iso-code).
#' @param len numeric. The character length of the toponyms.
#' @param rat numeric. The ratio (a number between 0.0 and 1) of how many occurrences of one toponym need to be in the polygon.
#' @param polygon data frame. Polygon for comparison with the country.
#'
#' @param ... Additional parameters:
#' \itemize{
#' \item\code{type} character string. Either by default "$" (ending) or "^" (beginning).
#' \item\code{feat.class} character string with feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list and names of all feature classes in the data). By default, it is \code{P}.
#' \item\code{freq.type} character string. If "abs" (the default), ratios of absolute frequencies inside the area and in the countries as a whole are computed. If "rel", ratios of relative frequencies inside the area and outside the area will be computed.
#' \item\code{limit} numeric. The number of the most frequent toponyms which will be tested.
#' }
#' @return A data frame printed out and saved in the global environment. It shows toponyms surpassing the ratio, the ratio (expressed as percentage if freq.type is "abs") and the frequency.
#' @export
#'
#' @examples
#' \dontrun{
#' topComp("GB",
#'   count = 100, len = 4, rat = .9,
#'   polygon = toponym::danelaw_polygon
#' )
#' ## prints and saves a data frame of the top 100 four-character-long endings in Great Britain
#' ## if more than 90% of the places lie in the newly defined polygon
#' ## which frames the Danelaw.
#'
#'
#' topComp("GB",
#'   len = 3, rat = 1,
#'   polygon = toponym::danelaw_polygon,
#'   freq.type = "rel"
#' )
#' ## prints and saves a data frame of all three-character-long endings in Great Britain
#' ## if they have greater relative frequencies within Danelaw than outside of Danelaw.
#'
#'
#' topComp(c("BE", "NL"),
#'   rat = .8,
#'   polygon = toponym::flanders_polygon
#' )
#'
#' ## prints and saves a data frame of the top 10 three-character-long endings in Belgium
#' ## and Netherlands viewed as a unit if more than 80% of the places lie
#' ## in the newly defined polygon which frames Flanders.
#'
#' .
#' }
#'
topComp <- function(countries, len, rat, polygon, ...) {

  countries <- country(query = countries)
  for (i in 1:length(countries)) {
    countries[i] <- countries[[i]][, 1]
  } # converts input into ISO2 codes
  countries <- unlist(countries)

  opt <- list(...)
  if(is.null(opt$feat.class)) opt$feat.class <- "P"
  if(is.null(opt$type)) opt$type <- "$"
  if(is.null(opt$freq.type)) opt$freq.type <- "abs"

  getData(countries) # gets data
  gn <- readFiles(countries, opt$feat.class)
  if (is.null(opt$limit)) {
    toponyms_o <- topFreq(countries = countries, len = len, limit = "fnc", feat.class = opt$feat.class, type = opt$type)
    opt$limit <- length(toponyms_o)
    message("Limit was not specified. All toponyms will be tested. This may take a while.")
  } else{
    toponyms_o <- topFreq(countries = countries, len = len, limit = opt$limit, feat.class = opt$feat.class, type = opt$type)
    toponyms_o <- names(toponyms_o)
  }
  toponyms_ID_o <- list()
  lat_strings <- list()
  lon_strings <- list()
  loc_log <- list()
  ratio <- list() # ratio between absolute or relative frequencies, depending on freq.type
  dat <- list()

  con.hull <- poly(polygon)

  # for relative frequencies the number of toponyms within the area is needed
  if (opt$freq.type == "rel") {
    n.tops <- nrow(gn) # number of all toponyms anywhere
    in.poly <- rep(NA, n.tops)
    for (i in 1:n.tops) {
      in.poly[i] <- as.logical(point.in.polygon(gn$longitude[i], gn$latitude[i], con.hull$X, con.hull$Y))
    }
    n.tops.in.poly <- sum(in.poly) # number of all toponyms in polygon
    n.tops.out.poly <- n.tops - n.tops.in.poly # number of all toponyms outside polygon
  }

  for (i in 1:opt$limit) {
    # stores indices of all ordered toponyms
    toponyms_ID_o[[i]] <- unique(grep(toponyms_o[i], gn$name))

    lat_strings[[i]] <- gn$latitude[toponyms_ID_o[[i]]]
    lon_strings[[i]] <- gn$longitude[toponyms_ID_o[[i]]]

    # logical vectors storing if each place is within the given area
    loc_log[[i]] <- as.logical(point.in.polygon(lon_strings[[i]], lat_strings[[i]], con.hull$X, con.hull$Y))
    n.top.in.poly <- sum(loc_log[[i]]) # number of target toponym in polygon
    n.top <- length(loc_log[[i]]) # number of target toponym anywhere
    n.top.out.poly <- n.top - n.top.in.poly

    if (opt$freq.type == "abs") {
      ratio[[i]] <- n.top.in.poly / n.top
    }

    if (opt$freq.type == "rel") {
      ratio[[i]] <- (n.top.in.poly / n.tops.in.poly) / (n.top.out.poly / n.tops.out.poly)
    }

    # select only toponyms which surpass parameter rat
    if (ratio[[i]] > rat) {
      if (opt$freq.type == "abs") {
        dat[[i]] <- cbind(
          toponyms_o[i], round(ratio[[i]], 4) * 100,
          paste0(sum(loc_log[[i]]), "/", length(loc_log[[i]]))
        )
      }
      if (opt$freq.type == "rel") {
        dat[[i]] <- cbind(
          toponyms_o[i], round(ratio[[i]], 4),
          paste0(sum(loc_log[[i]]), "/", length(loc_log[[i]]))
        )
      }
    }
  }

  # transforms list into a df for printout
  if (length(dat) > 0) {
    dat <- as.data.frame(cbind(
      unlist(dat)[c(TRUE, FALSE, FALSE)],
      unlist(dat)[c(FALSE, TRUE, FALSE)],
      unlist(dat)[c(FALSE, FALSE, TRUE)]
    ))
    if (opt$freq.type == "abs") {
      colnames(dat) <- c("toponym", "ratio_perc", "frequency")
      dat <- dat[order(as.numeric(dat$ratio_perc), decreasing = TRUE), ]
    }
    if (opt$freq.type == "rel") {
      colnames(dat) <- c("toponym", "ratio", "frequency")
      dat <- dat[order(as.numeric(dat$ratio), decreasing = TRUE), ]
    }
    dat_name <- paste0("data_top_", opt$limit)
    assign(dat_name, dat, envir = .GlobalEnv)
    message(paste("\nDataframe", dat_name, "saved in global environment.\n"))

    return(dat)
  } else {
    message("No toponyms satisfy the criteria")
  }
}
