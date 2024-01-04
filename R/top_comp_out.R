#' @title Saves multiple maps and toponym data
#' @description
#' This function applies the list of toponyms returned by \code{topComp()} to \code{top()}.
#' @details
#' A series of maps showing the toponym, ratio in percentage and numbers will be generated and locally saved.
#' Parameter \code{countries} accepts all references found in \code{country(query = "country table")}.
#' Polygons passed through the \code{polygon} parameter need to intersect a country of \code{countries}.
#'
#' @param countries character string with country reference (name or iso-code)
#' @param len numeric. The character length of the toponyms.
#' @param rat numeric. The ratio (a number between 0.0 and 1) of how many occurrences of one toponym need to be in the polygon.
#' @param polygon data frame. Polygon for comparison with the country.

#' @param ... Additional parameters:
#' \itemize{
#' \item\code{df} logical. If \code{TRUE} then the filtered data frames will be saved in the global environment.
#' \item\code{csv} logical. If \code{TRUE} then the filtered data frames will be saved as .csv in the current working directory.
#' \item\code{type} character string. Either by default "$" (ending) or "^" (beginning)
#' \item\code{feat.class} character string with feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list and names of all feature classes in the data). By default, it is \code{P}.
#' \item\code{freq.type} character string. If "abs" (the default), ratios of absolute frequencies inside the area and in the countries as a whole are computed. If "rel", ratios of relative frequencies inside the area and outside the area will be computed.
#' \item\code{limit} numeric. The number of the most frequent toponyms which will be tested.
#' }
#'
#' @return Data frames and plots saved in a sub folder (called 'data frames' and 'plots') in the working directory or package environment.
#' @export
#'
#' @examples
#' \dontrun{
#' topCompOut(
#'   countries = "BE", count = 100, len = 3, rat = .5,
#'   toponym::flanders_polygon
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
