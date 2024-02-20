#' @title Coordinate selection
#' @description
#' This function returns coordinates of selected toponyms (strings).
#' @details This function returns coordinates (longitude and latitude), country codes and the matched strings. The return is used by \code{simple_map()}.
#' @param gn data frame which will be accessed.
#' @param strings character string vector with regular expressions to filter data.
#' @param df logical. If \code{TRUE}, matches will be saved in the global environment.
#' @param csv logical. If \code{TRUE}, matches will be saved as .csv in the current working directory.
#' @param tsv logical. If \code{TRUE}, matches will be saved as .tsv in the current working directory.
#' @param ... Additional parameter:
#' \itemize{
#' \item\code{polygon} data frame. Selects toponyms only inside the polygon.
#' \item\code{name} character string. Defines name of output data frame.
#' \item\code{column} character string vector. Selects the column(s) for query.
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
  m_strings <- rep(NA,nrow(gn))  # vector with NA values of gn length
  for(j in 1:ncol(gn_selection)){
    m[[j]] <- regexpr(paste(strings, collapse = "|"), gn_selection[, j], perl = TRUE) #pos of match
    m[[j]][is.na(m[[j]])] <- -1 # replace NA with -1
    m_strings[m[[j]]!=-1] <- regmatches(gn_selection[, j], m[[j]]) # gets matched strings or NA
  }

  gn["group"] <- m_strings # adds matches to "group" column
  output <- gn[w_strings, ]
  lat_strings <- output$latitude # gets respective lat coordinates
  lon_strings <- output$longitude # gets respective lon coordinates






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

  return(list(latitude = lat_strings, longitude = lon_strings, "country code" = output$"country code", "group" = output$group))
}
