#' @title Retrieves country names and codes
#' @description
#' The function returns country codes, names and regional names used in the data set.
#'
#' @param query character string. Enter query to access information on countries.
#' @param regions logical. If \code{TRUE}, outputs the region names of the respective country.
#' @details If you enter "ISO2" or "ISO3", you receive a list of all ISO-codes of the respective length. If you enter "names", you receive a list of all country names.
#' If you refer to an individual country, you receive the remaining forms of reference.
#' @return Returns a data frame or vector with the country data.
#' @export
#'
#' @examples
#' \dontrun{
#' country(query = "ISO3")
#' ## returns list of all ISO3 codes
#'
#' country(query = "Thailand")
#' ## returns a data frame with the ISO2, ISO3 code and the full name
#'
#' country(query = "Thailand", regions = TRUE)
#' ## returns all region names
#' }
country <- function(query = NULL, regions = FALSE) {

  if(!(is.character(query))) stop("The query must contain a character string.")
  countryInfo <- toponym::countryInfo

  output <- list()
  warn <- list()
  for(i in 1:length(query)){
  if (regions == FALSE) {
    if (any(query == "country table")) {
      return(countryInfo)
    } else if (query[i] == "ISO2") { # outputs all ISO2 codes
      return(countryInfo[, 1])
    } else if (query[i] == "ISO3") { # outputs all ISO3 codes
      return(countryInfo[, 2])
    } else if (query[i] == "names") { # outputs all country names
      return(countryInfo[, 3])
    } else if (nchar(query[i]) == 2) { # ISO2 code as input
      query[i] <- toupper(query[i])
      output[[i]] <- countryInfo[match(query[i], countryInfo[, 1]), ] # then outputs respective row
    } else if (nchar(query[i]) == 3) { # ISO3 code as input
      query[i] <- toupper(query[i])
      output[[i]] <- countryInfo[match(query[i], countryInfo[, 2]), ] # then outputs respective row
    } else if (nchar(query[i]) >= 4) { # country name as input --> there is no country name shorter than 4 characters
      output[[i]] <- countryInfo[match(query[i], countryInfo[, 3]), ] # then outputs respective row
    }
    if (anyNA(output[[i]])) {
      warn[[i]] <- query[i]
    } # check for NAs
  } else { # if regions is TRUE

    map_path <- paste0(system.file(package = "geodata"), "/extdata")

    error <- paste0("The query '", query[i], "' is an invalid country reference")

    output[[i]] <- tryCatch(expr = {
      gadm(country = query[i], path = map_path)$NAME_1
    },
    error = function(e){
      warning(error)
      return(NA)
    }
    )
    if(!all(is.na(output[[i]]))){
      Encoding(output[[i]]) <- "UTF-8" # corrects encoding
    }
  }

  } # loop ends

  n_warn <- 0
  if(length(warn) > 0){
    n_warn <- sum(sapply(warn, is.character))
    warn <- warn[!sapply(warn, is.null)]
    }
  if(n_warn == 1){
    warning(paste0("The query '", warn, "' is an invalid country reference."))
  }else if(n_warn > 1){
    warning(paste0("The queries '", paste(warn, collapse = ", "), "' are invalid country references."))
  }
  if(n_warn == length(query))
    stop("There were no correct country references. No data returned.")
  output <- output[!sapply(output, function(x) all(is.na(x)))]
  return(output)
}
