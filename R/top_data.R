topData <- function(query = NULL) {
  if(is.null(query) || query == "all") return(ls(envir = .top_env))
  if(length(ls(.top_env)) == 0) stop("The package environment is empty. Query ignored.")

  qS <- NULL
  for(i in 1:length(query)){
  qS[i] <- grep(query[i], ls(.top_env), value = TRUE)
  }

  countries <- tryCatch(expr = {
    country(query = query)
  },
  error = function(e){
  },
  warning = function(w){
  }
  )
  if(!is.null(countries)){
    for (i in 1:length(countries)) {
      countries[i] <- countries[[i]][, 1]
    } # converts input into ISO2 codes
    countries <- tolower(unlist(countries))
  }

  if(length(qS)>1){
    result <- list(.top_env[[qS]])
  }else {result <- .top_env[[qS]]}
  return(result)

}
