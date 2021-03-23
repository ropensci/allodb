#' @importFrom utils data
NULL

# FIXME: Hack to use stringsAsFactors = FALSE everywhere, with all versions of R
# Can we use tibble() instead? (We are using dplyr, and it exports tibble().)
data_frame <- function(...) {
  base::data_frame(..., stringsAsFactors = FALSE)
}

globalVariables(
  c(
    "Lat",
    "Lon",
    "agb",
    "dbh",
    "dependent_variable",
    "equation",
    "equation_id",
    "equations",
    "independent_variable",
    "ref_id",
    "resample",
    "zone1",
    "zone2"
  )
)
