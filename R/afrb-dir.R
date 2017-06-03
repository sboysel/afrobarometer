#' Set the Afrobarometer data directory
#'
#' Customize where the data is cached.  Must be run explicitly by the user.
#'
#' @param path Character scalar containing the file path to set. Run
#' \code{afrb_dir()} without any paramters to use \code{base::tempdir()}.
#' @return Sets the afrobarometer data directory and database file invisibly.
#'
#' @details Sets the options \code{afrobarometer.data} and
#' \code{afrobarometer.sqlite}, the paths of the local Afrobarometer data cache
#' and SQLite database respectively.  The questionnaire data will be
#' automatically downloaded into the subdirectory \code{questionnaires}.  The
#' user is expected to manually add spatial data CSV files in the format
#' \code{locations/Location_Rk.csv} where \code{locations} is a subdirectory of
#' the Afrobrometer data folder, \code{afrobarometer.data}.  \code{afrb_dir()}
#' automatically creates \code{locations}, so the user simply has to place the
#' spatial data CSVs in the \code{locations} subdirectory after running
#' \code{afrb_dir()}.
#'
#' @examples
#'
#' library(afrobarometer)
#' afrb_dir("~/foo")
#'
#' @export
afrb_dir <- function(path = tempdir()) {

  path <- normalizePath(path)

  op <- options()
  op.afrobarometer <- list(
    afrobarometer.data = path
  )
  toset <- !(names(op.afrobarometer) %in% names(op))

  message(paste("[afrb] Setting options(afrobarometer.data) to", path))
  message(paste("[afrb] Spatial data should be placed in the `locations`",
                "subdirectory of the Afrobarometer data directory.",
                "For example, if you have spatial data for Rounds 3",
                "and 4, you should place the spatial data as follows:"))
  message("[afrb]")
  message(paste("[afrb]", file.path(path, "locations/Locations_R3.csv")))
  message(paste("[afrb]", file.path(path, "locations/Locations_R4.csv")))
  message("[afrb]")
  message(paste("[afrb] To change the data directory to file path x, use",
                "afrobarometer::afrb_dir(x)"))

  if (any(toset)) options(op.afrobarometer[toset])

  make_data_dir(path)

  invisible(getOption("afrobarometer.data"))

}

#' @keywords internal
make_data_dir <- function(path) {

  path <- normalizePath(path)

  message("[afrb] Creating directories")
  lapply(
    c(path, file.path(path, c("questionnaires", "locations", "codebooks"))),
    function(x) {
      if (dir.exists(x)) {
        message(paste("[afrb] -", x, "(exists)"))
      } else {
        message(paste("[afrb] -", x, "(created)"))
      }
      invisible(dir.create(x, showWarnings = FALSE, recursive = TRUE))
    }
  )

  invisible(path)

}
