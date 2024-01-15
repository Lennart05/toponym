#' @title Toponym Map
#' @description
#' This function returns and plots selected toponyms onto a map.
#' @param strings character string with regular expression to filter data.
#' @param countries character string with country designation (name or ISO-code).
#' @param ... Additional parameters:
#' \itemize{
#' \item\code{color} character string indicating, which color is assigned to each string.
#' \item\code{regions} numeric. Specifies the level of administrative borders. By default \code{0} for displaying only country borders.
#' \item\code{df} logical. If \code{TRUE}, matches will be saved in the global environment.
#' \item\code{csv} logical. If \code{TRUE}, matches will be saved as .csv in the current working directory.
#' \item\code{tsv} logical. If \code{TRUE}, matches will be saved as .tsv in the current working directory.
#' \item\code{plot} logical. If \code{FALSE}, the plot will not be printed but saved as .png in the current working directory.
#' \item\code{feat.class} character string. Selects data only of those feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list of all feature classes). By default, it is \code{P}.
#' \item\code{polygon} data frame. Selects toponyms only inside the polygon.
#' }
#'
#' @details
#' This function is used to plot all locations matching the regular expression from \code{strings}.
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#' Polygons passed through the \code{polygon} parameter need to intersect a country of \code{countries}.
#'
#' This function calls the internal \code{simpleMap()} function to generate a map of all locations gotten by \code{getCoordinates()}. The plot also displays additional information if used by \code{topCompOut()}.
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
#' top("^Vlad", "RU", color = "green", df = FALSE, csv = TRUE, plot = FALSE)
#' # saves a plot with all populated places
#' # in Russia starting with "Vlad" (case sensitive) colored in green
#' # and saves it as .png together with the matches as .csv in the working directory.
#'
#'
#' top(c("itz$", "ice$"), c("DE", "PL"))
#' # prints a plot with all populated places in Germany and Poland ending with either "itz" or "ice"
#' # colored in red ("itz") and cyan ("ice")
#' # and saves matches in the global environment.
#' }
#' @return A plot of selected toponym(s) with the number of occurrences.
#' @export
top <- function(strings, countries, ...) {
   countries <- country(query = countries)
  for (i in 1:length(countries)) {
    countries[i] <- countries[[i]][, 1]
  } # converts input into ISO2 codes
  countries <- unlist(countries)
  opt <- list(...)
  if (is.null(opt$df)) opt$df <- TRUE
  if (is.null(opt$csv)) opt$csv <- FALSE
  if (is.null(opt$tsv)) opt$tsv <- FALSE
  if (is.null(opt$plot)) opt$plot <- TRUE
  if (is.null(opt$feat.class)) opt$feat.class <- "P"
  if (is.null(opt$regions)) opt$regions <- 0
  if (is.logical(opt$regions)) stop("Parameter `regions` must be numeric, not logical.")

  try(getData(countries), silent = TRUE) # gets data
  gn <- readFiles(countries, feat.class = opt$feat.class) # stands for GeoNames
  coordinates <- getCoordinates(strings, gn, df = opt$df, csv = opt$csv, tsv = opt$tsv, polygon = opt$polygon) # coordinates of matches
  simpleMap(strings, coordinates, color = opt$color, regions = opt$regions, plot = opt$plot, ratio_string = opt$ratio_string, fq = opt$fq) # inserts coordinates and generates map
}
