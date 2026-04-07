#' @title Orthographical symbols
#' @description
#' This function retrieves all symbols used in country data.
#' @param countries character string vector with country designations (names or ISO-codes).
#' @param ... Additional parameter:
#' \itemize{
#' \item\code{column} character string. Selects the column for query.
#' \item\code{toponym_path} character string. Path name for downloaded data.
#' }
#' @details
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#'
#' The default column is \code{"alternatenames"}. Other columns of possible interest are \code{"name"} and \code{"asciiname"}.
#' It outputs an ordered frequency table of all symbols used in a given column of the GeoNames data for one or more countries specified.
#'
#' Parameter \code{toponym_path} accepts `"pkgdir"` for the package directory or a full, alternative path.
#' With \code{toponymOptions()}, users can specify the path for toponym and map data downloaded by this package across sessions. See `help(toponymOptions)`.
#' The data used is downloaded by \code{getData()} and is accessible on the [GeoNames download server](https://download.geonames.org/export/dump/).
#' 
#'
#' @return A table with frequencies of all symbols.
#' @export
#'
#' @examples
#' ## We recommend setting a persistent path for downloaded data by using toponymOptions()
#' ## Users can always set the path manually when a function is used
#' ## For illustration purposes,
#' ## 1. the path is manually set each time
#' ## 2. and wrapped in donttest because data will be downloaded in the following example:
#' \donttest{
#' ortho(countries = "MC", toponym_path = tempdir())
#' # returns a table with frequencies of all symbols
#' # in the "alternatenames" column for the Monaco data set
#' }
ortho <- function(countries, ...) {

  opt <- list(...)
  if(is.null(opt$column)) opt$column <- "alternatenames"
  if(length(opt$column)>1) stop("This function only permits one column request at a time.")
  if(!is.character(opt$column)) stop("The selected column must be a character string.")
  
  path <- checkPath(toponym_path = opt$toponym_path)
  # convert input into ISO2 codes and remove incorrect country names
  countries <- unlist(lapply(country(query = countries, toponym_path = path), function(x) x[, 1]))

  # download data if not already on the computer
  getData(countries, toponym_path = opt$toponym_path)

  # read relevant country files, gn stands for GeoNames
  gn <- readFiles(countries, feat.class = c("P", "S", "H", "T", "A", "L", "R", "V", "U"), toponym_path = path)

  # identify and extract target column
  w_col <- which(names(gn) == opt$column)
  if(length(w_col) == 0) stop(paste0("The selected column `", opt$column, "` could not be found."))

  t_col <- gn[, w_col]

  if(!is.character(t_col)) stop(paste0("The selected column `", opt$column, "` contains no characters."))

  # split each element of column into characters, remove punctuation,
  # and output table of frequencies
  chars_split <- lapply(t_col, function(z) strsplit(z, "")[[1]])
  symbols <- unlist(chars_split)
  punct_chars <- which(symbols %in% c(" ", ",", ";", "."))
  if (length(punct_chars) > 0) {
    symbols <- symbols[-punct_chars]
  }
  char_table <- sort(table(symbols), decreasing = TRUE)
  return(char_table)
}
