#' @title Check for matches in alt names column
#'
#' @param gn The data frame(s), which will be accessed.
#' @param strings Character strings in form of regular expression that filter the data frames.
#' @keywords internal
#'
#' @return logical vector
#'
altNames <- function(gn, strings) {
  alt_names <- strsplit(gn$alternatenames, ",")  #separate names in altnam col
  alt_names <- do.call(rbind, unname(lapply(alt_names, `length<-`, max(lengths(alt_names))))) #as matrix
  alt_l <- list()

  for(i in 1:nrow(alt_names)){
    alt_l[[i]] <- grepl(paste(strings,collapse = "|"), alt_names[i,], perl = TRUE) #check all alt names for reg ex match
    alt_l[[i]] <- sum(alt_l[[i]])
    if(alt_l[[i]]>0)
    {alt_l[[i]] <- 1}
  }

  w_strings <- as.logical(unlist(alt_l))
  alt_names <- alt_names[w_strings,]

  m_strings <- list()
  for(i in 1:nrow(alt_names)){
  m_strings[[i]] <- regmatches(alt_names[i,],regexpr(paste(strings,collapse="|"), alt_names[i,], perl = TRUE)) # gets matches
  }
  m_strings <- do.call(rbind, unname(lapply(m_strings, `length<-`, max(lengths(m_strings)))))
  m_strings <- m_strings[,1]

  return(list(w_strings, m_strings))
  }
