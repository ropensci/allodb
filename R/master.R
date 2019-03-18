#' Join the main allodb tables: `equations``, `sitespecies`, and `sites_info`.
#'
#' @param .f A function, form the __dplyr__ package, used to join tables (e.g.
#'   `dplyr::full_join()`).
#' @seealso [dplyr::full_join()].
#' @family functions to interact with the database
#'
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' # Defaults to use `dplyr::full_join()`
#' master()
#'
#' # But you can use other joins
#' master(.f = dplyr::left_join)
#' \dontrun{
#' # Nice view in RStudio
#' View(master())
#' }
master <- function(.f = dplyr::full_join) {
  message(
    "Joining `allodb::equations` with `allodb::sitespecies` by 'equation_id'."
  )
  message("Then joining with `allodb::sites_info` by 'site'.")
  suppressMessages({
    eqn_site <- .f(allodb::equations, allodb::sitespecies, by = "equation_id")
    .f(eqn_site, allodb::sites_info, by = "site")
  })
}

