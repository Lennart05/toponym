#' @title  Alternatenames filter
#' @description Checks alternatenames column
#'
#' @param gn data frame(s), which will be accessed.
#' @param strings a character string vector with regular expressions to filter data.
#' @keywords internal
#'
#' @return A list of two vectors, logical values and matched strings.
#'
altNames <- function(gn, strings) {
  alt_names <- strsplit(gn$alternatenames, ",") # separate names in altnam col
  alt_names <- do.call(rbind, unname(lapply(alt_names, `length<-`, max(lengths(alt_names))))) # as matrix
  alt_l <- list()
  m_strings <- list()

  for (i in 1:nrow(alt_names)) {
    alt_l[[i]] <- grepl(paste(strings, collapse = "|"), alt_names[i, ], perl = TRUE) # check all alt names for reg ex match
    alt_l[[i]] <- any(alt_l[[i]])
  }
  if(!any(unlist(alt_l))) stop("\nThere were no matches.\n")

  w_strings <- as.logical(unlist(alt_l))
  alt_names <- alt_names[w_strings, ]
  if(is.null(alt_names)) stop("\nThere were no matches.\n")


  return(list(w_strings, alt_names))
}
