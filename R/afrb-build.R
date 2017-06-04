#' Build a local copy of the Afrobarometer database
#'
#' Automates the downloading and merging of the Afrobarometer data.  Fetches
#' any missing, publicly available files, creates a master MonetDB database in
#' \code{options(afrobarometer.data)}, and merges available spatial data with
#' the questionnaires for each round.
#'
#' @param rounds A vector of integers indicating which rounds to build.  Default
#' is value \code{1:6}.
#' @param overwrite A boolean value indicating whether or not the SQLite
#' database in the local Afrobarometer data directory should be overwritten
#' when \code{afrb_build} is run.  Default is \code{FALSE}.
#' @return Builds the database in \code{options("afrobarometer.data")},
#' downloading files as needed into sub-directories and merging the resulting
#' data \code{file.path(options("afrobarometer.data"), "build")}.
#'
#' @details May only run \code{afrb_round} after \code{afrb_dir} and before
#' \code{afrb_round}.
#'
#' @examples
#' \dontrun{
#' library(afrobarometer)
#' afrb_dir(path = "~/foo")
#' # download first 3 rounds but do not overwrite the existing database.
#' # This will fail if the database is already populated with merged tables.
#' afrb_build(rounds = 3:4)
#' # download all rounds and overwrite the existing database.
#' afrb_build(rounds = 3:4, overwrite = TRUE)
#' r3 <- afrb_round(round = 3)
#' }
#'
#' @seealso \code{\link{afrb_dir}}
#'
#' @export
afrb_build <- function(rounds = 1:6, overwrite = FALSE) {

  if (is.null(getOption("afrobarometer.data"))) {
    stop(paste("[afrb] Afrobarometer data directory has not been set, please run",
               "`afrb_dir` before `afrb_build`.  To set the data directory",
               "to `~/foo`, run `afrb_dir('~/foo')`.  To set the data",
               "directory to a temporary directory, run `afrb_dir()`."))
  }

  if (!dir.exists(getOption("afrobarometer.data"))) {
    stop(paste("[afrb]", getOption("afrobarometer.data"), "does not exist.  Please run `afrb_dir(path)` to set the Afrobarometer data directory."))
  }

  afrb_build_dir <- file.path(getOption("afrobarometer.data"), "build")

  if (length(afrb_list_rounds()) > 0) {

    if (overwrite) {

      message(paste("[afrb] Deleting", afrb_build_dir))
      unlink(x = afrb_build_dir, recursive = TRUE)
      dir.create(path = afrb_build_dir, recursive = TRUE, showWarnings = FALSE)

    } else {
      stop(paste("[afrb]", afrb_build_dir, "exists and is non-empty.  Please run `afrb_round(round)` to load the merged data."))
    }
  }

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

    message(paste("[afrb] Round", x))

    cb.fp <- file.path(
      getOption("afrobarometer.data"),
      "codebooks",
      basename(afrb.cbs[x])
    )

    if (!file.exists(cb.fp)) {
      message("[afrb] .. Codebook")

      message("[afrb] .... Downloading")

      downloader::download(
        url = afrb.cbs[x],
        destfile = cb.fp
      )
    }

    message("[afrb] .. Questionnaire")

    fp.q <- file.path(
      getOption("afrobarometer.data"),
      "questionnaires",
      basename(afrb.urls[x])
    )

    if (!file.exists(fp.q)) {
      message("[afrb] .... Downloading")
      downloader::download(url = afrb.urls[x], destfile = fp.q)
    }
    message("[afrb] .... Read")
    survey <- haven::read_sav(file = fp.q)
    message("[afrb] .... Transform")

    # Hotfix for bad colnames
    names(survey) <- gsub("\\$", "", tolower(names(survey)))

    survey <- haven::as_factor(survey)
    survey <- dplyr::mutate_all(survey, as.character)
    survey <- dplyr::mutate(survey, round = x)

    afrb_build_dir <- file.path(getOption("afrobarometer.data"), "build")

    if (!dir.exists(afrb_build_dir)) {
      dir.create(path = afrb_build_dir)
    }

    afrb_fp <- file.path(afrb_build_dir, paste0("afrb_", x, ".rds"))

    if ("respno" %in% names(survey)) {
      survey <- dplyr::arrange_(survey, .dots = c("respno"))
    }

    fp.l <- file.path(
      getOption("afrobarometer.data"),
      "locations",
      paste0("Locations_R", x, ".csv")
    )

    if (file.exists(fp.l)) {

      message("[afrb] .. Locations")

      message("[afrb] .... Read")
      loc <- readr::read_csv(
        file = fp.l,
        col_types = readr::cols(
          latitude = readr::col_double(),
          longitude = readr::col_double()
        ),
        progress = TRUE
      )

      message("[afrb] .... Transform")
      names(loc) <- tolower(names(loc))
      loc <- dplyr::select_(loc, .dots = c("respno", "latitude", "longitude"))
      loc <- dplyr::arrange_(loc, .dots = c("respno"))

      message("[afrb] .... Merge with questionnaire")

      afrb <- dplyr::left_join(
        x = survey,
        y = loc,
        by = "respno"
      )

      message("[afrb] .... Write to database")
      readr::write_rds(x = afrb, path = afrb_fp, compress = "gz")

    } else {

      message("[afrb] .... Write to database")
      readr::write_rds(x = survey, path = afrb_fp, compress = "gz")

    }

    invisible()

  })

  message("[afrb] Local Afrobarometer database complete!")
  message(paste("[afrb] Use afrb_round(x) to load a local data.frame",
                " of merged data for Round x."))

}
