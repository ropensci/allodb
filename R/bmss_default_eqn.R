#' Structure equations from __allodb__ as a __bmss__ default-equations table.
#'
#' This function restructures an equations-table from __allodb__ with columns as
#' in [allodb_eqn_crucial()] (e.g. [allodb::master()]). It transforms its input
#' into a default-equations table for __bmss__. Now this function is very
#' strict and intrusive:
#' * It drops problematic equations that can't be evaluated.
#' * It adds and remove columns.
#' * It renames columns.
#' * It transforms text-values to lowercase to simplify matching.
#' * It formats equations using [formatR::tidy_source()].
#' * It drops missing values.
#' * It replaces spaces (" ") with underscore ("_") in values of
#' allometry_specificity for easier manipulation.
#'
#' @param .data [allodb::master()] or similar.
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' bmss_default_eqn(allodb::master())
bmss_default_eqn <- function(.data) {
  check_crucial_names(.data, allodb_eqn_crucial())

  good <- .data[!.data$equation_id %in% .bad_eqn_id , allodb_eqn_crucial()]
  good %>%
    dplyr::mutate(
      eqn_source = "default",
      eqn = format_equations(good$equation_allometry),
      allometry_specificity = gsub(" ", "_", .data$allometry_specificity),
      equation_allometry = NULL
    ) %>%
    dplyr::rename(
      sp = .data$species,
      eqn_type = .data$allometry_specificity
      ) %>%
    # Recover missing values represented as the literal "NA"
    purrr::modify_if(is.character, readr::parse_character) %>%
    # Make it easier to find values (all lowercase)
    purrr::modify_if(is.character, tolower) %>%
    # Order
    dplyr::select(bmss_default_vars()) %>%
    dplyr::filter(stats::complete.cases(.)) %>%
    unique() %>%
    dplyr::as_tibble() %>%
    new_bmss_default_eqn()
}

new_bmss_default_eqn <- function(x) {
  stopifnot(tibble::is.tibble(x))
  structure(x, class = c("bmss_default_eqn", class(x)))
}

bmss_default_vars <- function() {
  c("site", "sp", "eqn", "eqn_source", "eqn_type")
}

format_equations <- function(eqn) {
  purrr::quietly(formatR::tidy_source)(text = eqn)$result$text.tidy
}



#' Create a census table of the kind useful in __bmss__.
#'
#' @param census A ForestGEO-like census-dataframe.
#' @param species A ForestGEO-like species-dataframe.
#' @param site The name of the site. One of `allodb::sites_info$site`.
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' bmss_cns(allodb::scbi_tree1, allodb::scbi_species, site = "scbi")
bmss_cns <- function(census, species, site) {
  .census <- rlang::set_names(census, tolower)
  .species <- rlang::set_names(species, tolower)
  .site <- tolower(site)
  check_bms_cns(.census, .species, .site)

  all <- dplyr::left_join(.census, .species, by = "sp")
  all$sp <- tolower(all$latin)
  all$site <- .site
  out <- all[c("site", "sp", "dbh")]
  out <- tibble::rowid_to_column(out)
  new_bmss_cns(dplyr::as_tibble(out))
}

new_bmss_cns <- function(x) {
  stopifnot(tibble::is.tibble(x))
  structure(x, class = c("bmss_cns", class(x)))
}

check_bms_cns <- function(census, species, site) {
  stopifnot(
    is.data.frame(census),
    is.data.frame(species),
    is.character(site),
    length(site) == 1
  )
  check_crucial_names(census, c("sp", "dbh"))
  check_crucial_names(species, "sp")
}



#' Crucial columns form __allodb__ equations-table used by `bmss_default_eqn()`.
#'
#' @return A string.
#' @export
#'
#' @examples
#' allodb_eqn_crucial()
allodb_eqn_crucial <- function() {
  c("site", "species", "equation_allometry", "allometry_specificity")
}

