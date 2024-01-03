#' @title Reads GeoNames data
#' @description This function reads toponym data for the package.
#' @details This function accesses the data saved by \code{getData()}, reads it as data frame and stores it in the package environment. [Here](http://download.geonames.org/export/dump/readme.txt) is further information on the used column names.
#' @param countries character string with country reference (name or iso-code)
#' @param feat.class character string. specifies data with which feature classes is tested (check \url{http://download.geonames.org/export/dump/readme.txt} for the list of all feature classes). By default, it is \code{P}.
#' @keywords internal
#' @return Data frame of the specified country.
readFiles <- function(countries, feat.class = "P") {
  filename <- list()
  for (i in 1:length(countries)) { # locates filename downloaded by getData()
    if (file.exists(paste0(system.file("extdata", package = "toponym"), "/", countries, ".txt"))[i]) { # if it is in the package directory
      filename[[i]] <- paste0(system.file("extdata", package = "toponym"), "/", countries, ".txt")[i]
    } else if (file.exists(paste0(tempdir(), "\\", countries, ".txt"))[i]) { # or if it is only temporary saved
      filename[[i]] <- paste0(tempdir(), "\\", countries, ".txt")[i]
    }
  }

  L <- list()
  for (i in 1:length(countries)) {
    if (tolower(countries[i]) %in% ls(top_env) == FALSE) {
      geonames_content <- utils::read.table(
        file = filename[[i]], # reads country data of parameter "countries"
        head = FALSE, sep = "\t", quote = "", na.strings = "",
        comment.char = "", encoding = "utf8"
      )
      Encoding(geonames_content[, 2]) <- "UTF-8" # set encoding to UTF-8 in case the local encoding of the OS reads it wrong
      Encoding(geonames_content[, 4]) <- "UTF-8" # set encoding to UTF-8 in case the local encoding of the OS reads it wrong

      # add column names, which were received from the geonames readme file
      colnames(geonames_content) <- c(
        "geonameid", "name", "asciiname", "alternatenames",
        "latitude", "longitude", "feature class", "feature code",
        "country code", "cc2", "admin1 code", "admin2 code", "admin3 code",
        "admin4 code", "population", "elevation", "dem", "timezone",
        "modification date"
      )


      L[[i]] <- assign(tolower(countries[i]), geonames_content, envir = top_env) # saves in pkg env for later use
    } else {
      L[[i]] <- top_env[[tolower(countries[i])]]
    }
  }
  if (length(L) > 1) {
    gn <- L[[1]]
    for (j in 2:length(L)) {
      gn <- rbind(gn, L[[j]])
    }
  } else {
    gn <- L[[1]]
  }

  # select only specified features
  gn <- gn[which(gn$"feature class" %in% feat.class), ]
}
