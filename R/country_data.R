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
#' country.data(query = "ISO3")
#' ## returns list of all ISO3 codes
#'
#' country.data(query = "Thailand")
#' ## returns a data frame with the ISO2, ISO3 code and the full name
#'
#' country.data(query = "Thailand", regions = TRUE)
#' ## returns all region names
#'
#' }
country.data <- function(query = NULL, regions = FALSE){


    countryInfo <- toponym::countryInfo

    if(length(query) >1){
      print("Please enter only one request at a time.")
    }

    else if(regions == FALSE){

    if(query == "country table"){
    return(countryInfo)
    } else if(query == "ISO2"){ #outputs all ISO2 codes
    return(countryInfo[,1])
    } else if(query == "ISO3"){ #outputs all ISO3 codes
    return(countryInfo[,2])
    } else if(query == "names"){ #outputs all country names
    return(countryInfo[,3])
    } else if(nchar(query) == 2){ #ISO2 code as input
    output <- countryInfo[match(query, countryInfo[,1]),] #then outputs respective row
    } else if(nchar(query) == 3){ #ISO3 code as input
    output <- countryInfo[match(query, countryInfo[,2]),] #then outputs respective row
    } else if(nchar(query) >= 4){ #country name as input
    output <- countryInfo[match(query, countryInfo[,3]),] #then outputs respective row
    }
    if(is.na(output[1])){print("The query contains incorrect country names")} #check for NAs

    }else{ # if regions is TRUE

      map_path <- paste0(system.file(package = "geodata"),"/extdata")
      output <- gadm(country = query, path = map_path)$NAME_1
      Encoding(output) <- "UTF-8" #corrects encoding
    }
    return(output)

  }
