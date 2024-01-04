#' @description
#' A package to analyze and visualize toponym distributions. You can plot, find, compare, analyze toponyms.
#'
#' The main functions are the following:
#' \itemize{
#' \item\code{\link{top}} plots selected toponyms onto a map.
#' \item\code{\link{country}} helps in navigating references to countries and regions used by the package.
#' \item\code{\link{createPolygon}} lets users create a polygon by point-and-click or directly retrieve polygon data.
#' \item\code{\link{topComp}} compares toponyms of a polygon and countries.
#' \item\code{\link{topCompOut}} saves multiple maps and toponym data.
#' \item\code{\link{topFreq}} retrieves the most frequent toponyms.
#' \item\code{\link{topZtest}} lets users apply a Z-test on toponym  data.
#' }
#' For more detailed descriptions read the respective documentation.

"_PACKAGE"

## usethis namespace: start
#' @importFrom utils write.csv
#' @importFrom utils download.file
#' @importFrom utils unzip
#' @importFrom utils read.table
#' @importFrom utils tail
#' @importFrom geodata world
#' @importFrom geodata gadm
#' @importFrom terra crds
#' @importFrom graphics segments
#' @importFrom grDevices chull
#' @importFrom grDevices rainbow
#' @importFrom dplyr %>%
#' @importFrom dplyr mutate_at
#' @importFrom sf st_as_sf
#' @importFrom sp point.in.polygon
#' @importFrom sp plot
#' @importFrom spatstat.utils spatstatLocator
#' @importFrom stats prop.test
#' @importFrom ggplot2 ggplot geom_sf theme_classic geom_point aes coord_sf scale_color_manual labs ggsave
## usethis namespace: end
NULL
