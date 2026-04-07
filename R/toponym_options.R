#' @title Manage Options of \code{toponym}
#' @description 
#' This function allows users to set the download path for the `toponym` package. Downloaded data includes toponym data and map data.
#' Most functions require external data which will be downloaded and stored for later use. This is described in the respective functions.
#' For this reason, after installation, users will be asked to specify the path for downloaded data. 
#' Users can set the path to the package directory with this command:
#' 
#' \code{toponymOptions(toponym_path = "pkgdir")}
#' 
#' A full, alternative path can also be provided.
#' 
#' 
#' If a path is provided, users are prompted to confirm their choice. This function will write the new path into `toponym_options.rds`in the package directory; the path is saved across sessions. 
#' To locate `toponym_options.rds`, enter:
#' 
#' \code{system.file("extdata", package = "toponym")}
#'
#'
#' To check the path that is currently set, enter:
#' 
#' `toponymOptions()`
#' @details
#' Parameter `toponym_path` accepts either the character string `"pkgdir"` or full, alternative paths.
#' `"pkgdir"` is interpreted as the extdata folder in the `toponym` package directory, i.e.:
#' \code{system.file("extdata", package = "toponym")}
#' @param toponym_path character string. Path name for downloaded data. This setting is saved across sessions.
#' 
#' @return A character string indicating the current path for downloaded data.
#' 
#' @examples
#' if(interactive()){
#' # Set the path to the temporary directory
#' # Users are prompted to confirm their choice.
#' # Upon confirmation, toponym_options.rds will be edited in the package directory
#' toponymOptions(toponym_path = tempdir())
#' #Show the current path
#' toponymOptions()
#' }
#' @export
toponymOptions <- function(toponym_path = NULL) {
  #read current path
  toponym_options <- readRDS(paste0(system.file("extdata", package = "toponym"), "/toponym_options.rds"))
  
  if(is.character(toponym_path)) toponym_options <- save_path(toponym_path, toponym_options)

  #check if path is NULL and if not, if it is a valid dir
  if(is.null(toponym_options)) stop("\nNo valid path for downloaded data specified.\nWrite toponymOptions(toponym_path = \"pkgdir\") to set the path to the package directory or provide a full, alternative path.")
  if(!dir.exists(toponym_options)) stop("\nNo valid path for downloaded data specified.\nWrite toponymOptions(toponym_path = \"pkgdir\") to set the path to the package directory or provide a full, alternative path.")
  
  return(toponym_options)
}