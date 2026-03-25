#' @title Save path for downloaded data.
#' @description This function saves the download path for the `toponym` package.
#' @param toponym_path character string. Path name for downloaded data.
#' @param toponym_options character string. Current path from .rds file.
#' @return A character string indicating the current path for downloaded data.
#' @keywords internal
save_path <- function(toponym_path, toponym_options) {
  answer = ""
  #if pkgdir is requested, set path to pkg dir
  if(toponym_path == "pkgdir") toponym_path <- system.file("extdata", package = "toponym")
  
  answer <- menu(title = paste0("Would you like to save this path? (0 to exit)\n", toponym_path), choices = c("Yes", "No"))
  if(answer == "1"){
  toponym_options <- as.character(toponym_path) #set path if specified by user
  saveRDS(toponym_options, paste0(system.file("extdata", package = "toponym"), "/toponym_options.rds"))
  message("Path set.")
  }else message("Path was not set.")
  
  return(toponym_options)
}
