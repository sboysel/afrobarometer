#' Build a local copy of the Afrobarometer database
#'
#' Automates the downloading and merging of the Afrobarometer data.  Fetches
#' any missing, publicly available files, creates a master SQLite database in
#' \code{options(afrobarometer.data)}, and merges available spatial data with
#' the questionnaires for each round.
#'
#' @param rounds A sequence of integers indicating which rounds to build.  As
#' of February 2017, there are six rounds.  Default is \code{seq(1: 6)}.
#' @param overwrite_db A boolean value indicating whether or not the SQLite
#' database in the local Afrobarometer data directory should be overwritten 
#' when \code{afrb_build} is run.  Default is \code{FALSE}.
#' @return Builds the database in \code{options("afrobarometer.data")},
#' downloading files as needed into subdirectories and merging the resulting
#' data in the SQLite database file \code{options("afrobarometer.sqlite")}.
#'
#' @details Meant to be run after \code{afrb_dir()} and before
#' \code{afrb_round}.
#'
#' @examples
#' \dontrun{
#' library(afrobarometer)
#' afrb_dir("~/foo")
#' # download first 3 rounds but do not overwrite the existing database file.
#' # This will fail if the database file has tables.
#' afrobarometer::afrb_build(1:3)
#' # download all rounds and overwrite the existing database file.
#' afrobarometer::afrb_build(overwrite_db = TRUE)
#' }
#'
#' @seealso \code{\link{afrb_dir}}
#'
#' @export
afrb_build <- function(rounds = 1:6, overwrite_db = FALSE) {

  if (is.null(getOption("afrobarometer.data"))) {
    stop(paste("Afrobarometer data directory has not been set, please run",
               "`afrb_dir` before `afrb_build`.  To set the data directory",
               "to `~/foo`, run `afrb_dir('~/foo')`.  To set the data",
               "directory to a temporary directory, run `afrb_dir()`."))
  }

  afrb.db <- make_sqlite_db(overwrite_db)

  afrb.urls <- c(
    "http://afrobarometer.org/sites/default/files/data/round-1/merged_r1_data.sav",
    "http://afrobarometer.org/sites/default/files/data/round-2/merged_r2_data.sav",
    "http://afrobarometer.org/sites/default/files/data/round-3/merged_r3_data.sav",
    "http://afrobarometer.org/sites/default/files/data/round-4/merged_r4_data.sav",
    "http://afrobarometer.org/sites/default/files/data/round-5/merged-round-5-data-34-countries-2011-2013-last-update-july-2015.sav",
    "http://afrobarometer.org/sites/default/files/data/round-6/merged_r6_data_2016_36countries2.sav"
  )

  message("Build Afrobarometer database")

  lapply(rounds, function(x) {

    message(paste("Round", x, "Questionnaire"))
  
    fp <- file.path(
      getOption("afrobarometer.data"),
      "questionnaires",
      basename(afrb.urls[x])
    )

    if (!file.exists(fp)) {
      message(" - Downloading")
      downloader::download(url = afrb.urls[x], destfile = fp)
    }
    message(" - Read")
    survey <- haven::read_sav(file = fp)
    message(" - Transform")

    # Hotfix for bad colnames
    names(survey) <- gsub("\\$", "", tolower(names(survey))) 

    survey <- haven::as_factor(survey)
    survey <- dplyr::mutate_if(survey, is.factor, as.character)
    survey <- dplyr::mutate(survey, round = x)
    survey <- dplyr::arrange(survey, respno)

    fp <- file.path(
      getOption("afrobarometer.data"),
      "locations",
      paste0("Locations_R", x, ".csv")
    )

    if (file.exists(fp)) {
      message(paste("Round", x, "Locations"))
      message(" - Read")
      loc <- readr::read_csv(file = fp)

      # Not really necessary to make the data spatial at this point
      #
      message(" - Transform")
      names(loc) <- tolower(names(loc))
      loc <- dplyr::select(loc, respno, latitude, longitude)
      loc <- dplyr::arrange(loc, respno)

      # loc <- sf::st_as_sf(
      #          loc,
      #          coords = c("longitude", "latitude"),
      #          remove = FALSE
      # )
      # sf::st_crs(loc) <- sf::st_crs(
      #   "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
      # )
      # sf::st_geometry(survey) <- NULL

      message(paste("Round", x, "Merge"))

      survey <- dplyr::left_join(
        x = loc,
        y = survey,
        by = "respno"
      )
      # survey %>% dplyr::filter(is.na(latitude)) %>% dplyr::distinct(country)

    }
    ## (3) Merge
    message(paste("Round", x, "Write to disk"))
    invisible(dplyr::copy_to(
      dest = afrb.db,
      df = survey,
      name = paste0("R", x),
      temporary = FALSE
    ))

    invisible()
  })

  message("Local Afrobarometer database complete!")
  message(paste("Use afrobarometer::round(x) to load a local data.frame",
                " of merged data for Round x."))

}
