#' A dummy table listing sites and species in ForestGEO's network.
#'
#' This table relates the table of allometric equations by species with the
#' table of allometric equations by site.
#'
#' @format A data frame with 12 rows and 2 variables:
#'   * `spp`: A character vector of species' names -- in lowercase.
#'   * `site`: A character vector giving site names -- in lowercase.
#'
#' @examples
#' library(dplyr)
#'
#' site_spp
#'
#' full_join(
#'   full_join(site_spp, site_eqn),
#'   spp_eqn
#' )
"site_spp"

#' A dummy table of allometric equations by site in ForestGEO's network.
#'
#' @format A data frame with 2 rows and 2 variables:
#'   * `site`: A character vector giving site names -- in lowercase.
#'   * `site_eqn`: A list of site-specific functions to calculate the biomass.
#'
#' @examples
#' library(dplyr)
#'
#' site_eqn
#'
#' # Pull the FAKE allometric equation of bci.
#' pull(filter(site_eqn, site == "bci"))
"site_eqn"

#' A dummy table of allometric equations by species in ForestGEO's network.
#'
#' @format A data frame  with 17 rows and two variables:
#' * `spp`: A character vector of species' names -- in lowercase.
#' * `spp_eqn`: A list of species-specific functions to calculate the biomass.
#'
#' @examples
#' spp_eqn
"spp_eqn"
