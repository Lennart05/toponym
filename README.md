toponym
================
Lennart Chevallier & Søren Wichmann
October 24, 2023

<!-- README.md is generated from README.Rmd. Please edit that file -->

## toponym

<!-- badges: start -->
<!-- badges: end -->

Welcome to the `toponym` GitHub page!

The initial goal of the `toponym` package is to have a tool to easily
visualize the distribution of toponyms (= place names). When a regular
expression is given, a map is generated displaying all populated
locations matching it. If needed, the plot can be saved locally as .png
file. A list of locations in form of a data frame can be temporarily
saved in the session environment or to the working directory as .csv
file as well.

For questions about which toponyms are prevalent in a region, the
`toponym` package searches for the most frequent toponym prefixes or
suffixes, checks how often they appear in the specified region, and
generates maps of those toponyms having significant frequency. This way,
you will quickly have a large number of maps helping you to find
toponyms which show distributions that may fruitfully be examined
further.

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

The function `top()`, meaning “toponym”, creates maps of places matching
a regular expression. First, a string, then a country is given. The
following code is a simple example of this:

``` r
library(toponym)
top("itz$", "DE") 
#> 
#> Dataframe data_itz saved in global environment.
```

<img src="man/figures/README-example-1.png" width="100%" />

The plot shows all locations, which end with “-itz” in Germany, their
total frequency (2182), and stores the data in the global environment.
As you can see, most occurrences are located in the former Slavic
settlement zone, indicating that the ending may be of Slavic origin. In
this case, we know that already.

## Country names and codes

The data is supposed to cover maps and toponyms of the world. The
`country.data()` lets you access the table with all countries available
as well as regional names of specified countries.

``` r
head(country.data(query = "country table"))
#>   ISO2 ISO3       Country
#> 1   AW  ABW         Aruba
#> 2   AF  AFG   Afghanistan
#> 3   AO  AGO        Angola
#> 4   AI  AIA      Anguilla
#> 5   AX  ALA Aland Islands
#> 6   AL  ALB       Albania
```

If you want to access the row of one specific country, you can either
provide the ISO2 code, ISO3 code or the country name:

``` r
country.data(query = "Argentina")
#>   ISO2 ISO3   Country
#> 9   AR  ARG Argentina
#returns the respective row for Argentina

country.data(query = "ARG")
#>   ISO2 ISO3   Country
#> 9   AR  ARG Argentina
#returns the same row
```

When `regions` is set to `TRUE`, the function returns all region names:

``` r
country.data(query = "AR", regions = TRUE)
#>  [1] "Buenos Aires"           "Catamarca"              "Chaco"                 
#>  [4] "Chubut"                 "Ciudad de Buenos Aires" "Córdoba"               
#>  [7] "Corrientes"             "Entre Ríos"             "Formosa"               
#> [10] "Jujuy"                  "La Pampa"               "La Rioja"              
#> [13] "Mendoza"                "Misiones"               "Neuquén"               
#> [16] "Río Negro"              "Salta"                  "San Juan"              
#> [19] "San Luis"               "Santa Cruz"             "Santa Fe"              
#> [22] "Santiago del Estero"    "Tierra del Fuego"       "Tucumán"
#returns all regional names of Argentina in the data set
```

## List suffixes specific to a region

If we want to find out which toponyms appear frequently in one region
compared to the rest of the given countries, we need to specify a
polygon. The function requires two vectors, one with the longitudes and
another with latitudes. A few polygons are part of the package. Later,
the built-in function to create polygons with is described. A polygon
covering an area of the Danelaw is in `toponym::danelaw_polygon`. For
example, we can run this:

``` r
top.candidates(countries = "GB", count = 75, len = 3, rat = .8, lons = toponym::danelaw_polygon$lons, lats = toponym::danelaw_polygon$lats)
#> 
#> Dataframe data_top_75 saved in global environment.
#>   toponym  ratio frequency
#> 1    rpe$ 94.86%   166/175
#> 2    sby$ 83.13%     69/83
#> 3    rby$ 81.67%     49/60
```

The output is a data frame giving us information about the ratio and
frequency of each ending. This means essentially that 94.86% of the
German places ending with “-rpe” are in the polygon. Even though the
endings are less common in total, “-sb” and “-rby” may be of interest
too as most occurrences are found in the polygon. To be clear what
happened: Other common suffixes in Great Britian such as “-ton” are
filtered out since they did not match our fairly high threshold of 80%
`rat = .8`. `count = 75` and `len = 3` means that we filtered the 75
most frequent suffixes with a length of three-characters.

Instead of applying this data frame with interesting candidates on your
own, there is another function doing this automatically.

## Creating multiple maps at once

``` r
candidates.maps(countries = "GB", count = 75, len = 3, rat = .8, lons = toponym::danelaw_polygon$lons, lats = toponym::danelaw_polygon$lats)
```

Running this with the same settings leaves us with a map of every ending
from before saved in the working directory in a separate folder called
“plots” as well as the respective data frames in another folder called
“data frames”. At this point, you can skim through or closely examine
the maps at a later date.

## Create polygons

You can either provide the coordinates of any polygon you have or create
one with the built-in function `create.polygon()`.

``` r
argentina_polygon <- create.polygon(countries = "AR", regions = 1)
```

In this example, a map of Argentina `AR` with state boundaries
`regions = 1` appears as plot. Now, a polygon can be defined by clicking
on the map and pressing `ESC` or the middle mouse button to exit. The
last point should not repeat the first point. Once finished, the newly
defined polygon is stored as a data frame called `argentina_polygon`. If
you do not store the output, the function will only print out the data
frame with the coordinates. It’s also possible to specify names of
regions in the given countries. Check the `country.data()` section above
for more information.

## Exemplary usage

To illustrate `toponym`, we make a quick step by step rundown. Let’s
look at Belgium: The two main regions, Flanders and Wallonia (we ignore
Brussels), have each one dominant standard language, alongside dialectal
variations. Dutch is dominant in the northern region, Flanders, and
French is dominant in the southern region, Wallonia, except small German
communities near the German border. Is this division also reflected by
toponyms? First, we need at least one polygon of a region. As part of
the package, the coordinates for Flanders is provided as
`toponym::flanders_polygon`. Thus, we could run this:

``` r
### find suffixes typical in Flanders
head(top.candidates(countries = "BE", count = 100, len = 3, rat = 0.8,
 lons = toponym::flanders_polygon$lons, lats = toponym::flanders_polygon$lats))
#> 
#> Dataframe data_top_100 saved in global environment.
#>   toponym  ratio frequency
#> 1    oek$ 99.84%   635/636
#> 2    aat$ 99.71%   348/349
#> 3    erg$ 94.63%   317/335
#> 4    ide$ 95.52%   213/223
#> 5    ken$ 96.43%   189/196
#> 6    gem$   100%   186/186
```

As the data frame shows, there are many suffixes almost only appearing
in Flanders but the limitation to three characters could cut the actual
suffixes off. For example, let’s take a closer look at “-aat” which is
the second most frequent in total:

``` r
top("aat$", "BE")
#> 
#> Dataframe data_aat saved in global environment.
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" /> The
high density of places ending with “-aat” in the central region stands
out and as we knew from the data frame earlier almost all (99.71%)
appear in our polygon. Looking at the full names (after generating this
map we end up with a data frame of the selection in the global
environment), it’s notable that the ending is in fact “-straat” meaning
as much as “-street”. From here on, a closer examination could start, e.
g., asking which conditions led to the frequency in the middle region.
And in addition, we could again use the `candidates.maps()` function
with the same parameters and check each map:

``` r
candidates.maps(countries = "BE", count = 100, len = 3, rat = 0.8, 
  lons = toponym::flanders_polygon$lons, lats = toponym::flanders_polygon$lats)
```

## Finding prefixes

As one last example we look at dominant prefixes in the same region. For
that the parameter `type` needs to be set to “^” as the default option
searches for suffixes (“\$”):

``` r
head(top.candidates("BE", 100, 4, 0.8, type = "^", 
  toponym::flanders_polygon$lons, toponym::flanders_polygon$lats))
#> 
#> Dataframe data_top_100 saved in global environment.
#>   toponym  ratio frequency
#> 1   ^Sint 98.32%   117/119
#> 2   ^Klei   100%     86/86
#> 3   ^Mole   100%     83/83
#> 4   ^Drie 98.67%     74/75
#> 5   ^Den    100%     60/60
#> 6   ^Hoog 98.15%     53/54
```

Next, we could look at one of them to see their distribution and form.
We suspect that it is of Germanic origin and include Netherlands and
France for testing:

``` r

top("^Hoog", c("BE", "NL", "FR"))
#> 
#> Dataframe data_Hoog saved in global environment.
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" /> Most
cases seem to be in the western and only few in the central region near
the border. As we might have expected, “Hoog-” occurs also throughout
the Netherlands but not in France. It is advised that the user adjusts
the length parameter `len` and runs the function multiple times to skim
through possible toponyms.

## Frequent toponyms

Lastly, `top.freq()` lets users find the most frequent toponyms in the
given countries or a polygon within the countries. A simple example
would be:

``` r
top.freq("Philippines", len = 3, count = 10)
#> [1] "PH.txt saved in package directory"
#> toponyms
#> gan$ ang$ ong$ yan$ uan$ ion$ nan$ tan$ lan$ san$ 
#> 1750 1247 1128  764  693  608  598  548  545  504
```

You need to specify the number of frequent toponyms you want (here
`count = 10`) and the length of the endings or beginning (here
`len = 3`). It’s also possible to restrict it to one polygon. In
comparison to the previous functions, this only outputs what is most
frequent in the region or country, while `top.candidates()` calculates,
which toponyms are most frequent in the country and then checks which of
them meet the threshold specified by `rat`, indicating that they are
common to the polygon. Running this function and the previous one we
used for the Danelaw again:

``` r
top.freq("GB",
         lons = toponym::danelaw_polygon$lons,
         lats = toponym::danelaw_polygon$lats, len = 3, count = 10)
#> toponyms
#> ton$ ham$ ley$ een$ ord$ rth$ ill$ rpe$ eld$ all$ 
#> 1391  453  371  221  198  174  172  166  158  156
```

``` r
top.candidates(countries = "GB", count = 75, len = 3, rat = .8,
               lons = toponym::danelaw_polygon$lons,
               lats = toponym::danelaw_polygon$lats)
#> 
#> Dataframe data_top_75 saved in global environment.
#>   toponym  ratio frequency
#> 1    rpe$ 94.86%   166/175
#> 2    sby$ 83.13%     69/83
#> 3    rby$ 81.67%     49/60
```

We see that “-rpe” is among the top ten most common endings but “-ton”
is more frequent in total. It may be common across the entire country.

## The functions

The core functions are again as follows:

- `top()` generates one map with all locations matching the regular
  expression
- `country.data()` helps in navigating references to countries
  (ISO-codes) and regions
- `create.polygon()` lets the user define a polygon by clicking on a map
- `top.candidates()` generates a list of prefixes or suffixes frequent
  in a given region
- `candidates.maps()` generates maps and lists on your computer out of
  these frequent prefixes and suffixes
- `top.freq()` generates a list of the most frequent toponyms
- `z.test()` lets users apply a z-test

For help type `?function` or `?toponym`

## Limitations

It should be clear that this tool merely helps one find frequent
toponyms. Less frequent ones, ones with different spelling yet of the
same origin or others which are of multiple origins but have the same
form (e.g. “-au” in Germany) require in depth examination. The data may
be non-exhaustive and could contain errors.

## Regular expression

The possible queries with regular expressions are broader and wider than
the given examples illustrate. For a concise description of which
regular expressions exist and how they can be used, type `help("regex")`
in the R console or follow [this
guide](https://cran.r-project.org/web/packages/stringr/vignettes/regular-expressions.html).

## Data

The data comes from [GeoNames](https://www.geonames.org/) and will be
automatically downloaded from there when you call any of the core
functions. It is recommended to save the data of the countries you look
at in the package directory. This is the default option of the function
`get.data()` but it is possible to place it in the temporary folder by
changing the parameter to `save = FALSE`. Type `tempdir()` to find the
temporary directory of the current session.

## Future work

We plan to update and improve the package in the future. This includes a
more detailed documentation, feedback for users when errors occur and
more. We look forward to any feedback or ideas!
