#' Calculate biomass.
#'
#' @param dbh_sp A dataframe created with [census_species()].
#' @param default_eqn A dataframe created with [as_default_eqn()].
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' dbh_sp <- census_species(scbi_tree1, scbi_species, site = "scbi")
#' default_eqn <- as_default_eqn(allodb::master())
#' bmss(dbh_sp, default_eqn)
bmss <- function(dbh_sp, default_eqn) {
  check_bmss(dbh_sp, default_eqn)

  eqn_dbh <- dbh_sp %>%
    bmss::get_allometry("site", "sp", "dbh", default_eqn = default_eqn) %>%
    dplyr::filter(stats::complete.cases(.))

  .biomass <- purrr::map2_dbl(
    eqn_dbh$eqn, eqn_dbh$dbh,
    ~eval(parse(text = .x), envir = list(dbh = .y))
  )
  dplyr::mutate(eqn_dbh, biomass = .biomass)
}

check_bmss <- function(dbh_sp, default_eqn) {
  if (!inherits(dbh_sp, "")) {
    inform("Did you use `()` to create `dbh_sp`?")
  }

  if (!inherits(default_eqn, "default_eqn")) {
    inform("Did you use `as_default_eqn()` to create `default_eqn`?")
  }

  invisible()
}
