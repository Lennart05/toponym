#' @title Downloads GeoNames data
#' @description This function downloads toponym data for the package.
#' @details
#' The data is downloaded from the [GeoNames download page](https://download.geonames.org/export/dump/) and thereby made accessible to \code{readFiles()}. The function allows users to update GeoNames data and to set the date of access to that database to the current date.
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}. If "all", data from all countries stored in the package folder is selected.
#' Parameter \code{toponym_path} accepts "pkgdir" for the package directory or a full, alternative path.
#' With \code{toponymOptions()}, users can specify the path for toponym data downloaded by \code{getData()} across sessions. See `help(toponymOptions)`.
#' @param countries character string vector with country designations (names or ISO-codes).
#' @param overwrite logical. If \code{TRUE}, the data sets (.txt files) in the package folder will be overwritten.
#' @param toponym_path character string. Path name for downloaded data. If not specified, this function will call `toponymOptions()` and try use the persistent path.
#' @seealso [GeoNames download page](https://download.geonames.org/export/dump/)
#' @examples
#' ## We recommend setting a persistent path for downloaded data by using toponymOptions()
#' ## Users can always set the path manually when a function is used
#' ## For illustration purposes,
#' ## 1. the path is manually set each time
#' ## 2. and wrapped in donttest because data will be downloaded in the following examples:
#' \donttest{
#' getData(countries = "NL", toponym_path = tempdir())
#' ## downloads and extracts data for NL to the temporary directory
#' }
#' 
#' \donttest{
#' getData(countries = c("DK", "DE"), toponym_path = tempdir())
#' ## downloads and extracts data for DK and DE to the temporary directory
#' }
#'
#' \donttest{
#' getData(countries = c("DK", "DE"), overwrite = TRUE, toponym_path = tempdir())
#' ## downloads, extracts, and overwrites data for DK and DE in the temporary directory
#' }
#' @return No return value.
#' @export
getData <- function(countries, overwrite = FALSE, toponym_path = NULL) {
  toponym_path <- checkPath(toponym_path = toponym_path)
	countries <- unlist(lapply(country(query = countries, toponym_path = toponym_path), function(x) x[, 1])) # convert if necessary designations to ISO2

  file_txt <- paste0(countries, ".txt")
  file_txt_dir <- paste0(toponym_path, "/", file_txt)
  file_zip <- paste0(countries, ".zip")
  file_zip_dir <- paste0(toponym_path, "/", file_zip)
  
  url <- paste0("https://download.geonames.org/export/dump/", countries, ".zip?raw=TRUE") # download address on GeoNames
  
  old_timeout <- getOption("timeout") # store timeout setting for download
  on.exit(options(timeout = old_timeout)) # restore timeout setting on exit
  options(timeout = max(6000, getOption("timeout"))) # set timeout to 6000 if it is lower
  
  for (i in 1:length(countries)) {
     #package directory
        if (any(!file.exists(file_txt_dir[i]), overwrite)) {#download if file is missing or overwrite = TRUE
          if (!file.exists(file_zip_dir[i])) {#zipfile is missing in directory
            utils::download.file(url[i], file_zip_dir[i], mode = "wb")
            message(paste(file_zip[i], "saved in:", toponym_path))
          } # downloads zip if missing
          utils::unzip(zipfile = file_zip_dir[i], files = file_txt[i], exdir = toponym_path, overwrite = overwrite) # unzips txt to directory & overwrite if set TRUE
          if(overwrite == FALSE) {message(paste(file_txt[i], "saved in:", toponym_path))
          }else message(paste(file_txt[i], "overwritten in:", toponym_path))
        }
  }
}
