#' Join allodb tables: `equations`, `sitespecies`, and `sites_info`.
#'
#' @seealso [dplyr::full_join()].
#' @family functions to interact with the database
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
      allodb::equations,
      allodb::sitespecies,
      by = "equation_id"
    )

    dplyr::left_join(
      lowercase_site(eqn_site),
      lowercase_site(allodb::sites_info),
      by = "site"
    )
  })
}

lowercase_site <- function(data) {
  data$site <- tolower(data$site)
  data
}
