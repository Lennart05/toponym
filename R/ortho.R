#' @title Orthographical symbols
#' @description
#' This function retrieves all symbols used in country data.
#' @param countries character string vector with country designations (names or ISO-codes).
#' @param ... Additional parameter:
#' \itemize{
#' \item\code{column} character string. Selects the column for query.
#' }
#' @details
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
#'
#' The default column is \code{"alternatenames"}. Other columns of possible interest are \code{"name"} and \code{"asciiname"}.
#' It outputs an ordered frequency table of all symbols used in a given column of the GeoNames data for one or more countries specified.
#'
#'
#' @return A table with frequencies of all symbols.
#' @export
#'
#' @examples
#' \dontrun{
#' ortho(countries = "ID")
#' # outputs a table with frequencies all symbols
#' # in the "alternatenames" column for the Indonesia data set
#' }
ortho <- function(countries, ...) {

  opt <- list(...)
  if(is.null(opt$column)) opt$column <- "alternatenames"
  if(length(opt$column)>1) stop("This function only permits one column request at a time.")
  if(!is.character(opt$column)) stop("The selected column must be a character string.")

  # convert input into ISO2 codes and remove incorrect country names
    countries <- country(query = countries)
  for (i in 1:length(countries)) {
    countries[i] <- countries[[i]][, 1]
  } # converts input into ISO2 codes
  countries <- unlist(countries)

  # download data if not already on the computer
  getData(countries)

  # read relevant country files, gn stands for GeoNames
  gn <- readFiles(countries, feat.class = c("P", "S", "H", "T", "A", "L", "R", "V", "U"))

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
