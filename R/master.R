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
#' master()
#'
#' \dontrun{
#' # Nice view in RStudio
#' View(master())
#' }
master <- function() {
  message(
    "Joining `equations` and `sitespecies` by 'equation_id'; ",
    "then `sites_info` by 'site'."
  )

  suppressMessages({
    eqn_site <- dplyr::left_join(
      allodb::equations, allodb::sitespecies, by = "equation_id"
    )
    dplyr::left_join(eqn_site, allodb::sites_info, by = "site")
  })
}

