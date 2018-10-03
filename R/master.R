#' Read csv files into a master table.
#'
#' @param path Path to directory with equations.csv, sitespecies.csv, and
#'   sites_info.csv.
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' csv_master(allodb_example("csv_database"))
#' # Or
#' \dontrun{
#' csv_master("data-raw/csv_database")
#' }
csv_master <- function(path) {
  main_tables <- "equations.csv$|sitespecies.csv$|sites_info.csv"
  files <- fs::dir_ls(path, regexp = main_tables)
  tbls <- purrr::map(files, readr::read_csv)
  names(tbls) <- fs::path_ext_remove(fs::path_file(names(tbls)))

  tbls$equations %>%
    dplyr::left_join(tbls$sitespecies, by = "equation_id") %>%
    dplyr::left_join(tbls$sites_info, by = "site")
}

#' Help create path to example data.
#'
#' @param path Directory containing example.
#'
#' @return A path.
#' @export
#'
#' @examples
#' allodb_example("csv_database")
allodb_example <- function(path) {
  system.file("extdata", path, package = "allodb")
}

