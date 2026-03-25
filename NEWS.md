# toponym 2.0.1
================
**Initial CRAN release**

This is the initial release accessible on CRAN.

* More detailed description in DESCRIPTION, see help(toponym)

* Changed `toponymOptions()`: 
    * Upon package installation,
      users need to specify a path in `toponymOptions()`
      for downloaded data from `getData()`
* mapper(): argument `plot_name` removed
* top(): arguments `csv`and `tsv` removed
* Added timeout for potential problems downloading toponym and map data

# toponym 2.0.0
================
The main difference between v1.0.0 and v2.0.0 is that v2.0.0 and future versions do not assign objects to the Global environment.