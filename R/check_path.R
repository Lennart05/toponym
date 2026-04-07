#' @title Check path for downloaded data
#' @description This function checks the download path for the `toponym` package.
#' @details
#' If a path is provided using a function, this function checks it for validity. If no path is provided, this function retrieve the path from the .Rds file stored in the package directory and checks it for validity.
#' @param toponym_path character string. Path name for downloaded data. If not specified, this function will call `toponymOptions()` and try use the persistent path.
#' @return Character string of the used path for downloaded data.
#' @keywords internal
checkPath <- function(toponym_path = NULL) {
  #toponym is NULL, read .Rds for path
  if(is.null(toponym_path)){
    toponym_path <- toponymOptions()
  }else{
    #use pkg dir if requested
    if(toponym_path == "pkgdir") toponym_path <- system.file("extdata", package = "toponym")
    #check if path is a valid dir
    if(!dir.exists(toponym_path)) stop("\nNo valid path for downloaded data specified.\nWrite toponymOptions(toponym_path = \"pkgdir\") to set the path to the package directory or provide a full, alternative path.")
  }
  return(toponym_path)
}