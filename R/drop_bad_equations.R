#' Pick equations from __allodb__.
#'
#' From all equations in __allodb__, pick equations for a given site and
#' specificity.
#'
#' @param site_species Dataframe. The species table of a ForestGEO site.
#' @param specificity String to match values from
#'   `allodb::equations$allometry_specificity`.
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' pick_equations(allodb::scbi_species, "species")
pick_equations <- function(site_species, specificity) {
  allodb::master() %>%
    drop_bad_equations() %>%
    add_sp(site_species = allodb::scbi_species) %>%
    pick_specificity("species")
}

pick_specificity <- function(.data, specificity) {
  .specificity <- tolower(specificity)
  check_specificity(.data, .specificity)

  .data %>%
    dplyr::mutate(allometry_specificity = tolower(allometry_specificity)) %>%
    dplyr::filter(allometry_specificity %in% .specificity)
}

check_specificity <- function(.data, .specificity) {
  check_crucial_names(.data, "allometry_specificity")

  valid <- tolower(na.omit(unique(.data$allometry_specificity)))
  if (!any(.specificity %in% valid)) {
    valid_values <- glue::glue_collapse(
      rlang::expr_label(valid),
      sep = ", ", last = " or "
    )

    abort(glue("`specificity` must be one of {valid_values}"))
  }

  invisible(.data)
}

add_sp <- function(.data, site_species = allodb::scbi_species) {
  species_codes <- dplyr::select(site_species, .data$Latin, .data$sp)
  dplyr::left_join(.data, species_codes, by = c("species" = "Latin"))
}



#' Add the column `equation_allometry` to a census dataframe.
#'
#' @param census A ForestGEO-like census dataframe, with columns `sp` `dbh`.
#' @param equations A dataframe with columns `sp` and `equation_allometry`.
#' @param .f A `dplyr::*_join()` function -- e.g. [dplyr::left_join()]
#'   [dplyr::full_join()] [dplyr::inner_join()] (default).
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' equations <- pick_equations(allodb::scbi_species, "species")
#' add_equation(census = allodb::scbi_tree1, equations)
add_equation <- function(census, equations, .f = dplyr::inner_join) {
  check_crucial_names(census, c("sp", "dbh"))

  crucial_eqn <- c("sp", "equation_allometry")
  check_crucial_names(equations, crucial_eqn)

  .f(census, equations[crucial_eqn])
}



#' Add column `biomass`, by evaluating `equation_allomerty` for each `dbh`.
#'
#' @param .data A dataframe with columns `equation_allometry` and `dbh`.
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' equations <- pick_equations(allodb::scbi_species, "species")
#'
#' allodb::scbi_tree1 %>%
#'   add_equation(equations) %>%
#'   # Just a few for speed
#'   head() %>%
#'   add_biomass()
add_biomass <- function(.data) {
  check_crucial_names(.data, c("equation_allometry"))

  biomass <- purrr::map2_dbl(
    .data$equation_allometry, .data$dbh,
    ~eval(parse(text = .x), envir = list(dbh = .y))
  )
  tibble::add_column(.data, biomass)
}



#' Drop rows known to contain problematic equations.
#'
#' @param .data An __allodb__ dataframe with the variable `equation_id`.
#'
#' @return A dataframe.
#' @export
#'
#' @keywords internal

#' @examples
#' drop_bad_equations(master())
drop_bad_equations <- function(.data) {
  if (utils::hasName(.data, "equation_id"))
    return(dplyr::filter(.data, ! .data$equation_id %in% bad_eqn_id))

  col_nms <- glue::glue_collapse(
    rlang::expr_label(names(.data)), sep = ', ', last = ' and '
  )
  rlang::abort(glue::glue("
    `.data` must have the column `equation_id`
    Columns found:
    {col_nms}.
  "))
}
