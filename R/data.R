#' List of EPHT measures
#'
#' List of content areas, indicators, and measures and their associated IDs
#' from the CDC Tracking API.
#'
#' @format A data frame with 674 rows and 9 variables:
#' \describe{
#'   \item{measure_ID}{measure unique identifier}
#'   \item{measure_name}{full measure name}
#'   \item{measure_shortName}{short measure name}
#'   \item{indicator_ID}{indicator unique identifier}
#'   \item{indicator_name}{full indicator name}
#'   \item{indicator_shortName}{short indicator name}
#'   \item{content_area_ID}{content area unique identifier}
#'   \item{content_area_name}{full content area name}
#'   \item{content_area_shortName}{short content area name}
#'   ...
#' }
#' @source \url{https://ephtracking.cdc.gov/}
"measures_indicators_CAs"