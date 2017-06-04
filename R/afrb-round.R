#' Load data for an Afrobarometer Survey round as a local tibble
#'
#' After the local database has been built (\code{\link{afrb_build}}), \code{afrb_round}
#' reads data for the specified round into the workspace as a \code{data.frame}.
#'
#' @param round An integer of the round to select.  \code{round \%in\% 1:6} must be true
#' @return \code{afrb_round(x)} returns a \code{data.frame} for Round ]code{x}.  \code{afrb_list_rounds}
#' returns a character vector of file paths for built datasets from \code{\link{afrb_build}},
#' if any exist.
#'
#' @details \code{afrb_round} loads built data for round as a \code{data.frame}.  Assumes
#' \code{\link{afrb_build}} has been run.  \code{afrb_list_rounds} lists built datasets in the
#' Afrobarometer data directory, if any exist.
#'
#' @examples
#' \dontrun{
#' library(afrobarometer)
#' afrb_dir("~/foo")
#' afrb_build(rounds = 3, overwrite = TRUE)
#' r3 <- afrb_round(round = 3)
#' }
#'
#' @name afrb_round

#' @rdname afrb_round
#' @export
afrb_round <- function(round = NULL) {

  afrb_build_dir <- suppressWarnings(file.path(getOption("afrobarometer.data"), "build"))

  stopifnot(dir.exists(afrb_build_dir), length(dir(afrb_build_dir)) > 0, !is.null(round), round %in% 1:6)

  afrb_fp <- file.path(afrb_build_dir, paste0("afrb_", round, ".rds"))

  stopifnot(file.exists(afrb_fp))

  readr::read_rds(path = afrb_fp)

}

#' @rdname afrb_round
#' @export
afrb_list_rounds <- function() {

  afrb_build_dir <- suppressWarnings(file.path(getOption("afrobarometer.data"), "build"))

  stopifnot(dir.exists(afrb_build_dir))

  dir(path = afrb_build_dir, pattern = "afrb_[1-6]\\.rds", full.names = TRUE, include.dirs = FALSE)

}
