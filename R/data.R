# Database data -------------------------------------------------------------

#' Tables of allometric equations and associated metadata for ForestGEO sites.
#'
#' A compilation of best available allometry equations to calculate tree
#' above-ground biomass (AGB) per species at ForestGEO sites:
#' * `equations`: Table of allometric equations.
#' * `equations_metadata`: Table of metadata of `equations`.
#'
#'
#' @details
#' * equation_id: Unique equation identification number given arbitrarely.
#' * equation_form: FIXME.
#'
#' @format
#' A data frame with 168 rows and 22 variables:
#' ```
#' # FIXME: Replace with real data.
#' [,1]	Ozone	 numeric	 Ozone (ppb)
#' [,2]	Solar.R	 numeric	 Solar R (lang)
#' [,3]	Wind	 numeric	 Wind (mph)
#' [,4]	Temp	 numeric	 Temperature (degrees F)
#' [,5]	Month	 numeric	 Month (1--12)
#' [,6]	Day	 numeric	 Day of month (1--31)
#' ```
#' @family database datasets
"equations"

#' @rdname equations
"equations_metadata"



#' Table of metadata associated to the table `missing_values`.
#'
#'  Example of alternative format for meta-data documentation:
#' * NA: Not Applicable; Data does not apply to that particular case
#'
#' @family database datasets
"missing_values_metadata"



#' Table of metadata associated to the table `references`.
#'
#' @family database datasets
"references_metadata"



#' Tables of ForestGEO sites and tree species and associated metadata.
#'
#' * `sitespecies`: Table of ForestGEO sites and tree species.
#' * `sitespecies_metadata`: Metadata for `sitespecies` table.
#'
#' @family database datasets
"sitespecies"

#' @name sitespecies
"sitespecies_metadata"



#' Tables of wood density and associated metadata.
#'
#' * `wsg`: Table of allometric equations.
#' * `wsg_metadata`: Table of metadata of `wsg`.
#'
#' @family database datasets
"wsg"

#' @name wsg
"wsg_metadata"



#' Table of information on sites from tropical forests.
#'
#' @source Ervan Rutishauser (er.rutishauser@@gmail.com), received on Sat,
#' Oct 28, 2017 at 4:05 AM.
#'
#' @family database datasets
"sites_info"



# Census data -------------------------------------------------------------

#' Data from SCBI.
#'
#' @name scbi
#'
#' @source http://bit.ly/scbi-forestgeo-data
#' @format Objects of class tbl_df (inherit from tbl, data.frame). See structure
#'   in __Examples__.
#'
#' @family census datasets
#'
#' @examples
#' dim(scbi_tree1)
#' dim(scbi_tree2)
#' str(scbi_tree2)
#'
#' dim(scbi_stem1)
#' dim(scbi_stem2)
#' str(scbi_stem2)
#'
#' str(scbi_species)
NULL

#' @rdname scbi
"scbi_tree1"
#' @rdname scbi
"scbi_tree2"
#' @rdname scbi
"scbi_species"
#' @rdname scbi
"scbi_stem1"
#' @rdname scbi
"scbi_stem2"

