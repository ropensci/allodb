#' Structure equaitons from __allodb__ as a __bmss__ default-equations table.
#'
#' @param .data An object of class 'allodb_eqn' built with [allodb::master()].
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' bmss_default_eqn()
bmss_default_eqn <- function(.data) {
  crucial <- c("site", "species", "equation_allometry", "allometry_specificity")
  check_crucial_names(.data, crucial)

  good <- .data[!.data$equation_id %in% .bad_eqn_id , crucial]
  good %>%
    dplyr::mutate(
      eqn_source = "default",
      eqn = format_equations(good$equation_allometry),
      equation_allometry = NULL
    ) %>%
    dplyr::rename(
      sp = .data$species,
      eqn_type = .data$allometry_specificity
      ) %>%
    # Make it easier to find values (all lowercase)
    purrr::modify_if(is.character, tolower) %>%
    # Order
    dplyr::select(bmss_default_vars()) %>%
    unique()
}

bmss_default_vars <- function() c("site", "sp", "eqn", "eqn_source", "eqn_type")

format_equations <- function(eqn) {
  purrr::quietly(formatR::tidy_source)(text = eqn)$result$text.tidy
}
