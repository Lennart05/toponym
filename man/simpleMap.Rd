% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simple_map.R
\name{simpleMap}
\alias{simpleMap}
\title{Plots toponyms onto a map}
\usage{
simpleMap(strings, coordinates, color, regions, plot, ...)
}
\arguments{
\item{strings}{character string with regular expression to filter data.}

\item{coordinates}{coordinates with country codes and matched strings filtered by \code{getCoordinates()}.}

\item{color}{character string indicating, which color is assigned to each string.}

\item{regions}{numeric. Specifies the level of regional borders. By default \code{0} for displaying only country borders.}

\item{plot}{logical. If \code{FALSE}, then the plot will not be printed but saved as .png in the current working directory.}

\item{...}{Addtional parameters:
\itemize{
\item\code{ratio_string} character string. Ratio of occurrences in the polygon from \code{topComp()}.
\item\code{fq} character string. Number of occurrences in the designated polygon and in total.
\item\code{legend_title} character string. Only if \code{mapper} is used. Text for the title of the legend. It is prioritized over \code{string} and \code{color} even if a \code{group} and \code{color} column exists.
}}
}
\value{
A plot of all selected toponyms.
}
\description{
This function generates a map plotting all locations, filtered by \code{getCoordinates()}.
}
\details{
If directly generated by \code{top()}, it displays the strings and the total occurrences. If generated by \code{topCompOut()}, it displays the string, the ratio as a percentage and the number of occurrences in the designated polygon and in total.
}
\keyword{internal}
