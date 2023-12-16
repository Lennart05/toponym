#' @title Get toponym data from GeoNames
#' @description The function downloads and saves toponym data from the [GeoNames download page](https://download.geonames.org/export/dump/), which is later used by \code{readFiles()}.
#' @param countries character string with country code abbreviations to download (check \url{https://www.geonames.org/countries/} for a list of available countries). Type "all" for all currently stored data sets in the package directory.
#' @param save logical. If \code{TRUE} then the data sets will be extracted to the package folder. It will be otherwise saved in the temporary folder.
#' @param overwrite logical. If \code{TRUE} then the data sets (.txt files) in the package folder will be overwritten.
#' @seealso [GeoNames download page](https://download.geonames.org/export/dump/)
#' @examples
#' \dontrun{
#' getData(countries = c("DK", "DE"), save = FALSE)
#' ## downloads and extracts data for DK and DE to the temporary folder
#'
#' getData(countries = c("DK", "DE", "PL"), save = TRUE)
#' ## downloads and extracts data for PL but only extracts data for DK and DE
#' ## from the zip files downloaded before to the package folder if used in the same session
#' }
#' @return The data as .txt in the temporary or package folder.
#' @export
getData <- function(countries, save = TRUE, overwrite = FALSE) {
  packdir <- system.file("extdata", package = "toponym")
  if (countries == "all") {
    countries <- substring(list.files(packdir), 1, 2)
  } else {
    for (i in 1:length(countries)) {
      countries[i] <- country(query = countries[i])[, 1]
    } # converts input into ISO2 codes
    countries <- countries[!is.na(countries)] # removes incorrect country names
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
