#' Join allodb tables: `equations`, `sitespecies`, and `sites_info`.
#'
#' * `master()` has all column types set as characters to preserve different
#' kinds of missing values.
#' * `master_tidy()` has column types and missing optimized for computation.
#'
#' @seealso [dplyr::full_join()].
#' @family functions to interact with the database
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' library(dplyr)
#' library(purrr)
#'
#' master()
#'
#' # Columns are of type "character"
#' master() %>%
#'   purrr::map_chr(typeof) %>%
#'   unique()
#'
#' # This preserves preserve different kinds of NAs
#' unique(grep("N", master()$dbh_min_cm, value = TRUE))
#' allodb::missing_values_metadata
#'
#' # For computation, use `master_tidy()`, which has column types and missing
#' # values already optimized for computation on the data
#' master_tidy() %>%
#'   map_chr(typeof) %>%
#'   unique()
master <- function() {
  message(
    "Joining `equations` and `sitespecies` by 'equation_id'; ",
    "then `sites_info` by 'site'."
  )

  suppressMessages({
    eqn_site <- dplyr::left_join(
      allodb::equations,
      allodb::sitespecies,
      by = "equation_id"
    )

    out <- dplyr::left_join(
      lowercase_site(eqn_site),
      lowercase_site(allodb::sites_info),
      by = "site"
    )
  })

  out
}

#' @rdname master
#' @export
master_tidy <- function() {
  data <- set_type(master())
  data$dbh_min_cm <- replace_missing(data$dbh_min_cm, 0)
  data$dbh_max_cm <- replace_missing(data$dbh_max_cm, Inf)
  data
}

lowercase_site <- function(data) {
  data$site <- tolower(data$site)
  data
}

replace_missing <- function(x, replace) {
  x[is.na(x)] <- replace
  x
}
