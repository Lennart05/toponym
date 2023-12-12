#' @title symbols in data
#' @description Outputs an ordered frequency list of all symbols used in a given column of the GeoNames data for one or more countries specified. Since this is mainly useful for looking into what is in the alternatenames column, that column is the default.
#' @param countries character string with country code abbreviations (check \url{https://www.geonames.org/countries/} for a list of available countries) specifying, the toponyms of which countries are checked.
#' @param column character string naming the column of interest. Default is \code{"alternativenames"}. Other columns of possible interest are \code{"name"} and \code{"asciiname"}
#'
#' @return a table with frequencies of all symbols
#' @export
#'
#' @examples
#' \dontrun{
#' symbols(countries = "ID")
#' # outputs a table with frequencie all symbols in the "alternatenames" column for the Indonesia data set
#' }
symbols <- function(countries, column="alternatenames") {
  # convert input into ISO2 codes and remove incorrect country names
  for(i in 1:length(countries)){countries[i] <- country.data(query = countries[i])[,1]}
  countries <- countries[!is.na(countries)]

  # download data if not already on the computer
  get.data(countries)

  # read relevant country files, gn stands for GeoNames
  gn <- read.files(countries, feat.class=c("P","S","H","T","A","L","R","V","U"))

  # identify and extract target column
  w_col <- which(names(gn)==column)
  t_col <- gn[,w_col]

  # split each element of column into characters, remove punctuation,
  # and output table of frequencies
  chars_split <- lapply(t_col, function(z) strsplit(z, "")[[1]])
  chars_unlisted <- unlist(chars_split)
  punct_chars <- which(chars_unlisted %in% c(" ", ",", ";", "."))
  if (length(punct_chars) > 0) {
    chars_unlisted <- chars_unlisted[-punct_chars]
  }
  char_table <- sort(table(chars_unlisted), decreasing=TRUE)
  return(char_table)
}
