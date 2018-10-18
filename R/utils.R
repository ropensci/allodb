#' Use updated data.
#'
#' Quick way to do all of this:
#' * Update exported data.
#' * Document to refresh help files showing data structure.
#' * Build and re-install.
#' * Build site.
#'
#' @keywords inernal
#' @noRd
use_updated_data <- function() {
  source(here::here("data-raw/data.R"))
  devtools::document()
  devtools::build()
  devtools::install()
  pkgdown::build_site()
}
