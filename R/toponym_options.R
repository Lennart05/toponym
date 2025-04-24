#' @title Manage Options of \code{toponym}
#' @description This function allows users to change settings related to the storage of toponym data.
#' Users can decide whether to save matches and strings in the global environment or not.
#' Further, users can decide whether toponym data from `geonames` is saved in the package folder or in a temporary folder.
#'
#' @details
#' When the function is called, the user is prompted to select an option:
#' - Typing `1` allows the user to change the setting related to storing objects in the global environment.
#' - Typing `2` allows the user to change the setting related to saving toponym datasets in the package folder or in a temporary folder.
#' 
#' For option `1`, if the current setting is `TRUE`, matches from `top()` and strings from `topComp()` 
#' will be saved in the global environment; if the current setting is `FALSE`, they will not be saved.
#' 
#' For option `2`, if the current setting is `TRUE`, toponym datasets will be saved in the package folder; 
#' if the current setting `FALSE`, they will be saved in a temporary folder.
#' 
#' @return This function does not return a value. It modifies package options based on user input.
#' 
#' @examples
#' # Call the function to manage toponym options
#' toponymOptions()
#' 
#' @export
toponymOptions <- function() {
    cat("\nIf you type 1, you may change the setting related to storing objects in the global environment.\n") 
    cat("\nIf you type 2, you may change the setting related to toponym data sets in the package folder.\n")
  selection <- readline()
  
  
  if(selection == 1){
  if(getOption("global") == TRUE){
  cat("\nMatches from top() and strings from topComp() will be saved in the global environment.\n")
  } else {
  cat("\nMatches from top() and strings from topComp() will not be saved in the global environment.\n")
  }
  cat("\nYou may change this setting for the package.\nIf you type TRUE, objects will be saved in the global environment.\nIf you type FALSE, objects will not be saved in the global environment.\n")
  cat("\nType TRUE or FALSE or leave by pressing enter.")
  selection <- readline()
  if (!any(c("TRUE", "FALSE") %in% selection)) {
    stop("Input must be TRUE or FALSE.")
  }
  options(global = as.logical(selection))
  
  }else if (selection == 2){
  if(getOption("save_data") == TRUE){
      cat("\nToponym data sets will be saved in the package folder.\n")
    } else {
      cat("\nToponym data sets will be saved in a temporary folder.\n")
    }
    cat("\nYou may change this setting for the package.\nIf you type TRUE, toponym data sets will be saved in the package folder.\nIf you type FALSE, toponym data sets will be saved in a temporary folder.\n")
    cat("\nType TRUE or FALSE or leave by pressing enter.")
    selection <- readline()
    if (!(selection %in% c("TRUE", "FALSE"))) {
      stop("Input must be TRUE or FALSE.")
    }
  options(save_data = as.logical(selection))
  }
}