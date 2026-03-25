# toponym 2.0.1
================
**Initial CRAN release**

This is the initial release accessible on CRAN.

* More detailed description in DESCRIPTION, see help(toponym)

* no default location set for downloaded data. Now users either
    * specify a persistent path in `toponymOptions()`; or
	* specify a path using parameter `toponym_path`
	  whenever they use a function requiring downloaded data
* mapper(): argument `plot_name` removed
* top(): arguments `csv`and `tsv` removed
* Added timeout for potential problems downloading toponym and map data
* getData() returns the used path for downloaded data

# toponym 2.0.0
================
The main difference between v1.0.0 and v2.0.0 is that v2.0.0 and future versions do not assign objects to the Global environment.