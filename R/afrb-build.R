#' Build a local copy of the Afrobarometer database
#'
#' Automates the downloading and merging of the Afrobarometer data.  Fetches
#' any missing, publicly available files, creates a master MonetDB database in
#' \code{options(afrobarometer.data)}, and merges available spatial data with
#' the questionnaires for each round.
#'
#' @param rounds A sequence of integers indicating which rounds to build.  As
#' of February 2017, there are six rounds.  Default is \code{seq(1, 6)}.
#' @param overwrite_db A boolean value indicating whether or not the SQLite
#' database in the local Afrobarometer data directory should be overwritten
#' when \code{afrb_build} is run.  Default is \code{FALSE}.
#' @return Builds the database in \code{options("afrobarometer.data")},
#' downloading files as needed into subdirectories and merging the resulting
#' data in the SQLite database file \code{options("afrobarometer.sqlite")}.
#'
#' @details Meant to be run between \code{afrb_dir} and \code{afrb_round}.
#'
#' @examples
#' \dontrun{
#' library(afrobarometer)
#' afrb_dir(path = "~/foo")
#' # download first 3 rounds but do not overwrite the existing database.
#' # This will fail if the database is already populated with merged tables.
#' afrb_build(rounds = 3:4)
#' # download all rounds and overwrite the existing database.
#' afrb_build(rounds = 3:4, overwrite_db = TRUE)
#' }
#'
#' @seealso \code{\link{afrb_dir}}
#'
#' @export
afrb_build <- function(rounds = 1:6, overwrite_db = FALSE) {

  if (is.null(getOption("afrobarometer.data"))) {
    stop(paste("[afrb] Afrobarometer data directory has not been set, please run",
               "`afrb_dir` before `afrb_build`.  To set the data directory",
               "to `~/foo`, run `afrb_dir('~/foo')`.  To set the data",
               "directory to a temporary directory, run `afrb_dir()`."))
  }

  if (!dir.exists(getOption("afrobarometer.data"))) {
    stop(paste("[afrb]", getOption("afrobarometer.data"), "does not exist.  Please run `afrb_dir(path)` to set the Afrobarometer data directory."))
  }

  afrb.db <- make_monetdb(overwrite = overwrite_db)

  afrb.urls <- c(
    "http://afrobarometer.org/sites/default/files/data/round-1/merged_r1_data.sav",
    "http://afrobarometer.org/sites/default/files/data/round-2/merged_r2_data.sav",
    "http://afrobarometer.org/sites/default/files/data/round-3/merged_r3_data.sav",
    "http://afrobarometer.org/sites/default/files/data/round-4/merged_r4_data.sav",
    "http://afrobarometer.org/sites/default/files/data/round-5/merged-round-5-data-34-countries-2011-2013-last-update-july-2015.sav",
    "http://afrobarometer.org/sites/default/files/data/round-6/merged_r6_data_2016_36countries2.sav"
  )

  afrb.cbs <- c(
    "http://afrobarometer.org/sites/default/files/data/round-1/merged_r1_codebook2.pdf",
    "http://afrobarometer.org/sites/default/files/data/round-2/merged_r2_codebook2.pdf",
    "http://afrobarometer.org/sites/default/files/data/round-3/merged_r3_codebook2_0.pdf",
    "http://afrobarometer.org/sites/default/files/data/round-4/merged_r4_codebook3.pdf",
    "http://afrobarometer.org/data/merged-round-5-codebook-34-countries-2011-2013-last-update-july-2015",
    "http://afrobarometer.org/data/merged-round-6-codebook-36-countries-2016"
  )

  message("[afrb] Build Afrobarometer database")

  lapply(rounds, function(x) {

    # x <- 4

    cb.fp <- file.path(
      getOption("afrobarometer.data"),
      "codebooks",
      basename(afrb.cbs[x])
    )

    if (!file.exists(cb.fp)) {
      message(paste("[afrb] Round", x, "Codebook"))

      message("[afrb] - Downloading")

      downloader::download(
        url = afrb.cbs[x],
        destfile = cb.fp
      )
    }

    message(paste("[afrb] Round", x, "Questionnaire"))

    fp.q <- file.path(
      getOption("afrobarometer.data"),
      "questionnaires",
      basename(afrb.urls[x])
    )

    if (!file.exists(fp.q)) {
      message("[afrb] - Downloading")
      downloader::download(url = afrb.urls[x], destfile = fp.q)
    }
    message("[afrb] - Read")
    survey <- haven::read_sav(file = fp.q)
    message("[afrb] - Transform")

    # Hotfix for bad colnames
    names(survey) <- gsub("\\$", "", tolower(names(survey)))

    survey <- haven::as_factor(survey)
    survey <- dplyr::mutate_all(survey, as.character)
    survey <- dplyr::mutate(survey, round = x)

    # arrange by respondent number, if present
    if ("respno" %in% names(survey)) {
      survey <- dplyr::arrange_(survey, .dots = c("respno"))
    }

    fp.l <- file.path(
      getOption("afrobarometer.data"),
      "locations",
      paste0("Locations_R", x, ".csv")
    )

    if (file.exists(fp.l)) {
      message(paste("[afrb] Round", x, "Locations"))
      message("[afrb] - Read")
      loc <- readr::read_csv(
        file = fp.l,
        col_types = readr::cols(
          respno = readr::col_character(),
          district = readr::col_character(),
          townvill = readr::col_character(),
          eanumb = readr::col_character(),
          country = readr::col_character(),
          region = readr::col_character(),
          latitude = readr::col_double(),
          longitude = readr::col_double()
        ),
        progress = TRUE
      )

      # Not really necessary to make the data spatial at this point
      #
      message("[afrb] - Transform")
      names(loc) <- tolower(names(loc))
      loc <- dplyr::select_(loc, .dots = c("respno", "latitude", "longitude"))
      loc <- dplyr::arrange_(loc, .dots = c("respno"))

      message(paste("[afrb] Round", x, "Merge"))

      survey <- dplyr::left_join(
        x = loc,
        y = survey,
        by = "respno"
      )

    }

    ## (3) Merge
    message(paste("[afrb] Round", x, "Write to disk"))

    DBI::dbWriteTable(afrb.db, paste0("afrobarometer_round_", x), survey)

    invisible()
  })

  message("[afrb] Local Afrobarometer database complete!")
  message(paste("[afrb] Use afrobarometer::round(x) to load a local data.frame",
                " of merged data for Round x."))

}

#' @keywords internal
make_monetdb <- function(overwrite = FALSE) {

  if (overwrite) rm_monetdb()

  dbdir <- file.path(getOption("afrobarometer.data"), "monetdblite")

  if (overwrite) {
    message(paste("[afrb] Creating database:", dbdir))
  } else {
    message(paste("[afrb] Connecting to database:", dbdir))
  }

  DBI::dbConnect(MonetDBLite::MonetDBLite(), dbdir)

}

#' @keywords internal
rm_monetdb <- function() {

  stopifnot(!identical(getOption("afrobarometer.data"), ""))

  dbdir <- file.path(getOption("afrobarometer.data"), "monetdblite")

  if (dir.exists(dbdir)) {
    message(paste("[afrb] Deleting database:", dbdir))
    unlink(dbdir, recursive = TRUE)
  } else {
    message(paste("[afrb] Database does not exist, nothing deleted:", dbdir))
  }

}
