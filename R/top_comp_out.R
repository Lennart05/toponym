#' @title Saves all maps and data frames based on the output of \code{topComp()}
#' @description
#' The function applies the list of toponyms returned by \code{topComp()} to \code{top()}. A series of maps showing the toponym, ratio in percentage and numbers will be generated and locally saved.
#'
#'
#' @param countries character string with country code abbreviations (check \url{https://www.geonames.org/countries/} for a list of available countries) specifying, the toponyms of which countries are checked.
#' @param count numeric. The number of the most frequent endings which will be tested.
#' @param len numeric. The character length of the endings.
#' @param df logical. If \code{TRUE} then the filtered data frames will be saved in the global environment.
#' @param csv logical. If \code{TRUE} then the filtered data frames will be saved as .csv in the current working directory.
#' @param rat numeric. The ratio (a number between 0.0 and 1) of how many occurrences of one ending need to be in the polygon
#' @param type character string. Either by default "$" (ending) or "^" (beginning)
#' @param lons numeric. Vector of longitudinal coordinates defining the polygon.
#' @param lats numeric. Vector of latitudinal coordinates defining the polygon.
#' @param feat.class character string with feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list and names of all feature classes in the data). By default, it is \code{p}.
#' @param freq.type character string. If set to "abs" (the default), ratios of absolute frequencies inside the area and in the countries as a whole are computed. If set to "rel", ratios of relative frequencies inside the area and outside the area will be computed.
#' @details
#' The goal is to find and generate maps of toponyms which are potentially worthwhile to be further examined by hand or other means.
#' A general and meaningful ratio is not determinable if we take the different areas (i.e. the possible polygons to be compared) and varying frequencies of specific toponyms into account.
#' For example, an ending may only occur five times in total, thus the distribution on a percentage basis is a less conclusive indicator for potential candidates.
#'
#'
#' @return A number of data frames and plots saved in a sub folder (called "data frames" and "plots") in the working directory. If wanted, it stores the ratio surpassing toponyms in a data frame in the global environment.
#' @export
#'
#' @examples
#' \dontrun{
#' topCompOut(
#'   countries = "BE", count = 100, len = 3, rat = .5,
#'   lons = toponym::flanders_polygon$lons, lats = toponym::flanders_polygon$lats
#' )
#'
#' ## generates and saves the data frames & maps of the top hundred three-character-long endings
#' ## in Belgium if more than 50% of the places lie in the polygon for Flanders.
#' }
topCompOut <- function(countries, len, rat, polygon, ...) {
  opt <- list(...)
  if(is.null(opt$type)) opt$type <- "$"
  if(is.null(opt$feat.class)) opt$feat.class <- "P"
  if(is.null(opt$plot)) opt$plot <- FALSE

  dat <- topComp(countries = countries, len = len, rat = rat, polygon = polygon, limit = opt$limit, type = opt$type, feat.class = opt$feat.class, opt$freq.type) # gets df with candidates for top() function
  #topComp <- function(countries, len, rat, polygon, ...)
  for (i in 1:length(dat$toponym)) {
    top(strings = dat$toponym[i],
      countries = countries,
      color = opt$color,
      df = opt$df,
      csv = opt$csv,
      plot = opt$plot,
      ratio_string = dat$ratio[i], # ratio in % from dat
      fq = dat$frequency[i],
      feat.class = opt$feat.class

    ) # fq as number from dat
  }
}
