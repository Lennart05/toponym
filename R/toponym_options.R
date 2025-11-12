#' @title Manage Options of \code{toponym}
#' @description This function allows users to modify settings for managing toponym data.
#' Users can choose whether to save matches and strings in the global environment or not to save them.
#' Further, users can specify whether toponym data retrieved from `GeoNames` will be saved in the package folder or in a temporary folder.
#'
#' @details
#' When the function is called, the user is prompted to select an option:
#' - Option `1`: Allows the user to modify the setting for storing objects in the global environment.
#' - Option `2`: Allows the user to modify the setting for saving toponym data sets in the package folder or in a temporary folder.
#' 
#' For option `1`, if the current setting is `TRUE`, matches from `top()` and strings from `topComp()` 
#' will be saved in the global environment; if the current setting is `FALSE`, the results will not be saved.
#' 
#' For option `2`, if the current setting is `TRUE`, toponym data sets will be saved in the package folder; 
#' if the current setting is `FALSE`, toponym data sets will be saved in a temporary folder.
#' 
#' @return This function does not return a value. It modifies package options based on user input.
#' 
#' @examples
#' # Call the function to manage toponym options
#' toponymOptions()
#' 
#' @export
toponymOptions <- function() {
  toponym_options <- readRDS(paste0(system.file("extdata", package = "toponym"), "/toponym_options.rds"))
  
    cat("\nIf you type 1, you may modify the setting for storing objects in the global environment.\n") 
    cat("\nIf you type 2, you may modify the setting for saving toponym data sets in the package folder or in a temporary folder.\n")
  selection <- readline()
  
  
  if(selection == 1){
  if(toponym_options["global",1] == TRUE){
  cat("\nCurrent Value: TRUE\nMatches from top() and strings from topComp() will be saved in the global environment.\n")
  } else {
  cat("\nCurrent Value: FALSE\nMatches from top() and strings from topComp() will not be saved in the global environment.\n")
  }
  cat("\nYou may modify this setting for the package.\nIf you type TRUE, objects will be saved in the global environment.\nIf you type FALSE, objects will not be saved in the global environment.\n")
  cat("\nType TRUE or FALSE or leave by pressing enter.")
  selection <- readline()
  if (!any(c("TRUE", "FALSE") %in% selection)) {
    stop("Input must be TRUE or FALSE.")
  }
  
  toponym_options["global",1] <- as.logical(selection)
  
  }else if (selection == 2){
  if(toponym_options["save_data", 1] == TRUE){
      cat("\nCurrent Value: TRUE\nToponym data sets will be saved in the package folder.\n")
    } else {
      cat("\nCurrent Value: FALSE\nToponym data sets will be saved in a temporary folder.\n")
    }
    cat("\nYou may modify this setting for the package.\nIf you type TRUE, toponym data sets will be saved in the package folder.\nIf you type FALSE, toponym data sets will be saved in a temporary folder.\n")
    cat("\nType TRUE or FALSE or leave by pressing enter.")
    selection <- readline()
    if (!(selection %in% c("TRUE", "FALSE"))) {
      stop("Input must be TRUE or FALSE.")
    }
  toponym_options["save_data", 1] <- as.logical(selection)
  }
  
  saveRDS(toponym_options, paste0(system.file("extdata", package = "toponym"), "/toponym_options.rds"))
}