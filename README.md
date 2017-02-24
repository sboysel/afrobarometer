<!-- README.md is generated from README.Rmd. Please edit that file -->
    ## Installing afrobarometer

    ## '/usr/lib64/R/bin/R' CMD INSTALL '/home/sam/repos/afrobarometer'

Afrobarometer Data
==================

**Data Source:** <http://www.afrobarometer.org/data> - [Data usage policy](http://www.afrobarometer.org/data/data-use-policy) - [IPUMS-DHS](https://www.idhsdata.org/idhs/)

Install
-------

Install `afrobarometer` package

``` r
devtools::install_github("sboysel/afrobarometer")
```

Note that the following packages must be installed. It may be required that some system software packages need to be installed outside of R.

| R package   | Dependencies |
|-------------|--------------|
| `rgdal`     | `gdal`       |
| `rgeos`     | `geos`       |
| `RMYSqlite` | `sqlite3`    |

Required Data
-------------

-   Open access data: individual responses to survey questionnaires.
-   Restricted access data (optional): spatial locations, recently administered rounds.

The `afrobarometer` package fetches any public access data necessary and merges the available spatial data with the questionnaire data. If spatial data is not provided for a specific round, the final table is simply the questionnaire data.

Usage
-----

``` r
library(afrobarometer)
afrb_dir(path = tempdir())
#> Setting options(afrobarometer.data) to /tmp/Rtmpi5BPFF
#> Setting options(afrobarometer.sqlite) to /tmp/Rtmpi5BPFF/afrobarometer.sqlite
#> Spatial data should be placed in the `locations` subdirectory of the Afrobarometer data directory. For example, if you have spatial data for Rounds 3 and 4, you should place the spatial data as follows:
#> 
#> /tmp/Rtmpi5BPFF/locations/Locations_R3.csv
#> /tmp/Rtmpi5BPFF/locations/Locations_R4.csv
#> 
#> To change the data directory to file path x, use afrobarometer::set_data_dir(x)
#> Creating directories
#>  - /tmp/Rtmpi5BPFF ...
#>  - /tmp/Rtmpi5BPFF/questionnaires ...
#>  - /tmp/Rtmpi5BPFF/locations ...
```

`afrb_dir` sets the local cache directory to `path`, creating subdirectories and the local database file as needed. If you have access to spatial location data for each round, place the CSV files in the `location` subdirectory of the Afrobarometer and name them `Locations_R1.csv`, `Locations_R2.csv`, etc. For example, if you have spatial information for rounds 3 and 4, your Afrobarometer data directory should look like this after running `afrb_dir`:

    .
    ├── locations
    │   ├── Locations_R3.csv
    │   └── Locations_R4.csv
    ├── questionnaires
    └── afrobarometer.sqlite

    2 directories, 3 files

Build the database locally

``` r
afrb_build(rounds = c(3, 4), overwrite_db = TRUE)
```

Pull the merged Round 3 data into R

``` r
r3 <- afrb_round(3)
```

Notes

1.  Column names are converted to lowercase on import.

Citation
--------

This package simply structures the Afrobarometer data for analysis. Any use of the Afrobarometer data must comply with it's [Data Usage and Access Policy](http://www.afrobarometer.org/data/data-use-policy). The data is protected by copywright and the authors request the following citation for any use of either the open or restricted data:

    Afrobarometer Data, [Country(ies)], [Round(s)], [Year(s)], available at http://www.afrobarometer.org

TODO
----

-   \[ \] Package tests
-   \[ \] Download codebooks
-   \[ \] Discuss merging details
