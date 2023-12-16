topData <- function(countries) {
  if (length(countries) > 1) {
    warning("Multiple requests are not allowed. Only the first element will be used.")
  }
  return(top_env[[tolower(countries)]])
}
