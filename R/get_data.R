#' @title Get toponym data from [GeoNames](https://www.geonames.org/)
#' @description The function downloads and saves toponym data  from the [GeoNames download server](https://download.geonames.org/export/dump/), which is later used by \code{read.files()}.
#' @param countries character string with country code abbreviations to download (check \url{https://www.geonames.org/countries/} for a list of available countries).
#' @param save logical. If \code{TRUE} then the data sets will be extracted to the package folder. It will be otherwise saved in the temporary folder.
#' @examples
#' \dontrun{
#' get.data(countries = c("DK", "DE"), save = FALSE)
#' ## downloads and extracts data for DK and DE to the temporary folder
#'
#' get.data(countries = c("DK", "DE", "PL"), save = TRUE)
#' ## downloads and extracts data for PL but only extracts data for DK and DE
#' ## from the zip files downloaded before to the package folder if used in the same session
#' }
#' @return The data as .txt in the temporary or package folder.
#' @importFrom utils download.file
#' @importFrom utils unzip
#' @export
get.data <- function(countries, save = TRUE) {


  url <- paste0("https://download.geonames.org/export/dump/", countries, ".zip?raw=TRUE")
  filename <- paste0(countries, ".txt")
  zipfile <- paste0(countries, ".zip")
  tmpdir <- tempdir()
  tmpfile <- paste0(tmpdir, "\\", zipfile)
  tmptxt <- paste0(tmpdir, "\\", countries, ".txt")

  packdir <- system.file("extdata", package = "toponym")



  for (i in 1:length(countries)) {
    if(file.exists(paste0(packdir, "/", filename[i]))){
  } else if(!file.exists(paste0(packdir, "/", filename[i])) && save == TRUE){  # checks if file exists in package directory

        if(!file.exists(tmpfile[i])){utils::download.file(url[i],tmpfile[i], mode = "wb")}  # downloads zip if missing
        utils::unzip(zipfile = tmpfile[i], files = filename[i], exdir = packdir, overwrite = FALSE) # unzips txt to package directory
        print(paste(filename[i], "saved in package directory"))

  } else if(!file.exists(tmptxt[i])){   # checks if file exists in tempdir
        if(!file.exists(tmpfile[i])){utils::download.file(url[i],tmpfile[i], mode = "wb")} # downloads zip if missing
        utils::unzip(zipfile = tmpfile[i], files = filename[i], exdir = tmpdir, overwrite = FALSE) # unzip txt to tempdir
  }

    }



}
