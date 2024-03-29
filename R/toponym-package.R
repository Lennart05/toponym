#' @description
#' A package to analyze and visualize toponym distributions.
#'
#' The main functions are the following:
#' \itemize{
#' \item\code{\link{top}} returns and plots selected toponyms onto a map.
#' \item\code{\link{country}} helps in navigating designations of countries and regions used by the package.
#' \item\code{\link{createPolygon}} lets users create a polygon by point-and-click or directly retrieve polygon data.
#' \item\code{\link{mapper}} plots a user-specific data frame onto a map.
#' \item\code{\link{topComp}} compares toponym substrings in a polygon and in the remainder of a country (or countries).
#' \item\code{\link{topCompOut}} saves multiple maps and toponym data.
#' \item\code{\link{topFreq}} retrieves most frequent toponym substrings.
#' \item\code{\link{topZtest}} lets users apply a Z-test on toponym distributions
#' }
#' For more detailed descriptions please read the respective documentation.

"_PACKAGE"

## usethis namespace: start
#' @importFrom utils write.table download.file unzip read.table tail
#' @importFrom geodata world gadm
#' @importFrom terra crds plot
#' @importFrom ngram get.phrasetable ngram
#' @importFrom graphics segments
#' @importFrom grDevices rainbow
#' @importFrom sf st_as_sf
#' @importFrom spatstat.geom owin inside.owin
#' @importFrom spatstat.utils spatstatLocator
#' @importFrom stats prop.test aggregate
#' @importFrom ggplot2 ggplot geom_sf theme_classic geom_point aes coord_sf scale_color_manual labs ggsave
## usethis namespace: end
NULL
