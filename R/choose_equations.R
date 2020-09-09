#' Function to subset the default equation table, based on taxa, koppen climate zone or region.
#' This subsetted equation table can then be used in the `get_biomass` function.
#'
#' @param taxa character vector with taxa to be kept. Default is `all`, in which
#'   case all taxa are kept.
#' @param climate character vector with name of Koppen climate to be kept.
#'   Default is `all`, in which case all climates are kept.
#' @param region character vector with name of location(s) or country(ies) or broad region(s)
#'  (`Europe`, `North America`, etc -> add complete list) to be kept.
#'   Default is `all`, in which case all regions are kept.
#' @param new_equations optional equation table, as created by the
#'   `add_equations` function. Default is `NULL`, in which case the default
#'   equation table is used.
#' @return A subsetted equation table.
#'
#' @export
#'
#' @examples
#'
choose_equations <- function(taxa = "all",
                             climate = "all",
                             region = "all",
                             new_equations = NULL) {
  if (is.null(new_equations)) {
    data("equations")
    new_equations <- equations
  }

  # check input consistency
  if (!is.character(taxa) | !is.character(climate)) {
    stop("taxa and climate arguments must be character vectors.")
  }

  if (taxa != "all") {
    keep <- sapply(new_equations$equation_taxa, function(tax0) {
      any(sapply(taxa, function(i) grepl(i, tax0)))
    })
    new_equations <- new_equations[keep, ]
  }

  if (climate != "all") {
    keep <- sapply(new_equations$koppen, function(clim0) {
      any(sapply(climate, function(i) grepl(i, clim0)))
    })
    new_equations <- new_equations[keep, ]
  }

  if (region != "all") {
    keep <- sapply(new_equations$geographic_area, function(reg0) {
      any(sapply(region, function(i) grepl(i, reg0)))
    })
    new_equations <- new_equations[keep, ]
  }

  return(new_equations)
}
