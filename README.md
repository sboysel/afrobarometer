<!-- README.md is generated from README.Rmd. Please edit that file -->
`afrobarometer`: Load Afrobarometer Data into R
===============================================

The `afrobarometer` automates laoding Afrobarometer Survey data into the R environment. Open access data is downloaded as needed. The user supplies any optional restricted access data (i.e. survey respondents georeferenced by sampling unit). Merged data is cached in the Afrobarometer data directory and read into R as a local `data.frame`.

-   [Data](http://www.afrobarometer.org/data)
-   [Data usage policy](http://www.afrobarometer.org/data/data-use-policy)

Install
-------

Install `afrobarometer` package

``` r
devtools::install_github("sboysel/afrobarometer")
```

Note that the following packages must be installed. It may be required that some system software packages need to be installed outside of R.

| R package | Dependencies |
|-----------|--------------|
| `rgdal`   | `gdal`       |
| `rgeos`   | `geos`       |

Required Data
-------------

-   Open access data: individual responses to survey questionnaires.
-   Restricted access data (optional): spatial locations, recently administered rounds.

The `afrobarometer` package fetches any public access data necessary and merges the available spatial data with the questionnaire data. If spatial data is not provided for a specific round, the final table is simply the questionnaire data.

Usage
-----

``` r
library(afrobarometer)
afrb_dir(path = "~/Dropbox/dataset/Afrobarometer")
```

`afrb_dir` sets the local cache directory to `path`, creating subdirectories and the local database file as needed. If you have access to spatial location data for each round, place the CSV files in the `location` subdirectory of the Afrobarometer and name them `Locations_R1.csv`, `Locations_R2.csv`, etc. For example, if you have spatial information for rounds 3 and 4, your Afrobarometer data directory should look like this after running `afrb_dir`:

    .
    ├── locations
    │   ├── Locations_R3.csv
    │   └── Locations_R4.csv
    ├── questionnaires
    └── codebooks

    3 directories, 2 files

Build the database locally

``` r
afrb_build(rounds = c(3, 4), overwrite_db = TRUE)
```

Pull the merged Round 3 data into R

``` r
r3 <- afrb_round(round = 3)
```

Notes
-----

1.  Column names are converted to lowercase on import.
2.  As of now, the only variables kepted from the the location files (i.e. Afrobarometer georeferenced data) are the respondent number, latitude, and longitude of the respondent (i.e. respondent's cluster). These variables are then merged with the full questionnaire by respondent number.

Citation
--------

This package simply structures the Afrobarometer data for analysis. Any use of the Afrobarometer data must comply with it's [Data Usage and Access Policy](http://www.afrobarometer.org/data/data-use-policy). The data is protected by copywright and the authors request the following citation for any use of either the open or restricted data:

    Afrobarometer Data, [Country(ies)], [Round(s)], [Year(s)], available at http://www.afrobarometer.org

TODO
----

-   \[ \] Package tests
-   \[x\] Download codebooks
-   \[x\] Discuss merging details: take lat + long + respno
-   \[x\] Switch to MonetDB
-   \[ \] Merge on disk
-   \[ \] Merge multiple rounds together (Inter-round question correspondence, if possible)
