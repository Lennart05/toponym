#' @title Retrieves the most frequent toponyms
#' @description
#' This function returns the most frequent toponym substrings in countries or a polygon.
#' @details
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#'
#' @param countries a character string vector with country designations (names or ISO-codes).
#' @param len numeric. The length of the substring within toponyms.
#' @param limit numeric. The number of the most frequent toponyms.

#' @param ... Additional parameters:
#' \itemize{
#' \item\code{type} character string. Either by default "$" (ending), "^" (beginning) or "ngram" (all substrings). Type "ngram" may take a while to compute.
#' \item\code{feat.class} a character string vector. Selects data only of those feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list of all feature classes). By default, it is \code{P}.
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

  if(missing(len)) stop("Parameter 'len' must be defined.")
  if(missing(limit) && limit != "fnc") stop("Parameter 'limit' must be defined.")

  ##### store additional parameters and set defaults
  opt <- list(...)
  if(is.null(opt$feat.class)) opt$feat.class <- "P"
  if(is.null(opt$type)) opt$type <- "$"

  getData(countries)
  gn <- readFiles(countries, opt$feat.class)

  if (!is.null(opt$polygon)) {
  if(!all(c("lons", "lats") %in% colnames(opt$polygon))) stop("Parameter `polygon` must consist of two columns named `lons` and `lats`.")
    poly_owin <- poly(opt$polygon)

    poly_log <- inside.owin(x = gn$longitude, y = gn$latitude, w = poly_owin) # check which places are in the polygon

    gn <- gn[poly_log, ] # only those in the polygon left
  }

  if(len > max(nchar(gn$name))) stop(paste0("Parameter `len` exceeds the length of the longest name (", max(nchar(gn$name)), ") in the data."))

  if(opt$type == "ngram"){
  toponyms <- list()
  ngram_names <- gn[nchar(gn$name) >= len, "name"] # removes places which are shorter than ngram length
  for(i in 1:length(ngram_names)){
    toponyms[[i]] <- get.phrasetable(ngram(ngram_names[i], sep = "", n = len))[,c("ngrams", "freq")] #get ngrams & freq
    toponyms[[i]] <- toponyms[[i]][!grepl("  ", toponyms[[i]]$ngrams),] # ngrams containing space bar removed
    toponyms[[i]]$ngrams <- gsub(" ", "", toponyms[[i]]$ngrams , fixed = TRUE) # remove all white space
    }
  toponyms <- aggregate(freq ~ ngrams, data = do.call("rbind", toponyms), FUN = sum) #merge ngrams by frequency
  toponyms <- toponyms[order(toponyms$freq, decreasing = TRUE),]
  freq_top <- as.table(toponyms$freq)
  names(freq_top) <- toponyms$ngrams
  if (limit == "fnc") limit <- length(freq_top)
  freq_top <- freq_top[1:limit]
  }else{
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
  }

  freq_top <- freq_top[!is.na(freq_top)] # rm nas


  return(freq_top)
}









