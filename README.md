toponym
================
February 21, 2024

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
<!-- badges: end -->

Welcome to the `toponym` GitHub page!

The `toponym` package supplies users of R with tools to visualize and
analyze toponym (= place name) distributions. It is intended as an
interface to the [GeoNames](https://www.geonames.org/) data. A regular
expression filters data and a map is created displaying locations which
comply with it. The functions make data and plots available for further
analysis – either within R or in the working directory. Users can select
regions within countries, provide coordinates to define regions, or
specify a region within the package to restrict the data selection to
that region or compare regions with the remainder of countries.

## Installation

In order to install this package, you will need `devtools`. You can
download and load the current development version of `toponym` from
[GitHub](https://github.com/Lennart05/toponym) with:

``` r
# install.packages("devtools")
# library ("devtools")
devtools::install_github("Lennart05/toponym")
```

## Create a simple map

The function `top()`, meaning “toponym”, creates maps of places
complying with a regular expression. Minimally one or more strings and
one or more countries (in that order) are given as input. The following
code is a simple example of this:

``` r
library(toponym) # load the package
top("itz$", "DE")
#> 
#> Dataframe data_itz saved in global environment.
```

<img src="man/figures/README-example-1.png" width="100%" />

The plot displays all locations which end in “-itz” in Germany, their
total frequency (2182), and stores the data in the global environment.

For the purpose of plotting an edited data frame, we offer the
`mapper()`function. This accepts user-defined title, legends, colors,
and groups. An example using the previously created data frame is the
following, where occurrences of -witz and -itz east of a 10.5
longitudinal line are displayed:

``` r
itz_east <- data_itz[data_itz$longitude > 10.5,]
itz_east$color <- "darkgrey"                # creates color column with color dark grey
witz_indices <- grep("witz", itz_east$name) # stores indices for lines containing "witz" 
itz_east[witz_indices, "color"] <- "green"  # sets color of "witz" entries to green
itz_east[witz_indices, "group"] <- "witz"   # sets group labels with "itz" to "witz"
mapper(itz_east, title = "-witz and -itz in the East")
```

<img src="man/figures/README-example mapper-1.png" width="100%" />

## Country designations

The data is meant to cover maps and toponyms of the world. The function
`country()` lets users access all permitted country and region
designations used by this package. The query `country table` returns the
entire data frame.

``` r
head(country(query = "country table"))
#>   ISO2 ISO3       Country
#> 1   AW  ABW         Aruba
#> 2   AF  AFG   Afghanistan
#> 3   AO  AGO        Angola
#> 4   AI  AIA      Anguilla
#> 5   AX  ALA Aland Islands
#> 6   AL  ALB       Albania
```

If you want to access the row of a specific country, you can either
provide the ISO2 code, ISO3 code or the country name:

``` r
country(query = "Argentina")
#> [[1]]
#>   ISO2 ISO3   Country
#> 9   AR  ARG Argentina
# returns the respective row for Argentina

country(query = "ARG")
#> [[1]]
#>   ISO2 ISO3   Country
#> 9   AR  ARG Argentina
# returns the same row
```

If `regions` is set to `1`, the function returns all region
designations:

``` r
country("Mali", regions = 1)
#> [[1]]
#>       name        ID       
#>  [1,] "Bamako"    "MLI.1_1"
#>  [2,] "Gao"       "MLI.2_1"
#>  [3,] "Kayes"     "MLI.3_1"
#>  [4,] "Kidal"     "MLI.4_1"
#>  [5,] "Koulikoro" "MLI.5_1"
#>  [6,] "Mopti"     "MLI.6_1"
#>  [7,] "Ségou"     "MLI.7_1"
#>  [8,] "Sikasso"   "MLI.8_1"
#>  [9,] "Timbuktu"  "MLI.9_1"
# returns all region names and IDs of Mali available in the data
```

## Frequent toponym substrings

`topFreq()` lets users find strings frequently recurring in toponym. A
simple example for the Philippines would be:

``` r
topFreq(countries = "Philippines",
        len = 3,
        limit = 10,
        type = "$")
#> toponyms
#> gan$ ang$ ong$ yan$ uan$ ion$ nan$ tan$ lan$ san$ 
#> 1750 1247 1128  764  693  608  598  548  545  504
```

Among all toponyms in the data for the Philippines
(`countries = "Philippines"`), these are the ten (`limit = 10`) most
frequent trailing (`type = "$"`) strings consisting of (a length of)
three characters (`len = 3`).

The additional parameter `polygon` allows users to restrict the data to
a subset of the selected countries. Only toponyms within the polygon are
selected. The polygon must intersect a country specified by the
parameter `countries`. The package contains a predefined polygon for the
historical Danelaw area of England for purposes of illustration:

``` r
topFreq(countries = "GB",
        len = 3,
        limit = 10,
        polygon = toponym::danelaw_polygon
)
#> toponyms
#> ton$ ham$ ley$ een$ ord$ rpe$ rth$ ill$ eld$ ell$ 
#> 1213  430  300  191  157  156  153  149  146  128
```

## Create polygons

Coordinates which delimit a polygon are input in the form of a data
frame. The `createPolygon()` function helps users to define their own
polygon by point-and-click or to retrieve map data.

``` r
argentina_polygon <- createPolygon(countries = "AR", regions = 1)
```

In this example, a map of Argentina `AR` with highest-level
administrative borders `regions = 1` will appear as a plot. Now users
can click to set points which define a polygon. The last point should
not repeat the first point. In RGui, users exit the point selection by
middle-clicking or right-clicking and then pressing stop. In RStudio,
users exit the point selection by pressing ESC or Finish in the top
right corner of the plot. Once finished, a data frame with longitudinal
and latitudinal coordinates called `argentina_polygon` is created.

## Strings specific to a region

`topComp()` determines which toponym strings in the data are
characteristic to a region. Consider again the following example for the
Danelaw area:

``` r
topComp(countries = "GB",
       len = 3,
       limit = 100,
       rat = .8, 
       polygon = toponym::danelaw_polygon
       )
#> 
#> Dataframe data_top_100 saved in global environment.
#>   toponym ratio_perc frequency
#> 1    rpe$      89.14   156/175
#> 2    lme$      80.43     37/46
```

The function compares the frequency of trailing strings (`type = "$"`)
within the Danelaw area (`polygon = toponym::danelaw_polygon`) with
their frequency in the United Kingdom (`countries = "GB"`) and returns a
data frame. The output is in descending order by their proportional
frequency. The search is limited to the 100 (`limit = 100`) most
frequent strings in theUnited Kingdom consisting of (a length of) three
characters (`len = 3`). The cut-off ratio of 80% (`rat = .8`) means that
at least 80% of all occurrences (in the country or countries) must be
inside the polygon. In this case, the string “-rpe” occurs 175 times in
the United Kingdom and 156 of these 176 occurrences are within the
target polygon resulting in a ratio percentage of 89.14%.

## Creating multiple maps at once

``` r
topCompOut(countries = "GB",
           len = 3,
           limit = 75,
           rat = .8,
           polygon = toponym::danelaw_polygon
                )
```

Running this with the same settings as just used for `topComp()`
produces a distributional map and a data frame of every string. The
plots are saved in the working directory in a separate folder called
“plots”. The data frames are saved in another folder called “data
frames”.

## Apply a Z-test

`topZtest()` tests whether the frequency of a toponym string is
significantly greater in the given area than in the rest of the country
or countries:

``` r
topZtest(strings = "aat$",
         countries = "BEL",
         polygon = toponym::flanders_polygon
                )
#> 
#>  2-sample test for equality of proportions with continuity correction
#> 
#> data:  c(string_in_poly, string_in_cc) out of c(top_in_poly, top_in_cc)
#> X-squared = 321.76, df = 1, p-value < 2.2e-16
#> alternative hypothesis: greater
#> 95 percent confidence interval:
#>  0.04767105 1.00000000
#> sample estimates:
#>       prop 1       prop 2 
#> 0.0527035237 0.0003287851
```

In this example, the function compares the toponymic distribution of the
trailing string “-aat” (`strings = "aat$"`) in Flanders
(`polygon = toponym::flanders_polygon`) with Belgium
(`countries = "BEL"`) as a whole. The result of the two proportion test
is returned as an object of class `htest`.

## The functions

The core functions are as follows:

- `top()` returns and plots selected toponyms onto a map.
- `country()` helps in navigating designations of countries and regions
  used by the package.
- `creatPolygon()` lets users create a polygon by point-and-click or
  directly retrieve polygon data.
- `mapper()` plots a user-specific data frame onto a map.
- `topComp()` compares toponym substrings in a polygon and in the
  remainder of a country (or countries).
- `topCompOut()` saves multiple maps and toponym data.
- `topFreq()` retrieves most frequent toponym substrings.
- `topZtest()` lets users apply a Z-test on toponym distributions.

For help type `?toponym` or a question mark following the individual
function name (or use the `help()` syntax). A link to the index at the
bottom of each help page provides a useful way of navigating the
package.

## Regular expression

For a concise description of which regular expressions exist and how
they can be used, type `help("regex")` in the R console or follow [this
guide](https://cran.r-project.org/web/packages/stringr/vignettes/regular-expressions.html).

## Data

The toponym data comes from [GeoNames](https://www.geonames.org/) and
will be automatically downloaded when you call any of the core
functions. It is recommended to save the data of the countries you
access in the package directory. This is the default option of the
function `getData()` but it is possible to place it in the temporary
folder by changing the parameter to `save = FALSE`. If you want to store
data only temporary, you need to use `getData()` before any other
function. Type `tempdir()` to find the temporary directory of the
current session.

For mapping purposes as well as region designations, the
[geodata](https://cran.r-project.org/web/packages/geodata/index.html)
package is used. It provides spatial data for all countries and regions
available in this package. All maps are stored in the geodata package
directory.
