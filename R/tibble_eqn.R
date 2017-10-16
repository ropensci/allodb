#' Table allometric equations.
#'
#' Wrappers around [tibble_eqn()]. Use these functions to create tables of
#' allometric equations by site, species, and stem.
#'
#'
#' @param x A dataframe, usually a ForestGEO-table.
#' @param eqn Name of the variable in `x` giving allometric equations.
#' @param sp Name of the variable in `x` species names.
#' @param stemid Name of the variable in `x` that uniquely identifies each stem.
#' @param dbh Name of the variable in `x` giving stem diameter.
#' @param eqn_site Character string giving the name of the site.
#' @param eqn_source One of "user" or "default". Use "user" always, except
#'   if you are a developer of __allodb__ and you are creating default tables
#'   for ForestGEO.
#'
#' @return A dataframe.
#' @export
#'
#' @name table_equations
#'
#' @examples
#' # Enable a nice printing method.
#' library(tibble)
#'
#' # Wrapper by site
#'
#' tibble_site_eqn(eqn = "3 * dbh", eqn_site = "bci")
#'
#' # Wrapper by species
#'
#' # Your allometric equations by speces are likely in a table, e.g.:
#' eqn_by_sp <- tibble::tribble(~sp, ~equation,
#'                            "sp1", "3 * dbh",
#'                            "sp2", "7 * dbh",
#'                            "sp3", "5 * dbh")
#' eqn_by_sp
#'
#' # Give the names of the variables with the relevant information.
#' tibble_sp_eqn(x = eqn_by_sp, eqn = "equation", sp = "sp", eqn_site = "bci")
#'
#' # Wrapper by stem.
#'
#' eqn_by_stem <- tibble::tribble(~sp,   ~equation,     ~id, ~dbh,
#'                                "sp1", "3 * dbh",     001,   40,
#'                                "sp1", "7 * dbh",     002,   15,
#'                                "sp1", "5 * dbh",     003,   40)
#' eqn_by_stem
#'
#' # Give the names of the variables with the relevant information.
#' tibble_stem_eqn(x = eqn_by_stem, eqn = "equation", sp = "sp", stemid = "id",
#'   dbh = "dbh", eqn_site = "bci")

#' @rdname table_equations
#' @export
tibble_eqn <- function(eqn,
                       eqn_site,
                       eqn_type = c("site", "species", "stem"),
                       eqn_source = c("user", "default")) {
  stopifnot(eqn_type %in%  c("site", "species", "stem"))
  eqn_type <- eqn_type[[1]]
  eqn_source <- eqn_source[[1]]

  tibble::tibble(eqn, eqn_source, eqn_site, eqn_type)
}

#' @rdname table_equations
#' @export
tibble_site_eqn <- function(eqn, eqn_site, ...) {
  tibble_eqn(eqn = eqn, eqn_site = eqn_site, eqn_type = "site", ...)
}

#' @rdname table_equations
#' @export
tibble_sp_eqn <- function(x, eqn, sp, eqn_site, ...) {
  x$eqn <- x[[eqn]]
  x$sp <- x[[sp]]
  site <- tibble_eqn(eqn = x$eqn, eqn_site = eqn_site, eqn_type = "species", ...)
  dplyr::bind_cols(site, dplyr::select(x, sp))
}

#' @export
#' @rdname table_equations
tibble_stem_eqn <- function(x, eqn, sp, stemid, dbh, eqn_site, ...) {
  x$eqn <- x[[eqn]]
  x$sp <- x[[sp]]
  x$stemid <- x[[stemid]]
  x$dbh <- x[[dbh]]
  site <- tibble_eqn(eqn = x$eqn, eqn_site = eqn_site, eqn_type = "stem", ...)
  dplyr::bind_cols(site, dplyr::select(x, sp, stemid, dbh))
}







