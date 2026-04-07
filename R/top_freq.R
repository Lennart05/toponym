#' @title Retrieves the most frequent toponyms
#' @description
#' This function returns the most frequent toponym substrings in countries or a polygon.
#' @details
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#' Polygons passed through the \code{polygon} parameter need to intersect or be within a country specified by the \code{countries} parameter.
#' Parameter \code{toponym_path} accepts `"pkgdir"` for the package directory or a full, alternative path.
#' With \code{toponymOptions()}, users can specify the path for toponym and map data downloaded by this package across sessions. See `help(toponymOptions)`.
#' The data used is downloaded by \code{getData()} and is accessible on the [GeoNames download server](https://download.geonames.org/export/dump/).
#'
#' @param countries character string vector with country designations (names or ISO-codes).
#' @param len numeric. The length of the substring within toponyms.
#' @param limit numeric. The number of the most frequent toponym substrings.
#' @param ... Additional parameters:
#' \itemize{
#' \item\code{type} character string. Either by default "$" (ending) or "^" (beginning).
#' \item\code{feat.class} character string vector. Selects data only of those feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list of all feature classes). By default, it is \code{P}.
#' \item\code{polygon} data frame. Selects toponyms only inside the polygon.
#' \item\code{toponym_path} character string. Path name for downloaded data.
#' }
#'
#' @return A table with toponym substrings and their frequency.
#' @export
#'
#' @examples
#' ## We recommend setting a persistent path for downloaded data by using toponymOptions()
#' ## Users can always set the path manually when a function is used
#' ## For illustration purposes,
#' ## 1. the path is manually set each time
#' ## 2. and wrapped in donttest because data will be downloaded in the following examples:
#' \donttest{
#' topFreq(
#'   countries = "Ecuador",
#'   len = 3,
#'   limit = 10,
#'   toponym_path = tempdir())
#' ## returns the top 10 most frequent toponym endings
#' ## of three-character length in Ecuador
#' }
#' 
#' \donttest{
#' topFreq(
#'   countries = "GB",
#'   len = 3,
#'   limit = 10,
#'   polygon = toponym::danelaw_polygon,
#'   toponym_path = tempdir())
#' ## returns the top 10 most frequent toponym endings
#' ## in the polygon which is inside the United Kingdom.
#' }
topFreq <- function(countries, len, limit, ...) {
  opt <- list(...)
  toponym_path <- checkPath(toponym_path = opt$toponym_path)
  countries <- unlist(lapply(country(query = countries, toponym_path = toponym_path), function(x) x[, 1]))

  if(missing(len)) stop("Parameter 'len' must be defined.")
  if(missing(limit) && limit != "fnc") stop("Parameter 'limit' must be defined.")

  ##### store additional parameters and set defaults
  if(is.null(opt$feat.class)) opt$feat.class <- "P"
  if(is.null(opt$type)) opt$type <- "$"

  getData(countries, toponym_path = toponym_path)
  gn <- readFiles(countries, opt$feat.class, toponym_path = toponym_path)

  if (!is.null(opt$polygon)) {
  if(!all(c("longitude", "latitude") %in% colnames(opt$polygon))) stop("Parameter `polygon` must consist of two columns named `longitude` and `latitude`.")
    poly_owin <- poly(opt$polygon)

    poly_log <- inside.owin(x = gn$longitude, y = gn$latitude, w = poly_owin) # check which places are in the polygon

    gn <- gn[poly_log, ] # only those in the polygon left
  }

  if(len > max(nchar(gn$name))) stop(paste0("Parameter `len` exceeds the length of the longest name (", max(nchar(gn$name)), ") in the data."))
  
  # query all toponyms from the dataset
  toponyms <- paste(
    if (opt$type == "^") {
      "^"
    },
    # creates a reg expr looking for strings of length "len"
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
  if (limit == "fnc") limit <- length(toponyms)
  freq_top <- table(toponyms)[order(table(toponyms), decreasing = TRUE)][1:limit] # only a selection of the most frequent toponyms
  

  freq_top <- freq_top[!is.na(freq_top)] # rm nas


  return(freq_top)
}









