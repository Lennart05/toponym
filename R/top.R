#' @title Toponym Map
#' @description This function plots selected toponyms on a map.
#' @param strings character string with regular expression to filter data.
#' @param countries character string with country reference (name or iso-code)
#' @param ... additional parameters; see details
#' @details
#' This function is used to plot all locations matching the regular expression from \code{strings}.
#' Parameter \code{countries} accepts all references found in \code{country(query = "country table")}.
#'
#' Allowed additional parameters are the following:
#' \itemize{
#' \item\code{color} character string indicating, which color is assigned to each string.
#' \item\code{regions} numeric. specifies the level of administrative borders. By default \code{0} displaying only country borders.
#' \item\code{df} logical. If \code{TRUE} then matches will be saved in the global environment.
#' \item\code{csv} logical. If \code{TRUE} then matches will be saved as .csv in the current working directory.
#' \item\code{plot} logical. If \code{FALSE} then the plot will not be printed but saved as .png in the current working directory.
#' \item\code{feat.class} character string. specifies data with which feature classes is tested (check \url{http://download.geonames.org/export/dump/readme.txt} for the list of all feature classes). By default, it is \code{P}.
#' }
#' This function calls the \code{simpleMap()} function to generate a map to plot all locations, passed down by \code{getCoordinates()}. The plot also displays additional information if used by \code{topCompOut()}.
#' The data used is downloaded by \code{getData()} and is accessible on the [GeoNames download server](https://download.geonames.org/export/dump/).
#'
#' @examples
#' \dontrun{
#' top("itz$", "DE")
#' # prints a plot with all populated places
#' # in Germany ending with "itz"
#' # and saves the locations in a data frame in the global environment.
#'
#'
#' top("^By", "DK", color = "green", df = FALSE, csv = TRUE, plot = FALSE)
#' # saves a plot with all populated places colored in green
#' # in Denmark starting with "By" (case sensitive)
#' # and saves it as .png together with the matches as .csv in the working directory.
#'
#'
#' top(c("itz$", "ice$"), c("DE", "PL"))
#' # prints a plot with all populated places in Germany colored in red and Poland colored in cyan
#' # ending with either "itz" or "ice"
#' # and saves matches in the global environment.
#' }
#' @return a plot of selected toponym(s) with the number of occurrences
#' @export
top <- function(strings, countries, ...) {

  ### additional parameter color, regions, df, csv, plot, ratio_string, fq, feat.class, lons lats/polygon
  countries <- country(query = countries)
  for (i in 1:length(countries)) {
    countries[i] <- countries[[i]][, 1]
  } # converts input into ISO2 codes
  countries <- unlist(countries)

  opt <- list(...)

  if (is.null(opt$df)) opt$df <- TRUE
  if (is.null(opt$csv)) opt$csv <- FALSE
  if (is.null(opt$plot)) opt$plot <- TRUE
  if (is.null(opt$feat.class)) opt$feat.class <- "P"
  if (is.null(opt$regions)) opt$regions <- 0


  try(getData(countries), silent = TRUE) # gets data
  gn <- readFiles(countries, opt$feat.class) # stands for GeoNames
  coordinates <- getCoordinates(strings, gn, opt$df, opt$csv) # coordinates of matches
  simpleMap(strings, coordinates, opt$color, opt$regions, opt$plot, opt$polygon, opt$ratio_string, opt$fq) # inserts coordinates and generates map
}
