toponymOptions <- function() {
    cat("\nIf you type 1, you may change settings about storing objects in the global environment.\n") 
    cat("\nIf you type 2, you may change settings about saving toponym data sets in the package folder.\n")
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
  options(global = selection)
  
  }else if (selection == 2){
  if(getOption("save_data") == TRUE){
      cat("\nToponym data sets will be saved in the package folder.\n")
    } else {
      cat("\nToponym data sets will be saved in a temporary folder.\n")
    }
    cat("\nYou may change this setting for the package.\nIf you type TRUE, toponym data sets will be saved in the package folder.\nIf you type FALSE, toponym data sets will be saved in a temporary folder.\n")
    cat("\nType TRUE or FALSE or leave by pressing enter.")
    selection <- readline()
    if (!any(c("TRUE", "FALSE") %in% selection)) {
      stop("Input must be TRUE or FALSE.")
    }
  options(save_data = selection)
  }
}