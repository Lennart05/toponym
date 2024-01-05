#' @title Symbols Data
#' @description 
#' This functions retrieves all symbols used in country data sets.
#' @details
#' Parameter \code{countries} accepts all references found in \code{country(query = "country table")}.
#' Default of \code{column} is \code{"alternativenames"}. Other columns of possible interest are \code{"name"} and \code{"asciiname"}
#' Outputs an ordered frequency table of all symbols used in a given column of the GeoNames data for one or more countries specified.
#' @param countries character string with country reference (name or iso-code).
#' @param column character string naming the column of interest.
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
ortho <- function(countries, column = "alternatenames") {
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
  w_col <- which(names(gn) == column)
  t_col <- gn[, w_col]

  # split each element of column into characters, remove punctuation,
  # and output table of frequencies
  chars_split <- lapply(t_col, function(z) strsplit(z, "")[[1]])
  chars_unlisted <- unlist(chars_split)
  punct_chars <- which(chars_unlisted %in% c(" ", ",", ";", "."))
  if (length(punct_chars) > 0) {
    chars_unlisted <- chars_unlisted[-punct_chars]
  }
  char_table <- sort(table(chars_unlisted), decreasing = TRUE)
  return(char_table)
}
