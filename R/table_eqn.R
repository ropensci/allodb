
# Aim to replace all of the above ----

#' Table allometric equations.
#'
#' Use these functions to create tables of allometric equations by site,
#' species, and stem.
#'
#' @param x A dataframe, usually a ForestGEO-table.
#' @param eqn Name of the variable in `x` giving allometric equations.
#' @param sp Name of the variable in `x` species names.
#' @param stemid Name of the variable in `x` that uniquely identifies each stem.
#' @param dbh Name of the variable in `x` giving stem diameter.
#' @param site Character string giving the name of the site.
#' @param eqn_type One of stem, species or site.
#' @param source One of "user" or "default". Use "user" always, except
#'   if you are a developer of __allodb__ and you are creating default tables
#'   for ForestGEO.
#'
#' @return A dataframe.
#' @export
#' @examples
#' x <- tibble::tribble(~sp, ~equation, ~id, ~dbh,
#'                    "sp1",        NA, 200,   33,
#'                    "sp2", "3 * dbh", 111,   40,
#'                    "sp3", "7 * dbh", 221,   15,
#'                    "sp4", "5 * dbh", 332,   40)
#' x
#'
#' table_eqn(x = x, eqn = "equation", sp = "sp", dbh = "dbh", site = "bci",
#'   eqn_type = "stem")
#'
#' table_eqn(x = x, eqn = "equation", sp = "sp", dbh = "dbh", site = "bci",
#'   eqn_type = "species")
#'
#' table_eqn(x = x, eqn = "equation", sp = "sp", dbh = "dbh", site = "bci",
#'   eqn_type = "site")
table_eqn <- function(x,
                      eqn,
                      sp,
                      dbh,
                      site = "my_site",
                      eqn_type = c("site", "species", "stem"),
                      source = c("user", "default")) {
  stopifnot(eqn_type %in%  c("site", "species", "stem"))
  eqn_type <- eqn_type[[1]]
  stopifnot(source %in% c("user", "default"))
  source <- source[[1]]

  x$eqn <- x[[eqn]]
  x$sp <- x[[sp]]
  x$dbh <- x[[dbh]]
  site <- tibble::tibble(eqn = x$eqn, eqn_type = eqn_type, source = source, site = site)

  table_eqn <- dplyr::bind_cols(site, dplyr::select(x, sp, dbh))
  # Match na between eqn and eqn_type
  mutate(table_eqn, eqn_type = ifelse(is.na(eqn), NA, eqn_type))
}

#' Combine multiple tables of allometric equations.
#'
#' @param ... One or multiple tables of allometric equations.
#' @seealso table_equations
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' x <- tibble::tribble(~sp, ~equation, ~id, ~dbh,
#'                    "sp1",        NA, 200,   33,
#'                    "sp2", "3 * dbh", 111,   40,
#'                    "sp3", "7 * dbh", 221,   15,
#'                    "sp4", "5 * dbh", 332,   40)
#' x
#'
#' stem <- table_eqn(x = x, eqn = "equation", sp = "sp", dbh = "dbh", site = "bci",
#'   eqn_type = "stem")
#'
#' sp <- table_eqn(x = x, eqn = "equation", sp = "sp", dbh = "dbh", site = "bci",
#'   eqn_type = "species")
#'
#' site <- table_eqn(x = x, eqn = "equation", sp = "sp", dbh = "dbh", site = "bci",
#'   eqn_type = "site")
#'
#' tibble_all_eqn(stem, site, sp)
combine_eqn <- function(...) {
  purrr::reduce(list(...), dplyr::bind_rows)
}
