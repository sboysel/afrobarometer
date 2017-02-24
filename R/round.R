#' Load data for an Afrobarometer Survey round as a local tibble
#'
#' After the local database has been build, this function reads data for the
#' specified round into R as a local tibble.
#'
#' @param round An integer of the round to select.  As of February 2017, there
#' is questionnaire data available for Rounds 1 through 6.
#' @return tbl A local tibble with data for the round.  If spatial data is
#' available for the round, then the objet returned by
#' \code{afrobarometer::afrb_round(x)} will be merged spatial and questionnaire
#' data for round \code{x}.
#'
#' @examples
#' \dontrun{
#' library(afrobarometer)
#' afrb_dir("~/foo")
#' afrb_build(overwrite = TRUE)
#' r3 <- afrb_round(3)
#' }
#' @export
afrb_round <- function(round) {

  afrb.db <- make_sqlite_db(overwrite = FALSE)

  tbl.lzy <- dplyr::tbl(afrb.db, paste0("R", round))

  dplyr::collect(tbl.lzy, n = Inf)

}
