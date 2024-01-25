#' @title Country designations
#' @description
#' This function returns country codes, names and regional names used by the \code{toponym} package.
#'
#' @param query a character string vector. Enter queries to access information on countries.
#' @param ... Additional parameter:
#' \itemize{
#' \item\code{regions} numeric. If \code{1}, outputs the region designations of the respective countries. By default, it is \code{0}.
#' }
#' @details If you enter to an individual country designation, you receive the three different designations (IS02, ISO3, name).
#' If you enter "ISO2" or "ISO3", you receive a vector of all ISO-codes of the respective length.
#' If you enter "names", you receive a vector of all country names.
#' If you enter "country table", you receive a data frame with all three designations for every country.
#' Region designations are retrieved from the \code{geodata} package map data. The list of region designations may be incomplete. For mapping purposes, \code{geodata} is used throughout this package.
#' @return Returns country designations selected from a data frame. If regions is set to {1}, returns region designations in a matrix selected from \code{geodata} map data.
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
#' country(query = "Thailand", regions = 1)
#' ## returns a list with a vector with all region names
#' }
country <- function(query = NULL, ...) {

  opt <- list(...)
  if(is.null(opt$regions)) opt$regions <- 0
  if(!is.numeric(opt$regions)) stop("`regions` must be numeric.")
  if(opt$regions > 1) stop("`regions` values higher than 1 cannot be satisfied.")


  if(!is.character(query)) stop("The query must contain a character string.")
  query <- query[!nchar(query) == 1] #removes input which is only one character long
  if(length(query) == 0) stop("The query contains no valid input.")

  countryInfo <- toponym::countryInfo
  spec_col <- c("country table", "ISO2", "ISO3", "names")
  output <- list()
  warn <- list()
  for(i in 1:length(query)){
  if (opt$regions == 0) {
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
  } else if(opt$regions == 1) { # if regions is 1
    if(any(query %in% spec_col)) stop("If parameter 'regions' is set to 1, the query must contain a country designation.")
    map_path <- paste0(system.file(package = "geodata"), "/extdata")

    error <- paste0("The query '", query[i], "' is an invalid country designation")

    output[[i]] <- tryCatch(expr = {
     gadm(country = query[i], path = map_path)
    },
    error = function(e){
      warning(error)
      return(NA)
    }
    )
    name <- output[[i]]$NAME_1 #
    Encoding(name) <- "UTF-8" # corrects encoding
    ID <- output[[i]]$GID_1 # region ID
    output[[i]] <- cbind(name, ID)
  }

  } # loop ends

  n_warn <- 0
  if(length(warn) > 0){
    n_warn <- sum(sapply(warn, is.character))
    warn <- warn[!sapply(warn, is.null)]
    }
  if(n_warn == 1){
    warning(paste0("The query '", warn, "' is an invalid country designation."))
  }else if(n_warn > 1){
    warning(paste0("The queries '", paste(warn, collapse = ", "), "' are invalid country designations."))
  }
  if(n_warn == length(query))
    stop("There were no correct country designation. No data returned.")
  output <- output[!sapply(output, function(x) all(is.na(x)))]
  return(output)
}
