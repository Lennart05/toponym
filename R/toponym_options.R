#' @title Manage Options of \code{toponym}
#' @description This function allows users to modify settings for managing toponym data.
#' Users can specify whether toponym data retrieved from `GeoNames` will be saved in the package folder or in a temporary folder.
#'
#' @details
#' Parameter `save_data`: if the current setting is `TRUE`, toponym data sets will be saved in the package folder; 
#' if the current setting is `FALSE`, toponym data sets will be saved in a temporary folder.
#' 
#' If no parameter is set, i.e. `toponymOptions()`, the complete data frame with current settings is printed.
#' 
#' @param save_data logical. Enter `TRUE` or `FALSE`. Allows the user to modify the setting for saving toponym data sets in the package folder or in a temporary folder.
#' 
#' @return A data frame with the value(s) of the respective setting(s).
#' 
#' @examples
#' # Show the current settings
#' toponymOptions()
#' 
#' @export
toponymOptions <- function(save_data = NULL) {
  toponym_options <- readRDS(paste0(system.file("extdata", package = "toponym"), "/toponym_options.rds"))

  if(!is.null(save_data)){toponym_options["save_data", 1] <- as.logical(save_data)
  cat("\nCurrent value:\n")
  print(toponym_options["save_data",1]) 
  }
  saveRDS(toponym_options, paste0(system.file("extdata", package = "toponym"), "/toponym_options.rds"))
}