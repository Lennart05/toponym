#' @title Country Designations
#' @description
#' This function returns country codes, names and regional names used by the \code{toponym} package.
#'
#' @param query character string. Enter query to access information on countries.
#' @param regions logical. If \code{TRUE}, outputs the region names of the respective countries.
#' @details If you enter to an individual country designation, you receive the three different designations (IS02, ISO3, name).
#' If you enter "ISO2" or "ISO3", you receive a vector of all ISO-codes of the respective length.
#' If you enter "names", you receive a vector of all country names.
#' If you enter "country table", you receive a data frame with all three designations for every country.
#' @return Returns designations selected from a data frame containing designations for every country.
#' @export
#'
#' @examples
#' \dontrun{
#' country(query = "ISO3")
#' ## returns a vector of all ISO3 codes
#'
#' country(query = "Thailand")
#' ## returns a list with a data frame with ISO2 code, ISO3 code and the full name
#'
#' country(query = "Thailand", regions = TRUE)
#' ## returns a list with a vector with all region names
#' }
country <- function(query = NULL, regions = FALSE) {

  if(!(is.character(query))) stop("The query must contain a character string.")
  countryInfo <- toponym::countryInfo
  spec_col <- c("country table", "ISO2", "ISO3", "names")
  output <- list()
  warn <- list()
  for(i in 1:length(query)){
  if (regions == FALSE) {
    if (any(query == spec_col[1])) {
      return(countryInfo)
    } else if (query[i] == spec_col[2]) { # outputs all ISO2 codes
      return(countryInfo[, 1])
    } else if (query[i] == spec_col[3]) { # outputs all ISO3 codes
      return(countryInfo[, 2])
    } else if (query[i] == spec_col[4]) { # outputs all country names
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
    if(any(query == spec_col)) stop("If parameter 'regions' is set to TRUE, the query must contain a country reference.")
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
