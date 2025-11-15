#' @title Manage Options of \code{toponym}
#' @description This function allows users to modify settings for managing toponym data.
#' Users can choose whether to save matches and strings in the global environment or not to save them.
#' Further, users can specify whether toponym data retrieved from `GeoNames` will be saved in the package folder or in a temporary folder.
#'
#' @details
#' Parameter `global`: if the current setting is `TRUE`, matches from `top()` and strings from `topComp()` 
#' will be saved in the global environment; if the current setting is `FALSE`, the results will not be saved.
#' 
#' Parameter `save_data`: if the current setting is `TRUE`, toponym data sets will be saved in the package folder; 
#' if the current setting is `FALSE`, toponym data sets will be saved in a temporary folder.
#' 
#' If no parameter is set, i.e. `toponymOptions()`, the complete data frame with current settings is printed.
#' 
#' @param global logical. Enter `TRUE` or `FALSE`. Allows the user to modify the setting for storing objects in the global environment.
#' @param save_data logical. Enter `TRUE` or `FALSE`. Allows the user to modify the setting for saving toponym data sets in the package folder or in a temporary folder.
#' 
#' @return A data frame with the value(s) of the respective setting(s).
#' 
#' @examples
#' # Show the current settings
#' toponymOptions()
#' 
#' @export
toponymOptions <- function(global = NULL, save_data = NULL) {
  toponym_options <- readRDS(paste0(system.file("extdata", package = "toponym"), "/toponym_options.rds"))
  
  if(!is.null(global)){
    toponym_options["global",1] <- as.logical(global)
    cat("\nCurrent value:\n")
    print(toponym_options["global",1]) 
    }
  if(!is.null(save_data)){toponym_options["save_data", 1] <- as.logical(save_data)
  cat("\nCurrent value:\n")
  print(toponym_options["save_data",1]) 
  }
  if(is.null(global) & is.null(save_data)){
  print(toponym_options) 
  }
  saveRDS(toponym_options, paste0(system.file("extdata", package = "toponym"), "/toponym_options.rds"))
}