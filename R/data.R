#' Tables of allometric equations and associated metadata for ForestGEO sites.
#'
#' A dataset of best available allometry equations to calculate AGB per species per ForestGEO site
#' * `equations`: Table of allometric equations.
#' * `equations_metadata`: Table of metadata of `equations`.
#'@format a dataset of 419 observations and 24 variables
#'\describe{
#'   \item{equation_id}{Unique equation identification number given arbitrarely. Links to Site_Species table.}
"equations"

#' @rdname equations
"equations_metadata"




#' Table of metadata associated to the table `missing_values`.
#'
#'  Example of alternative format for meta-data documentation:
#' * NA: Not Applicable; Data does not apply to that particular case
#'
"missing_values_metadata"



#' Table of metadata associated to the table `references`.
#'
"references_metadata"


#' Tables of sites and species and associated metadata.
#'
#' * `sitespecies`: Table of sites and species.
#' * `sitespecies_metadata`: Table of metadata of `sitespecies`.
#'
"sitespecies"

#' @name sitespecies
"sitespecies_metadata"



#' Tables of wood density and associated metadata.
#'
#' * `wsg`: Table of allometric equations.
#' * `wsg_metadata`: Table of metadata of `wsg`.
#'
"wsg"

#' @name wsg
"wsg_metadata"



#' Table of information on sites from tropical forests.
#'
#' @source Ervan Rutishauser (er.rutishauser@@gmail.com), received on Sat,
#' Oct 28, 2017 at 4:05 AM.
"sites_info"
