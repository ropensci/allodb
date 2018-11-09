#' Evaluate equations, find duplicated ones, and pick a single row by `rowid`.
#'
#' @param .data A dataframe as those created with [pick_best_equations()].
#'
#' @return A dataframe with a single row by each value of `rowid`.
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' best <- allodb::scbi_tree1 %>%
#'   census_species(allodb::scbi_species, "scbi") %>%
#'   get_equations() %>%
#'   pick_best_equations()
#'
#' # Has duplicated rowid
#' find_duplicated_rowid(best)
#'
#' # NO duplicated rowid
#' pick_one_row_by_rowid(best)
#'
#' find_duplicated_rowid(pick_one_row_by_rowid(best))
evaluate_equations <- function(.data) {
  .biomass <- purrr::map2_dbl(
    .data$eqn, .data$dbh,
    ~eval(parse(text = .x), envir = list(dbh = .y))
  )
  dplyr::mutate(.data, biomass = .biomass)
}

#' @export
#' @rdname evaluate_equations
find_duplicated_rowid <- function(.data) {
  check_crucial_names(.data, c("sp", "site", "eqn", "equation_id"))

  .data %>%
    unique() %>%
    dplyr::add_count(.data$rowid, sort = TRUE) %>%
    dplyr::filter(.data$n > 1)
}

#' @export
#' @rdname evaluate_equations
pick_one_row_by_rowid <- function(.data) {
  .data %>%
    dplyr::group_by(.data$rowid) %>%
    dplyr::filter(dplyr::row_number() == 1L) %>%
    dplyr::ungroup()
}
