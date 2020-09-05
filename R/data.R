# Database data -------------------------------------------------------------

#' Tables of allometric equations and associated metadata for ForestGEO sites.
#'
#' A compilation of best available allometry equations to calculate tree
#' above-ground biomass (AGB) per species at ForestGEO sites:
#' * `equations`: Table of allometric equations.
#' * `equations_metadata`: Metadata for `equations` table.
#'
#' @details
#'
#'
#'
#' @format
#' A data frame with 225 rows and 24 variables:
#' ```
#'	[,1]	ref_id	character
#'	[,2]	equation_id	character
#'	[,3]	equation_allometry	character
#'	[,4]	equation_form	character
#'	[,5]	dependent_variable	character
#'	[,6]	independent_variable	character
#'	[,7]	equation_taxa	character (string)
#'	[,8]	allometry_specificity	character
#'	[,9]	geographic_area	character
#'	[,10]	dbh_min_cm	numeric
#'	[,11]	dbh_max_cm	numeric
#'	[,12]	sample_size	integer
#'	[,13]	dbh_units_original	character
#'	[,14]	units_original	character
#'	[,15]	allometry_development_method	character
#'	[,16]	regression_model	character
#'	[,17]	other_equations_tested	character
#'	[,18]	log_biomass	numeric
#'	[,19]	bias_corrected	numeric
#'	[,20]	bias_correction_factor	numeric
#'	[,21]	notes_fitting_model	character
#'	[,22]	original_equation_id	character
#'	[,23]	original_data_availability	character
#'	[,24]	notes	character
#'
#' ```
#' @source * Go to `references` table for equations original sources.
#'
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

#Test 5/9/2019



#' Title
#'
#' Description
#'
#' @source ?
#'
#' @family database datasets
"genus_family"
