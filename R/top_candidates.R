#' @title Retrieves the most frequent toponym endings in a given polygon
#' @description
#' The function sorts the toponyms in the given countries by frequency. It then tests which lie in the given polygon, printing out a data frame with those endings which match the ratio criteria and are potential candidates for further examination. The coordinates form the polygon, which roughly resembles the Slavic settlement zone in Germany. It is generated with [Google My Maps](https://www.google.com/maps/about/mymaps/).
#' @param countries Character string with country code abbreviations (check \url{https://www.geonames.org/countries/} for a list of available countries) specifying, the toponyms of which countries are checked.
#' @param count numeric. The number of the most frequent endings which will be tested, e.g. by default the top ten most frequent endings in Germany.
#' @param len numeric. The character length of the endings, e.g. by default three-character-long endings.
#' @param rat numeric. The ratio (a number between 0.0 and 1) of how many occurrences of one ending need to be in the polygon.
#' @param lons numeric. Vector of longitudinal coordinates defining the polygon.
#' @param lats numeric. Vector of latitudinal coordinates defining the polygon.
#' @importFrom sp point.in.polygon
#' @importFrom grDevices chull
#'
#' @return A data frame printed out and saved in the global environment. It shows the ending surpassing the ratio, at what percentage and the frequency.
#' @export
#'
#' @examples
#' \dontrun{
#' top.candidates()
#' # prints and saves a data frame of the top ten three-character-long endings in Germany if more than 50% of them lie in the default polygon.
#'
#'
#' top.candidates("DK", count = 100, len = 4, rat = .9,
#'  lons = c(9.788425, 10.216892, 10.019138, 9.744480, 9.832370, 10.205905, 10.722263, 10.832126, 11.128757, 10.898044, 11.271579, 11.172702, 10.766208, 9.030368, 8.184421, 7.821872, 7.744968, 8.019626, 8.316257, 8.546970, 8.601902, 9.392917, 9.788425),
#'  lats = c(54.83623, 54.85521, 55.05078, 55.27671, 55.59458, 55.71235, 55.71235, 55.93453, 56.42372, 56.92469, 57.20542, 57.57251, 57.90093, 57.48404, 57.05038, 56.30200, 55.61320, 54.96888, 55.08224, 55.02560, 54.90577, 54.77291, 54.83623)
#'  )
#' # prints and saves a data frame of the top 100 four-character-long endings in Denmark if more than 90% of them lie in the newly defined polygon.
#'}
#'
top.candidates <- function(countries="DE", count = 10, len = 3, rat = .5,
  lons = c(10.144314,10.0399439 ,10.5178491 ,11.3143579 ,11.8746607 ,11.8087427 ,11.6274683 ,11.5450708 ,11.7757837 ,11.6659204 ,10.2140419 ,9.917411 ,9.8075477 ,10.6919471 ,12.8617469 ,14.9821083 ,15.5204383 ,14.6964637 ,13.8834755 ,12.9496376 ,11.6202919 ,11.1039344 ,10.144314),
  lats = c(54.3227499 ,53.5107333 ,53.324126 ,53.0476312 ,52.8755735 ,52.5928491 ,52.2377021 ,52.0826909 ,51.9389938 ,51.764248 ,51.0454903 ,50.8031092 ,50.2724411 ,49.8067462 ,49.7499912 ,50.2408327 ,51.6459284 ,53.9825363 ,54.6235699 ,54.7378977 ,54.4323074 ,54.5790222, 54.3227499)
  ) {
  gn <- read.files(countries)

  # query all endings from the dataset
  endings <- paste(
    # creates a reg expr looking for endings of length "len"
    regmatches(gn$name,regexpr(paste0(paste(replicate(len,"."), collapse = ""), "$"),gn$name)), "$", sep = "")
  # order them by frequency
  endings_o <- names(table(endings)[order(table(endings), decreasing = TRUE)])

  endings_ID_o <- list()
  lat_strings <- list()
  lon_strings <- list()
  loc_log <- list()
  ratio <- list()
  dat <- list()


  # store coordinates of the polygon in a df
  pol  <- data.frame(X = lons, Y = lats)
  # chull function from package grDevices
  pos <- chull(pol)
  con.hull <- rbind(pol[pos,],pol[pos[1],])   # convex hull


  for (i in 1:count) {
    # stores indices of all ordered endings
    endings_ID_o[[i]] <- unique(grep(endings_o[i], gn$name))

    lat_strings[[i]] <- gn$rlatitude[endings_ID_o[[i]]]
    lon_strings[[i]] <- gn$rlongitude[endings_ID_o[[i]]]
    # country[[i]] <- gn$rcountry_code[endings_ID_o[[i]]]

    # logical vectors storing if each place is within the given area
    loc_log[[i]] <- as.logical(point.in.polygon(lon_strings[[i]], lat_strings[[i]], con.hull$X, con.hull$Y))
    # percentage of places which are in the area
    ratio[[i]] <- sum(loc_log[[i]])/length(loc_log[[i]])

    # select only endings which surpass parameter rat
    if (ratio[[i]]>rat) {
      dat[[i]] <- cbind(endings_o[i], paste0(round(ratio[[i]], 4)*100, "%"),
                        paste0(sum(loc_log[[i]]),"/", length(loc_log[[i]])))



  dat <- as.data.frame(cbind(unlist(dat)[c(TRUE, FALSE, FALSE)], unlist(dat)[c(FALSE, TRUE, FALSE)], unlist(dat)[c(FALSE, FALSE, TRUE)]))
  colnames(dat) <- c("ending", "ratio", "frequency")

  dat_name <- paste0("data_top_", count)
  assign(dat_name, dat, envir = .GlobalEnv)
  cat(paste("\nDataframe",dat_name ,"saved in global environment.\n"))

  invisible(return(dat))

  } else if (all(ratio<rat)){
    cat("\nNo ending surpasses the ratio.")
  }
  }
  }
