#' @title Compares toponyms in a polygon and the remainder of countries
#' @description
#' This function retrieves the most frequent toponym substrings in a given polygon relative to country frequencies.
#' @details
#' This function sorts the toponym substrings in the given countries by frequency. It then tests which ones lie in the given polygon and prints out a data frame with those that match the ratio criterion.
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#' Polygons passed through the \code{polygon} parameter need to intersect or be within a country specified by the \code{countries} parameter.
#'
#' @param countries character string vector with country designations (names or ISO-codes).
#' @param len numeric. The length of the substring within toponyms.
#' @param rat numeric. The cut-off ratio (a number between 0.0 and 1 for \code{freq.type = "abs"}) of how many occurrences of a toponym string need to be in the polygon relative to the rest of the country (or countries).
#' @param polygon data frame. Defines the polygon for comparison with the remainder of a country (or countries).
#'
#' @param ... Additional parameters:
#' \itemize{
#' \item\code{type} character string. Either by default "$" (ending), "^" (beginning) or "ngram" (all substrings). Type "ngram" may take a while to compute.
#' \item\code{feat.class} character string vector. Selects data only of those feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list of all feature classes). By default, it is \code{P}.
#' \item\code{freq.type} character string. If "abs" (the default), ratios of absolute frequencies inside the polygon and in the countries as a whole are computed. If "rel", ratios of relative frequencies inside the polygon and outside the polygon will be computed.
#' \item\code{limit} numeric. The number of the most frequent toponym substrings which will be tested.
#' }
#' @return A data frame printed out and saved in the global environment. It shows toponym substrings surpassing the ratio, the ratio and the frequency.
#' @export
#'
#' @examples
#' \dontrun{
#' topComp("GB",
#'   limit = 100,
#'    len = 4,
#'     rat = .7,
#'   polygon = toponym::danelaw_polygon
#' )
#' ## prints and saves a data frame of the top 100 four-character-long endings in the United Kingdom
#' ## if more than 70% of them belong to the polygon
#' ## corresponding to the Danelaw area.
#'
#'
#' topComp("GB",
#'   limit = 100,
#'   len = 3,
#'   rat = 1,
#'   polygon = toponym::danelaw_polygon,
#'   freq.type = "rel"
#' )
#' ## prints and saves a data frame of the top 100 three-character-long endings in the United Kingdom
#' ## if they have greater relative frequencies within Danelaw than outside of Danelaw.
#'
#'
#' topComp(c("BE", "NL"),
#'   limit = 50,
#'   len = 3,
#'   rat = .8,
#'   polygon = toponym::flanders_polygon
#' )
#'
#' ## prints and saves a data frame of the top 50 three-character-long endings
#' ## in Belgium and Netherlands viewed as a unit if more than 80% of them belong to the polygon
#' ## corresponding to Flanders.
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
  if(!all(c("lons", "lats") %in% colnames(polygon))) stop("Parameter `polygon` must consist of two columns named `lons` and `lats`.")

  poly_owin <- poly(polygon)

   ##### store additional parameters and set defaults
  opt <- list(...)
  if(is.null(opt$feat.class)) opt$feat.class <- "P"
  if(is.null(opt$type)) opt$type <- "$"
  if(is.null(opt$freq.type)) opt$freq.type <- "abs"

  getData(countries) # gets data
  gn <- readFiles(countries, opt$feat.class)
  if (is.null(opt$limit)) {
    message("Parameter `limit` was not specified. All toponyms will be tested. This may take a while.")
    toponyms_o <- topFreq(countries = countries, len = len, limit = "fnc", feat.class = opt$feat.class, type = opt$type)

  } else{
    toponyms_o <- topFreq(countries = countries, len = len, limit = opt$limit, feat.class = opt$feat.class, type = opt$type)
  }
  toponyms_o <- toponyms_o[!is.na(toponyms_o)]
  toponyms_o <- names(toponyms_o)
  opt$limit <- length(toponyms_o)

  toponyms_ID_o <- list()
  lat_strings <- list()
  lon_strings <- list()
  loc_log <- list()
  ratio <- list() # ratio between absolute or relative frequencies, depending on freq.type
  dat <- list()



  # for relative frequencies the number of toponyms within the polygon is needed
  if (opt$freq.type == "rel") {
    n.tops <- nrow(gn) # number of all toponyms anywhere
    in.poly <- rep(NA, n.tops)
    for (i in 1:n.tops) {
      in.poly[i] <- inside.owin(x = gn$longitude[i], y = gn$latitude[i], w = poly_owin) # check which places are in the polygon
    }
    n.tops.in.poly <- sum(in.poly) # number of all toponyms in polygon
    n.tops.out.poly <- n.tops - n.tops.in.poly # number of all toponyms outside polygon
  }

  for (i in 1:opt$limit) {
    # stores indices of all ordered toponyms
    toponyms_ID_o[[i]] <- unique(grep(toponyms_o[i], gn$name))

    lat_strings[[i]] <- gn$latitude[toponyms_ID_o[[i]]]
    lon_strings[[i]] <- gn$longitude[toponyms_ID_o[[i]]]

    # logical vectors storing if each place is within the given polygon
    loc_log[[i]] <- inside.owin(x = lon_strings[[i]], y = lat_strings[[i]], w = poly_owin)
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
    surpass <- ratio[[i]] >= rat
    surpass[is.na(surpass)] <- FALSE #turn NA to FALSE
    if (surpass) {
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
    warning("No toponym satisfies the criteria")
  }
}
