#' @title Manage Options of \code{toponym}
#' @description This function allows users to modify a setting for managing toponym data.
#' Users can specify whether toponym data retrieved from `GeoNames` will be saved in the package folder or in a temporary folder.
#'
#' @details
#' Parameter `toponym_path`: if the current setting is `TRUE`, toponym data sets will be saved in the package folder; 
#' if the current setting is `FALSE`, toponym data sets will be saved in a temporary folder.
#' 
#' If no parameter is set, i.e. `toponymOptions()`, the complete data frame with current settings is printed.
#' 
#' @param toponym_path logical. Enter `TRUE` or `FALSE`. Allows the user to modify the setting for saving toponym data sets in the package folder or in a temporary folder.
#' 
#' @return A character string.
#' 
#' @examples
#' \dontrun{
#' # Show the current path
#' toponymOptions()
#' }
#' 
#' @export
toponymOptions <- function(toponym_path = NULL) {
  #read path
  toponym_options <- readRDS(paste0(system.file("extdata", package = "toponym"), "/toponym_options.rds"))
  
  #check if path contains valid dir
  if(!dir.exists(toponym_options)) stop("No valid path for downloaded data specified. Write toponymOptions(toponym_path = \"pkgdir\") to set the path to the package directory or provide a full, alternative path.")
  
  #sets path
  toponym_options <- as.character(toponym_path) #set path if specified by user
  saveRDS(toponym_options, paste0(system.file("extdata", package = "toponym"), "/toponym_options.rds"))
  return(toponym_options)
}