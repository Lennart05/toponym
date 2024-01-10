#' @title Coordinates Selection
#' @description
#' This function returns the coordinates of selected toponyms.
#' @details This function returns coordinates (longitude and latitude) and country codes of all locations, which match the regular expression, given in \code{strings}. The return is used by \code{simple_map()}.
#' @param gn data frame which will be accessed.
#' @param strings character string with regular expression to filter data.
#' @param df logical. If \code{TRUE}, matches will be saved in the global environment.
#' @param csv logical. If \code{TRUE}, matches will be saved as .csv in the current working directory.
#' @param ... Additional parameter:
#' \itemize{
#' \item\code{polygon} data frame. Selects toponyms only inside the polygon.
#' }
#' @keywords internal
#' @return A list with the coordinates (longitude and latitude), country codes and matched strings.
getCoordinates <- function(strings, gn, df, csv, ...) {
  opt <- list(...)
  # removes coordinates outside of the polygon

  if (!is.null(opt$polygon)) {
    con.hull <- poly(opt$polygon)

    poly_log <- as.logical(point.in.polygon(gn[,"longitude"], gn[, "latitude"], con.hull$X, con.hull$Y)) # check which places are in the polygon

    gn <- gn[poly_log, ] # only those in the polygon left
  }




  results <- list()
  for (i in 1:length(strings)) {
    results[[i]] <- IS(strings[[i]])
  }
  if (sum(results == "non.latinate") > 0) { ## if strings contain non.latinates
    NApc <- paste0(round(sum(is.na(gn$alternatenames)) / nrow(gn) * 100), "%") ## % of NA in alternatenames col
    message(paste(NApc, "of all entries in the alternate names column are empty."))
    ### if no names in alternatenames
    alt_l <- altNames(gn, strings)
    w_strings <- alt_l[[1]]
    m_strings <- alt_l[[2]]
  } else {
    w_strings <- unique(grep(paste(strings, collapse = "|"), gn$name, perl = TRUE)) # gets all indexes of matches
    m_strings <- regmatches(gn$name, regexpr(paste(strings, collapse = "|"), gn$name, perl = TRUE)) # gets matches
  }
  output <- gn[w_strings, ]
  lat_strings <- output$latitude # gets respective lat coordinates
  lon_strings <- output$longitude # gets respective lon coordinates
  country <- output$"country code" # gets respective cc
  output["matches"] <- m_strings # adds matches






  # saves data as df and/or csv
  if (df == TRUE || csv == TRUE) {
    strings_raw <- gsub("[[:punct:]]", "", strings)
    dat_name <- paste0("data_", paste(strings_raw, collapse = "_"), collapse = "_")
    if (df == TRUE) {
      dat <- assign(dat_name, output, envir = .GlobalEnv)
      message(paste("\nDataframe", dat_name, "saved in global environment.\n"))
    }
    if (csv == TRUE) {
      csv_dir <- file.path(getwd(), "data frames")
      csv_name <- paste(file.path(csv_dir, dat_name), ".csv", sep = "")
      if (!dir.exists(csv_dir)) dir.create(csv_dir)
      utils::write.csv(output, csv_name)
      message(paste("\nDataframe", dat_name, "saved as csv in dataframes folder of the working directory.\n"))
    }
  }

  return(list(latitude = lat_strings, longitude = lon_strings, "country code" = country, "matches" = m_strings))
}
