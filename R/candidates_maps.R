#' @title Generates and saves all maps returned by \code{top.candidates()}
#' @description
#' test test test
#'
#'
#' @param countries Character string with country code abbreviations (check \url{https://www.geonames.org/countries/} for a list of available countries) specifying, the toponyms of which countries are checked.
#' @param count numeric. The number of the most frequent endings which will be tested, e.g. by default the top ten most frequent endings in Germany.
#' @param len numeric. The character length of the endings, e.g. by default three-character-long endings.
#' @param df logical. If \code{TRUE} then the filtered data frames will be saved in the global environment.
#' @param csv logical. If \code{TRUE} then the filtered data frames will be saved as .csv in the current working directory.
#' @param rat numeric. The ratio (a number between 0.0 and 1) of how many occurrences of one ending need to be in the polygon
#' @param lons numeric. Vector of longitudinal coordinates defining the polygon.
#' @param lats numeric. Vector of latitudinal coordinates defining the polygon.
#'
#' @return A number of data frames and plots saved in a sub folder (called "data frames" and "plots") in the working directory. It also stores the ratio surpassing endings in a data frame in the global environment.
#' @export
#'
#' @examples
candidates.maps <- function(countries="DE", count = 10, len = 3, df = FALSE, csv = TRUE, rat = .5,
                            lons = c(10.144314,10.0399439 ,10.5178491 ,11.3143579 ,11.8746607 ,11.8087427 ,11.6274683 ,11.5450708 ,11.7757837 ,11.6659204 ,10.2140419 ,9.917411 ,9.8075477 ,10.6919471 ,12.8617469 ,14.9821083 ,15.5204383 ,14.6964637 ,13.8834755 ,12.9496376 ,11.6202919 ,11.1039344 ,10.144314),
                            lats = c(54.3227499 ,53.5107333 ,53.324126 ,53.0476312 ,52.8755735 ,52.5928491 ,52.2377021 ,52.0826909 ,51.9389938 ,51.764248 ,51.0454903 ,50.8031092 ,50.2724411 ,49.8067462 ,49.7499912 ,50.2408327 ,51.6459284 ,53.9825363 ,54.6235699 ,54.7378977 ,54.4323074 ,54.5790222, 54.3227499)
                            ){
  dat <- top.candidates(countries, count, len, rat, lons, lats)
  for(i in 1:length(dat$ending)) {
    top(dat$ending[i], countries, color=rainbow(length(countries)), df, csv, plot = TRUE, ratio_string = dat$ratio[i], fq = dat$frequency[i])
  }
}
