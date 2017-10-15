#' Combine multiple tables of allometric equations.
#'
#' @param ... One or multiple tables of allometric equations.
#' @seealso table_equations
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' # Create equation's tables at different levels.
#'
#' by_site <- tibble_site_eqn(eqn = "3 * dbh", eqn_site = "bci")
#' by_site
#'
#' eqn_by_sp <- tibble::tribble(~sp, ~equation,
#'                           "sp1", "3 * dbh",
#'                           "sp2", "7 * dbh",
#'                           "sp3", "5 * dbh")
#' by_spp <- tibble_sp_eqn(x = eqn_by_sp, eqn = "equation", sp = "sp", eqn_site = "bci")
#' by_spp
#'
#' eqn_by_stem <- tibble::tribble(~sp,   ~equation,     ~id, ~dbh,
#'                               "sp1", "3 * dbh",     001,   40,
#'                               "sp1", "7 * dbh",     002,   15,
#'                               "sp1", "5 * dbh",     003,   40)
#' by_stem <- tibble_stem_eqn(x = eqn_by_stem, eqn = "equation", sp = "sp", stemid = "id",
#'  dbh = "dbh", eqn_site = "bci")
#' by_stem
#'
#' # Combine all tables.
#' tibble_all_eqn(by_site, by_spp, by_stem)
tibble_all_eqn <- function(...) {
  purrr::reduce(list(...), dplyr::bind_rows)
}
