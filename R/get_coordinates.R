#' @title Filters locations by given regular expression
#' @description The function retrieves the coordinates (longitude and latitude) and country codes of all locations, which match the regular expression, given in \code{string}. The return is used by \code{simple_map()}.
#' @param gn The data frame(s), which will be accessed.
#' @param strings Character strings in form of regular expression that filter the data frames.
#' @param df logical. If \code{TRUE} then the filtered data frame will be saved in the global environment.
#' @param csv logical. If \code{TRUE} then the filtered data frame will be saved as .csv in the current working directory.
#' @importFrom utils write.csv
#' @return A list with the coordinates (longitude and latitude) and country codes.
get.coordinates <- function(gn, strings, df, csv) {

  w_strings <- unique(grep(paste(strings,collapse="|"), gn$name))
  lat_strings <- gn$rlatitude[w_strings]
  lon_strings <- gn$rlongitude[w_strings]
  country <- gn$rcountry_code[w_strings]

  # saves data as df and/or csv
  if(df == TRUE || csv == TRUE) {
    dat_name <- paste0("data_", paste(regmatches(strings, regexpr("[a-zA-Z]+", strings)), collapse = "_"), collapse="_")
    if(df == TRUE) {
      dat <- assign(dat_name, gn[w_strings,], envir = .GlobalEnv)
      cat(paste("\nDataframe",dat_name ,"saved in global environment.\n"))
    }
    if(csv == TRUE) {
      csv_dir = file.path(getwd(),"data frames")
      csv_name = paste(file.path(csv_dir, dat_name), ".csv", sep ="")
      if (!dir.exists(csv_dir)) dir.create(csv_dir)
      utils::write.csv(gn[w_strings,], csv_name)
      cat(paste("\nDataframe",dat_name ,"saved as csv in dataframes folder of the working directory.\n"))
    }
  }

  return(list(lat_strings, lon_strings, country))
}
