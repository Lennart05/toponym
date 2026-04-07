#' @title Selection of Toponyms
#' @description
#' This function returns coordinates of selected toponyms (strings).
#' @param strings character string vector with regular expressions to filter data.
#' @param countries character string vector with country designations (names or ISO-codes).
#' @param ... Additional parameters:
#' \itemize{
#' \item\code{feat.class} character string vector. Selects data only of those feature classes (check \url{http://download.geonames.org/export/dump/readme.txt} for the list of all feature classes). By default, it is \code{P}.
#' \item\code{polygon} data frame. Selects toponyms only inside the polygon.
#' \item\code{column} character string vector. Selects the column(s) for query.
#' \item\code{toponym_path} character string. Path name for downloaded data.
#' }
#' @details
#' This function selects locations which match the regular expression from \code{strings}.
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#' Polygons passed through the \code{polygon} parameter need to intersect or be within a country specified by the \code{countries} parameter.
#' Parameter \code{toponym_path} accepts `"pkgdir"` for the package directory or a full, alternative path.
#' With \code{toponymOptions()}, users can specify the path for toponym and map data downloaded by this package across sessions. See `help(toponymOptions)`.
#' The data used is downloaded by \code{getData()} and is accessible on the [GeoNames download server](https://download.geonames.org/export/dump/).
#' 
#' @examples
#' ## We recommend setting a persistent path for downloaded data by using toponymOptions()
#' ## Users can always set the path manually when a function is used
#' ## For illustration purposes, the path is manually set each time in the following examples:
#' 
#' \donttest{
#' itz_data <- top("itz$", "DE", toponym_path = tempdir())
#' # returns a data frame with all populated places
#' # in Germany ending in "itz"
#' 
#' vlad_data <- top("^Vlad", "RU", toponym_path = tempdir())
#' 
#' # returns a data frame with all populated places
#' # in Russia starting with "Vlad" (case sensitive)
#'
#' itz_ice_data <- top(c("itz$", "ice$"), c("DE", "PL"), toponym_path = tempdir())
#' 
#' # returns a data frame with all populated places
#' # in Germany and Poland ending in either "itz" or "ice"
#' 
#' maw_data <- top("Maw$", "MM", column = "alternatenames", toponym_path = tempdir())
#' 
#' # returns a data frame with all populated places
#' # in Myanmar listed in the "alternatenames" column
#' # and ending in "Maw" (case sensitive)
#' }
#' @return A data frame of selected toponym(s).
#' @export
top <- function(strings, countries, ...) {
  ##### store additional parameters and set defaults
  opt <- list(...)
  if (is.null(opt$feat.class)) opt$feat.class <- "P"
  if (!is.character(opt$feat.class)) stop("Parameter `feat.class` must contain character string.")
  if (is.null(opt$column)) opt$column <- "name"
  if (!is.character(opt$column)) stop("Parameter `column` must be a character string vector.")
  if (!any(c("name", "asciiname", "alternatenames") %in% opt$column)) stop("Parameter `column` only accepts `name`, `asciiname` or `alternatenames`")
  path <- getData(countries, toponym_path = opt$toponym_path) # gets data
  
  
  gn <- readFiles(countries, feat.class = opt$feat.class, toponym_path = path) #gn stands for GeoNames
  
  
  # removes coordinates outside of the polygon
  if (!is.null(opt$polygon)) {
    if(!all(c("longitude", "latitude") %in% colnames(opt$polygon))) stop("Parameter `polygon` must consist of two columns named `longitude` and `latitude`.")

    poly_owin <- poly(opt$polygon)

    poly_log <- inside.owin(x = gn$longitude, y = gn$latitude, w = poly_owin) # check which places are in the polygon

    gn <- gn[poly_log, ] # only those in the polygon left
  }
  
  m <- list() # pos of matches
  script <- list()
  for (i in 1:length(strings)) {
    script[[i]] <- IS(strings[[i]]) # checks if any string contains non.latinates
  }




  cols <- c("name", "asciiname", "alternatenames")
  which_col <- match(opt$column, c("name", "asciiname", "alternatenames"))
  which_col <- which_col[!is.na(which_col)]
  gn_selection <- as.data.frame(gn[,cols[rev(which_col)[rev(which_col) !=3]]]) #select all cols in reversed order but alt names
  w_strings <- NULL
  if(any(1:2 %in% which_col)){
  w_strings <- !!rowSums(sapply(gn_selection, grepl, pattern = paste(strings, collapse = "|"), perl = TRUE)) # logical values if matched in names or asciiname
  }

  if (sum(script == "non.latinate") > 0 || 3 %in% which_col) { ## if strings contain non.latinates or alt col is selected
    NApc <- paste0(round(sum(is.na(gn$alternatenames)) / nrow(gn) * 100), "%") ## % of NA in alternatenames col
    message(paste(NApc, "of all entries in the alternate names column are empty."))
    ### if no names in alternatenames
    alternate_names <- altNames(gn, strings)
    if(!is.null(w_strings)){
    w_strings <- w_strings + alternate_names[[1]]
    w_strings[w_strings == 2] <- 1
    w_strings <- as.logical(w_strings) # logical vector indicating if any of the columns has a match
    }else{
      w_strings <- alternate_names[[1]]
    }
    alternate_names[[2]] <- alternate_names[[2]][,order(ncol(alternate_names[[2]]):1)] #reverse col order
    if(which_col[1] == 3 & length(which_col) > 1) {gn_selection <- cbind(gn_selection, alternate_names[[2]]) #put alt names last if first in selection
    }else if(length(which_col) == 1) {gn_selection <- alternate_names[[2]] # merge selected cols and all alt name cols
    }else {gn_selection <- cbind(alternate_names, gn_selection)}
  }
  m_strings <- rep(NA,nrow(gn)) # vector with NA values of gn length
  for(j in 1:ncol(gn_selection)){
    m[[j]] <- regexpr(paste(strings, collapse = "|"), gn_selection[, j], perl = TRUE) #pos of match
    m[[j]][is.na(m[[j]])] <- -1 # replace NA with -1
    m_strings[m[[j]]!=-1] <- regmatches(gn_selection[, j], m[[j]]) # gets matched strings or NA
  }

  gn["group"] <- m_strings # adds matches to "group" column
  output <- gn[w_strings, ]

  return(output)
}
