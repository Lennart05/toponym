#' @title Filters locations by a given regular expression
#' @description The function retrieves the coordinates (longitude and latitude) and country codes of all locations, which match the regular expression, given in \code{string}. The return is used by \code{simple_map()}.
#' @param gn The data frame(s), which will be accessed.
#' @param strings Character strings in form of regular expression that filter the data frames.
#' @param df logical. If \code{TRUE} then the filtered data frame will be saved in the global environment.
#' @param csv logical. If \code{TRUE} then the filtered data frame will be saved as .csv in the current working directory.
#' @keywords internal
#' @return A list with the coordinates (longitude and latitude) and country codes.
getCoordinates <- function(gn, strings, df, csv) {

  results <- list()
  for(i in 1:length(strings)){
    results[[i]] <- IS(strings[[i]])
  }
  if(sum(results == "non.latinate") > 0){ ## if strings contain non.latinates
  NApc <- paste0(round(sum(is.na(gn$alternatenames))/nrow(gn)*100), "%") ## % of NA in alternatenames col
  message(paste(NApc, "of all entries in the alternate names column are empty."))
    ### if no names in alternatenames
  alt_l <- altNames(gn, strings)
  w_strings <- alt_l[[1]]
  m_strings <- alt_l[[2]]
  }else{
  w_strings <- unique(grep(paste(strings,collapse="|"), gn$name, perl = TRUE)) # gets all indexes of matches
  m_strings <- regmatches(gn$name,regexpr(paste(strings,collapse="|"), gn$name, perl = TRUE)) # gets matches
  }
  lat_strings <- gn$latitude[w_strings] # gets respective lat coordinates
  lon_strings <- gn$longitude[w_strings] # gets respective lon coordinates
  country <- gn$'country code'[w_strings] # gets respective cc

  # saves data as df and/or csv
  if(df == TRUE || csv == TRUE) {
    strings_raw <- gsub("[[:punct:]]", "", strings)
    dat_name <- paste0("data_", paste(strings_raw, collapse = "_"), collapse="_")
    if(df == TRUE) {
      dat <- assign(dat_name, gn[w_strings,], envir = .GlobalEnv)
      message(paste("\nDataframe",dat_name ,"saved in global environment.\n"))
    }
    if(csv == TRUE) {
      csv_dir <- file.path(getwd(),"data frames")
      csv_name <- paste(file.path(csv_dir, dat_name), ".csv", sep ="")
      if (!dir.exists(csv_dir)) dir.create(csv_dir)
      utils::write.csv(gn[w_strings,], csv_name)
      message(paste("\nDataframe",dat_name ,"saved as csv in dataframes folder of the working directory.\n"))
    }
  }

  return(list(lat_strings, lon_strings, country, m_strings))
}
