#' @title Coordinate selection
#' @description
#' This function returns coordinates of selected toponyms (strings).
#' @details This function returns coordinates (longitude and latitude), country codes and the matched strings. The return is used by \code{simple_map()}.
#' @param gn data frame which will be accessed.
#' @param strings a character string vector with regular expressions to filter data.
#' @param df logical. If \code{TRUE}, matches will be saved in the global environment.
#' @param csv logical. If \code{TRUE}, matches will be saved as .csv in the current working directory.
#' @param tsv logical. If \code{TRUE}, matches will be saved as .tsv in the current working directory.
#' @param ... Additional parameter:
#' \itemize{
#' \item\code{polygon} data frame. Selects toponyms only inside the polygon.
#' \item\code{name} character string. Defines name of output data frame.
#' \item\code{column} a character string vector. Selects the column(s) for query
#' }
#' @keywords internal
#' @return A list with the coordinates (longitude and latitude), country codes and matched strings.
getCoordinates <- function(strings, gn, df, csv, tsv, ...) {

  ##### store additional parameters and set defaults
  opt <- list(...)

  if(!is.null(opt$name) && !is.character(opt$name[1])) stop("Data frame name must be a character string. Only the first element will be considered.")

  # removes coordinates outside of the polygon
  if (!is.null(opt$polygon)) {
    if(!all(c("lons", "lats") %in% colnames(opt$polygon))) stop("Parameter `polygon` must consist of two columns named `lons` and `lats`.")

    poly_owin <- poly(opt$polygon)

    poly_log <- inside.owin(x = gn$longitude, y = gn$latitude, w = poly_owin) # check which places are in the polygon

    gn <- gn[poly_log, ] # only those in the polygon left
  }




  results <- list()
  for (i in 1:length(strings)) {
    results[[i]] <- IS(strings[[i]])
  }

  if("alternatenames" %in% opt$column) alt <- TRUE # set true if alt names column is selected
  opt$column <- opt$column[opt$column %in% c("name", "asciiname")] # only select name and asciiname
  gn_selection <- gn[,c(opt$column)]

  w_strings <- !!rowSums(sapply(gn_selection, grepl, pattern = "berg$", perl = TRUE)) # logical values if matched in names or asciiname
  m_strings <- regmatches(gn$asciiname, regexpr(paste(strings, collapse = "|"), gn$asciiname, perl = TRUE)) # gets matched strings
#### merge m_strings if multiple rows!




  if (sum(results == "non.latinate") > 0 || alt) { ## if strings contain non.latinates
    NApc <- paste0(round(sum(is.na(gn$alternatenames)) / nrow(gn) * 100), "%") ## % of NA in alternatenames col
    message(paste(NApc, "of all entries in the alternate names column are empty."))
    ### if no names in alternatenames
    alternative_names <- altNames(gn, strings)
    w_strings <- w_strings + alternative_names[[1]]



    for (i in 1:nrow(alt_names)) {
      m_strings[[i]] <- regmatches(alt_names[i, ], regexpr(paste(strings, collapse = "|"), alt_names[i, ], perl = TRUE)) # gets matches
    }
    m_strings <- do.call(rbind, unname(lapply(m_strings, `length<-`, max(lengths(m_strings)))))
    m_strings <- m_strings[, 1]

    w_strings[w_strings == 2] <- 1
    w_strings <- as.logical(w_strings)
  }


  output <- gn[w_strings, ]
  lat_strings <- output$latitude # gets respective lat coordinates
  lon_strings <- output$longitude # gets respective lon coordinates
  country <- output$"country code" # gets respective cc
  output["group"] <- m_strings # adds matches to "group" column






  # saves data as df and/or csv/tsv
  if (any(df, csv, tsv)) {
    strings_raw <- gsub("[[:punct:]]", "", strings)
    dat_name <- paste0("data_", paste(strings_raw, collapse = "_"), collapse = "_")
    if(!is.null(opt$name)) dat_name <- opt$name[1]
    if (df == TRUE) {
      dat <- assign(dat_name, output, envir = .GlobalEnv)
      message(paste("\nDataframe", dat_name, "saved in global environment.\n"))
    }
    if(any(csv, tsv)){
      file_dir <- file.path(getwd(), "dataframes")
      if (!dir.exists(file_dir)) dir.create(file_dir)
    }
    if (csv == TRUE) {
      csv_name <- paste(file.path(file_dir, dat_name), ".csv", sep = "")
      utils::write.table(output, file = csv_name, quote=FALSE, sep=';', row.names = FALSE)
      message(paste("\nDataframe", dat_name, "saved as csv in `dataframes` folder of the working directory.\n"))
    }
    if (tsv == TRUE) {
      tsv_name <- paste(file.path(file_dir, dat_name), ".tsv", sep = "")
      utils::write.table(output, file = tsv_name, quote=FALSE, sep='\t', row.names = FALSE)
      message(paste("\nDataframe", dat_name, "saved as tsv in `dataframes` folder of the working directory.\n"))
    }


  }

  return(list(latitude = lat_strings, longitude = lon_strings, "country code" = country, "group" = m_strings))
}
