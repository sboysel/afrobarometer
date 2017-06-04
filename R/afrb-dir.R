#' Set the Afrobarometer data directory
#'
#' Initialize the Afrobarometer data directory for the session.
#'
#' @param path a string containing the file path to set as the Afrobarometer data directory
#' \code{getOptions("afrobarometer.data")}). Run \code{afrb_dir()} without any parameters
#' to use \code{path = base::tempdir()}.
#' @return Sets the Afrobarometer data directory and invisibly returns the path
#' to the directory as a string.
#'
#' @details Sets the options the Afrobarometer data directory: \code{afrobarometer.data}.
#' This directory is where raw and merged data is cached across sessions. \code{afrb_dir(path)}
#' creates the following subdirectories:
#' \itemize{
#' \item{codebooks}{Codebooks (PDF) for each round are downloaded and stored in \code{path/codebooks}.}
#' \item{locations}{Afrobarometer restricted access georeferenced data (CSV) should be stored in
#'       \code{path/locations}. The user is expected to manually place each CSV file of georeferenced
#'       data in \code{locations} like \code{path/locations/Location_R*.csv}.}
#' \item{questionnaires}{Afrobarometer survey questionnaires (SAS) are downloaded and stored in \code{path/questionnaires}.}
#' }
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
