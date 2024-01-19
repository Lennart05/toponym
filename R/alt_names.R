#' @title  Alternatenames Filter
#' @description Checks alternatenames column
#'
#' @param gn data frame(s), which will be accessed.
#' @param strings character string with regular expression to filter data.
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
  if(is.null(alt_names) == 0) stop("\nThere were no matches.\n")

  for (i in 1:nrow(alt_names)) {
    m_strings[[i]] <- regmatches(alt_names[i, ], regexpr(paste(strings, collapse = "|"), alt_names[i, ], perl = TRUE)) # gets matches
  }
  m_strings <- do.call(rbind, unname(lapply(m_strings, `length<-`, max(lengths(m_strings)))))
  m_strings <- m_strings[, 1]

  return(list(w_strings, m_strings))
}
