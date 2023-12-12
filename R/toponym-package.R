#' @keywords internal
#' @description
#' A simple package for visualizing toponym distributions. You either provide a regular expression searching for places matching it or find the most frequent toponyms specific to one area.
#'
#' The main functions are the following:
#' \itemize{
#' \item\code{\link{top}} generates one map with all locations matching the regular expression
#' \item\code{\link{country.data}} helps in navigating references to countries (ISO-codes) and regions
#' \item\code{\link{create.polygon}} lets users define a polygon by clicking on a map
#' \item\code{\link{top.candidates}} generates a list of prefixes or suffixes frequent in a given region
#' \item\code{\link{candidates.maps}} generates maps and lists on your computer out of these frequent prefixes and suffixes
#' \item\code{\link{top.freq}} generates a list of the most frequent toponyms
#' \item\code{\link{z.test}} lets users apply a z-test
#' }
#' For more detailed descriptions read the respective documentation.

"_PACKAGE"

## usethis namespace: start
#' @importFrom utils write.csv
#' @importFrom utils download.file
#' @importFrom utils unzip
#' @importFrom utils read.table
#' @importFrom geodata world
#' @importFrom geodata gadm
#' @importFrom terra crds
#' @importFrom grDevices chull
#' @importFrom grDevices rainbow
#' @importFrom dplyr %>%
#' @importFrom dplyr mutate_at
#' @importFrom sf st_as_sf
#' @importFrom sp point.in.polygon
#' @importFrom sp plot
#' @importFrom spatstat.geom clickpoly
#' @importFrom stats prop.test
## usethis namespace: end
NULL
