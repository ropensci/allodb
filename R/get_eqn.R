#' Get default equations of each type.
#'
#' @param dbh_species A dataframe as those created with [census_species()].
#'
#' @return A nested dataframe with each row containing the data of an equation
#'   type.
#' @export
#'
#' @examples
#' dbh_species <- census_species(dbh_sp, species, site)
#' get_eqn(dbh_species)
get_eqn <- function(dbh_species) {
  default_eqn <- allodb::default_eqn
  type_data <- default_eqn %>%
    dplyr::filter(!is.na(.data$eqn_type)) %>%
    dplyr::group_by(.data$eqn_type) %>%
    tidyr::nest() %>%
    dplyr::mutate(data = purrr::map(data, ~get_this_eqn(.x, dbh_species)))

  add_eqn_type(type_data)
}

get_this_eqn <- function(.type, dbh_species) {
  dplyr::inner_join(dbh_species, .type, by = c("sp", "site")) %>%
    dplyr::filter(!is.na(.data$dbh), !is.na(.data$eqn))
}

add_eqn_type <- function(type_data) {
  types <- type_data$eqn_type
  dplyr::mutate(
    type_data,
    data = purrr::map2(data, types, ~tibble::add_column(.x, eqn_type = .y))
  )
}
