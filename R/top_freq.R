#' @title Retrieves the most frequent toponyms
#' @description
#' This function returns the most frequent toponyms in countries or a polygon.
#' @details
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#'
#' @param countries character string with country designation (name or ISO-code).
#' @param len numeric. The length of the substring within toponyms.
#' @param limit numeric. The number of the most frequent toponyms.

#' @param ... Additional parameters:
#' \itemize{
#' \item\code{type} character string. Either by default "$" (ending) or "^" (beginning).
#' \item\code{feat.class} character string. Selects data only of those feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list of all feature classes). By default, it is \code{P}.
#' \item\code{freq.type} character string. If "abs" (the default), ratios of absolute frequencies inside the polygon and in the countries as a whole are computed. If "rel", ratios of relative frequencies inside the polygon and outside the polygon will be computed.
#' \item\code{polygon} data frame. Selects toponyms only inside the polygon.
#' }
#'
#' @return A table with toponym substrings and their frequency.
#' @export
#'
#' @examples
#' \dontrun{
#' topFreq(countries = "Namibia", len = 3, limit = 10)
#' ## returns the top ten most frequent toponym endings
#' ## of three-character length in Namibia
#'
#' topFreq(
#'   countries = "GB", len = 3, limit = 10,
#'   polygon = toponym::danelaw_polygon
#' )
#' ## returns the top ten most frequent toponym endings
#' ## in the polygon which is inside the United Kingdom.
#' }
topFreq <- function(countries, len, limit, ...) {

  countries <- country(query = countries)
  for (i in 1:length(countries)) {
    countries[i] <- countries[[i]][, 1]
  } # converts input into ISO2 codes
  countries <- unlist(countries)

  if(missing(len)) stop("Argument 'len' must be defined.")
  if(missing(limit) && limit != "fnc") stop("Argument 'limit' must be defined.")


  opt <- list(...)
  if(is.null(opt$feat.class)) opt$feat.class <- "P"
  if(is.null(opt$type)) opt$type <- "$"

  getData(countries)
  gn <- readFiles(countries, opt$feat.class)

  if (!is.null(opt$polygon)) {
    con.hull <- poly(opt$polygon)

    poly_log <- as.logical(point.in.polygon(gn$longitude, gn$latitude, con.hull$X, con.hull$Y)) # check which places are in the polygon

    gn <- gn[poly_log, ] # only those in the polygon left
  }


  # query all toponyms from the dataset
  toponyms <- paste(
    if (opt$type == "^") {
      "^"
    },
    # creates a reg expr looking for endings of length "len"
    regmatches(
      gn$name,
      regexpr(paste0(
        if (opt$type == "^") {
          "^"
        },
        paste(replicate(len, "."), collapse = ""), if (opt$type == "$") {
          "$"
        }
      ), gn$name)
    ), if (opt$type == "$") {
      "$"
    },
    sep = ""
  )

  # order them by frequency
  if (limit == "fnc") {
    toponyms_o <- names(table(toponyms)[order(table(toponyms), decreasing = TRUE)]) # only strings left
  } else {
    freq_top <- table(toponyms)[order(table(toponyms), decreasing = TRUE)][1:limit] # only a selection of the most frequent toponyms
    return(freq_top)
  }
}
