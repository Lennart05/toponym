#' @title Saves multiple maps and toponym data
#' @description
#' This function retrieves the most frequent toponym substrings in a given polygon relative to country frequencies. It generates maps of them and saves them along with the corresponding data frames.
#' @details
#' This function applies the list of toponyms returned by \code{topComp()} to \code{top()}.
#' A series of maps showing the toponym, ratio in percentage and numbers will be generated and locally saved.
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#' Polygons passed through the \code{polygon} parameter need to intersect or be within a country specified by the \code{countries} parameter.
#'
#' @param countries character string vector with country designations (names or ISO-codes).
#' @param len numeric. The length of the substring within toponyms.
#' @param rat numeric. The cut-off ratio (a number between 0.0 and 1 for \code{freq.type = "abs"}) of how many occurrences of a toponym string need to be in the polygon relative to the rest of the country (or countries).
#' @param polygon data frame. Defines the polygon for comparison with the remainder of a country (or countries).

#' @param ... Additional parameters:
#' \itemize{
#' \item\code{df} logical. If \code{TRUE}, the filtered data frames will be saved in the global environment.
#' \item\code{csv} logical. If \code{TRUE}, the filtered data frames will be saved as .csv in the current working directory.
#' \item\code{tsv} logical. If \code{TRUE}, the filtered data frames will be saved as .tsv in the current working directory.
#' \item\code{type} character string. Either by default "$" (ending), "^" (beginning) or "ngram" (all substrings). Type "ngram" may take a while to compute.
#' \item\code{feat.class} character string vector. Selects data only of those feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list of all feature classes). By default, it is \code{P}.
#' \item\code{freq.type} character string. If "abs" (the default), ratios of absolute frequencies inside the polygon and in the countries as a whole are computed. If "rel", ratios of relative frequencies inside the polygon and outside the polygon will be computed.
#' \item\code{limit} numeric. The number of the most frequent toponym substrings which will be tested.
#' }
#'
#' @return Data frames and plots saved in a sub folder (called 'dataframes' and 'plots') in the working directory or global environment.
#' @export
#'
#' @examples
#' \dontrun{
#' topCompOut(
#'   countries = "BE",
#'    limit = 10,
#'    len = 3,
#'    rat = .95,
#'    df = FALSE,
#'    polygon = toponym::flanders_polygon
#'    )
#'
#' ## generates and saves the data frames & maps of the top 10 three-character-long endings
#' ## in Belgium if more than 95% of of them belong to the polygon
#' ## corresponding to Flanders. The data frames are not saved
#' ## in the global environment (df = FALSE).}
topCompOut <- function(countries, len, rat, polygon, ...) {
   ##### store additional parameters and set defaults
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
      tsv = opt$tsv,
      plot = opt$plot,
      ratio_string = dat$ratio[i], # ratio in % from dat
      fq = dat$frequency[i],
      feat.class = opt$feat.class

    ) # fq as number from dat
  }
}
