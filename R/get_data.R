#' @title Downloads GeoNames data
#' @description This function downloads toponym data for the package.
#' @details
#' The data is downloaded from the [GeoNames download page](https://download.geonames.org/export/dump/) and thereby made accessible to \code{readFiles()}. The function allows users to update GeoNames data and to set the date of access to that database to the current date.
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}. If "all", data from all countries stored in the package folder is selected.
#' With \code{toponymOptions()}, users can specify whether toponym data downloaded by \code{getData()} will be stored in the package folder or in a temporary folder. See `help(toponymOptions)`.
#' @param countries character string vector with country designations (names or ISO-codes).
#' @param overwrite logical. If \code{TRUE}, the data sets (.txt files) in the package folder will be overwritten.
#' @seealso [GeoNames download page](https://download.geonames.org/export/dump/)
#' @examples
#' \dontrun{
#' getData(countries = "NL")
#' ## downloads and extracts data for NL to the package folder (default setting)
#' 
#' getData(countries = c("DK", "DE"))
#' ## downloads and extracts data for DK and DE to the package folder (default setting)
#'
#' getData(countries = c("DK", "DE"), overwrite = TRUE)
#' ## downloads, extracts, and overwrites data for DK and DE in the package folder (default setting)
#' }
#' @export
getData <- function(countries, overwrite = FALSE) {
  toponym_options <- toponymOptions()
  
	countries <- unlist(lapply(country(query = countries), function(x) x[, 1])) # convert if necessary designations to ISO2

  file_txt <- paste0(countries, ".txt")
  file_txt_dir <- paste0(toponym_options, "/", file_txt)
  file_zip <- paste0(countries, ".zip")
  file_zip_dir <- paste0(toponym_options, "/", file_zip)
  
  url <- paste0("https://download.geonames.org/export/dump/", countries, ".zip?raw=TRUE") # download address on GeoNames


  for (i in 1:length(countries)) {
     #package directory
        if (any(!file.exists(file_txt_dir[i]), overwrite)) {#download if file is missing or overwrite = TRUE
          if (!file.exists(file_zip_dir[i])) {#zipfile is missing in directory
            utils::download.file(url[i], file_zip_dir[i], mode = "wb")
          } # downloads zip if missing
          utils::unzip(zipfile = file_zip_dir[i], files = file_txt[i], exdir = toponym_options, overwrite = overwrite) # unzips txt to directory & overwrite if set TRUE
          if(overwrite == FALSE) {message(paste(filename[i], "saved in:", toponym_options))
          }else message(paste(filename[i], "overwritten in:", toponym_options))
        }
  }
  
  
}
