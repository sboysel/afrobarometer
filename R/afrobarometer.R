#' afrobarometer: Load the Merged Afrobarometer Survey Data
#'
#' The afrobarometer package automates downloading and merging the
#' Afrobarometer Survey Data into the R workspace.  
#"
#' @section Afrobarometer functions:
#' There are three exported functions of the afrobarometer package:
#' \describe{
#'   \item{afrb_dir(path)}{Sets the Afrobarometer data directory to
#'   \code{path}.}
#'   \item{afrb_build(rounds, overwrite_db)}{After running \code{afrb_dir}, the
#'   function \code{afrb_build} constructs the local database for the surveys
#'   specified in \code{rounds}.  If \code{overwrite_db} is set to \code{TRUE},
#'   the existing database file is overwritten.}
#'   \item{afrb_round(round)}{Extracts merged data for Round \code{code} from
#'   the loceal SQLite database into a \code{tibble} in \code{R}.}
#' }
#' Open access data is downloaded if needed.  The user is expected to manually 
#' set the optional restricted access data in the \code{locations} subdirectory
#' of the Afrobarometer data directory, \code{getOption("afrobarometer.data")}, 
#' such as spatial locations of survey respondents.
#'
#' @docType package
#' @name afrobarometer
NULL
