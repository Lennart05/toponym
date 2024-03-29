% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_data.R
\name{getData}
\alias{getData}
\title{Downloads GeoNames data}
\usage{
getData(countries, save = TRUE, overwrite = FALSE)
}
\arguments{
\item{countries}{character string vector with country designations (names or ISO-codes).}

\item{save}{logical. If \code{TRUE}, the data sets will be extracted to the package folder. If \code{FALSE} it will be saved in a temporary folder.}

\item{overwrite}{logical. If \code{TRUE}, the data sets (.txt files) in the package folder will be overwritten.}
}
\description{
This function downloads toponym data for the package.
}
\details{
The data is downloaded from the \href{https://download.geonames.org/export/dump/}{GeoNames download page} and thereby made accessible to \code{readFiles()}. The function allows users to update GeoNames data and to set the date of access to that database to the current date.
Parameter \code{countries} accepts all designations found in \code{country(query = "country table")}.
}
\examples{
\dontrun{
getData(countries = c("DK", "DE"), save = FALSE)
## downloads and extracts data for DK and DE to the temporary folder

getData(countries = c("DK", "DE", "PL"), save = TRUE)
## downloads and extracts data for PL but only extracts data for DK and DE
## from the zip files downloaded before to the package folder if used in the same session
}
}
\seealso{
\href{https://download.geonames.org/export/dump/}{GeoNames download page}
}
