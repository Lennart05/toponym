#' @title Saves all maps and data frames based on the output of \code{top.candidates()}
#' @description
#' The function applies the list of toponyms returned by \code{top.candidates()} to \code{top()}. A series of maps showing the toponym, ratio in percentage and numbers will be generated and locally saved.
#'
#'
#' @param countries Character string with country code abbreviations (check \url{https://www.geonames.org/countries/} for a list of available countries) specifying, the toponyms of which countries are checked.
#' @param count numeric. The number of the most frequent endings which will be tested, e.g. by default the top ten most frequent endings in Germany.
#' @param len numeric. The character length of the endings, e.g. by default three-character-long endings.
#' @param df logical. If \code{TRUE} then the filtered data frames will be saved in the global environment.
#' @param csv logical. If \code{TRUE} then the filtered data frames will be saved as .csv in the current working directory.
#' @param rat numeric. The ratio (a number between 0.0 and 1) of how many occurrences of one ending need to be in the polygon
#' @param type character string. Either "$" (suffixes) or "^" (prefixes)
#' @param lons numeric. Vector of longitudinal coordinates defining the polygon.
#' @param lats numeric. Vector of latitudinal coordinates defining the polygon.
#' @details
#' The goal is to find and generate maps of toponyms which are potentially worthwhile to be further examined by hand or other means.
#' As a meaningful ratio is not determinable if we take the different areas (i.e. the possible polygons to be compared) and varying frequencies of specific toponyms into account.
#' For example, an ending may only occur five times in total, thus the distribution on a percentage basis is a less conclusive indicator for potential candidates.
#'
#'
#' @return A number of data frames and plots saved in a sub folder (called "data frames" and "plots") in the working directory. It also stores the ratio surpassing toponyms in a data frame in the global environment.
#' @export
#'
#' @examples
#' \dontrun{
#' candidates.maps()
#'
#' ## generates and saves the data frames & maps of the top ten three-character-long endings
#' ## in Germany if more than 50% of the places lie in the default polygon.
#' }
candidates.maps <- function(countries="DE", count = 10, len = 3, df = FALSE, csv = TRUE, rat = .5, type = "$", lons = toponym::slav_polygon$lons, lats = toponym::slav_polygon$lats)
  {
  dat <- top.candidates(countries, count, len, rat, type, lons, lats) # gets df with candidates for top() function
  for(i in 1:length(dat$ending)) {
    top(dat$ending[i],
        countries,
        color=rainbow(length(countries)),
        df,
        csv,
        plot = FALSE,
        ratio_string = dat$ratio[i], # ratio in % from dat
        fq = dat$frequency[i]) # fq as number from dat
  }
}
