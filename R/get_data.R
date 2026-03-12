#' @title Downloads GeoNames data
#' @description This function downloads toponym data for the package.
#' @details
#' The data is downloaded from the [GeoNames download page](https://download.geonames.org/export/dump/) and thereby made accessible to \code{readFiles()}. The function allows users to update GeoNames data and to set the date of access to that database to the current date.
#' Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
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
  toponym_options <- readRDS(paste0(system.file("extdata", package = "toponym"), "/toponym_options.rds"))
  save <- toponym_options
  
  packdir <- system.file("extdata", package = "toponym")
  if (any(countries == "all")) {
    countries <- substring(list.files(packdir), 1, 2)
  } else {
	countries <- unlist(lapply(country(query = countries), function(x) x[, 1]))
  }

  filename <- paste0(countries, ".txt")
  zipfile <- paste0(countries, ".zip")
  tmpdir <- tempdir()
  tmpfile <- paste0(tmpdir, "\\", zipfile)
  tmptxt <- paste0(tmpdir, "\\", countries, ".txt")

  url <- paste0("https://download.geonames.org/export/dump/", countries, ".zip?raw=TRUE") # download address on GeoNames


  for (i in 1:length(countries)) {
    if (save == TRUE) {
      if (overwrite == FALSE) {
        if (!file.exists(paste0(packdir, "/", filename[i]))) { # checks if txt exists
          if (!file.exists(tmpfile[i])) {
            utils::download.file(url[i], tmpfile[i], mode = "wb")
          } # downloads zip if missing
          utils::unzip(zipfile = tmpfile[i], files = filename[i], exdir = packdir, overwrite = FALSE) # unzips txt to package directory
          message(paste(filename[i], "saved in package directory"))
        }
      } else { # if overwrite is set to TRUE
        if (!file.exists(tmpfile[i])) {
          utils::download.file(url[i], tmpfile[i], mode = "wb")
        } # downloads zip if missing
        utils::unzip(zipfile = tmpfile[i], files = filename[i], exdir = packdir, overwrite = TRUE) # unzips txt to package directory
        message(paste(filename[i], "overwritten in package directory"))
      }
    } else if (!file.exists(tmptxt[i])) { # checks if txt exists in tempdir
      if (!file.exists(tmpfile[i])) {
        utils::download.file(url[i], tmpfile[i], mode = "wb")
      } # downloads zip if missing
      utils::unzip(zipfile = tmpfile[i], files = filename[i], exdir = tmpdir, overwrite = FALSE) # unzip txt to tempdir
      message(paste(filename[i], "saved in temporary directory"))
    }
  }
}
