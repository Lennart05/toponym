#' @title Reads toponym data from temporary or package folder
#' @description The function accesses the data saved by \code{get.data()} and returns it as data frame, only with populated locations, in the global environment, which is used by \code{top()}. View [this](http://download.geonames.org/export/dump/readme.txt) for further information on the used column names, including the population tag.
#' @param countries character string with country code abbreviations to be read (check \url{https://www.geonames.org/countries/} for a list of available countries). Data needs to be saved by \code{get.data()} before.
#' @importFrom utils read.table
#' @return Data frames of the specified countries.
read.files <- function(countries) {
  filename <- list()
  for(i in 1:length(countries)){ # locates filename downloaded by get.data()
  if(file.exists(paste0(system.file("extdata", package = "toponym"), "/", countries, ".txt"))[i]){ # if it is in the package directory
    filename[[i]] <- paste0(system.file("extdata", package = "toponym"), "/", countries, ".txt")[i]
  } else if(file.exists(paste0(tempdir(), "\\", countries, ".txt"))[i]) { # or if it is only temporary saved
    filename[[i]] <- paste0(tempdir(), "\\", countries, ".txt")[i]
  }
}


  L <- list()
  for (i in 1:length(countries)) {
    if (tolower(countries[i]) %in% ls(envir = .GlobalEnv) == FALSE ) {
      geonames_content <- utils::read.table(file = filename[[i]],
                                     head=FALSE, sep="\t", quote="", na.strings="",
                                     comment.char="", encoding="utf8")
      L[[i]] <- assign(tolower(countries[i]), geonames_content, envir = .GlobalEnv)
    } else {
      L[[i]] <- get(tolower(countries[i]))
    }
  }
  if ( length(L) > 1 ) {
    gn <- L[[1]]
    for (j in 2:length(L)) {
      gn <- rbind(gn, L[[j]])
    }
  } else {
    gn <- L[[1]]
  }
  # add column names, which were received from the geonames readme file
  colnames(gn) <- c("geonameid", "name", "asciiname", "alternatenames",
                    "rlatitude", "rlongitude", "rfeature class", "rfeature_code",
                    "rcountry_code", "rcc2", "radmin1 code", "radmin2 code", "radmin3 code",
                    "radmin4_code", "rpopulation", "relevation", "rdem", "rtimezone",
                    "rmodification date")

  # select only the populated places
  gn <- gn[which(gn$"rfeature class"=="P"),]

  return(gn)
}