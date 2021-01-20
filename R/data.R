# Database data -------------------------------------------------------------

#' Tables of allometric equations and associated metadata.
#'
#' A compilation of best available allometry equations to calculate tree
#' above-ground biomass (AGB) per species based on
#' extratropical ForestGEO sites:
#' * `equations`: Table of allometric equations.
#' * `equations_metadata`: Metadata for `equations` table.
#'
#' @details
#'
#'
#'
#' @format
#' `equations`: A data frame with 568 rows and 47 variables:
#' ```
#' 	[,1]	ref_id	character
#' 	[,2]	equation_id	character
#' 	[,3]	equation_allometry	character
#' 	[,4]	equation_form	character
#' 	[,5]	dependent_variable	character
#' 	[,6]	independent_variable	character
#' 	[,7]	equation_taxa	character
#' 	[,8]	allometry_specificity	character
#' 	[,9]	equation_categ	character
#' 	[,10]	geographic_area	character
#' 	[,11]	original_coord	character
#' 	[,12]	lat	numeric
#' 	[,13]	long	numeric
#' 	[,14]	elev_m	numeric
#' 	[,15]	geography. Notes	character
#' 	[,16]	mat_C	numeric
#' 	[,17]	min.temp_C	numeric
#' 	[,18]	max.temp_C	numeric
#' 	[,19]	map_mm	numeric
#' 	[,20]	frost_free_period_days	numeric
#' 	[,21]	climate. Notes	character
#' 	[,22]	stand_age_range_yr	character
#' 	[,23]	stand_age_history	character
#' 	[,24]	stand_basal_area_m2_ha	numeric
#' 	[,25]	stand_trees_ha	numeric
#' 	[,26]	forest_description	character
#' 	[,27]	ecosystem_type	character
#' 	[,28]	koppen	character
#' 	[,29]	dbh_min_cm	numeric
#' 	[,30]	dbh_max_cm	numeric
#' 	[,31]	sample_size	integer
#' 	[,32]	collection_year	integer
#' 	[,33]	dbh_units_original	numeric
#' 	[,34]	dbh_unit_CF	numeric
#' 	[,35]	output_units_original	character
#' 	[,36]	output_units_CF	numeric
#' 	[,37]	allometry_development_method	character
#' 	[,38]	regression_model	character
#' 	[,39]	r_squared	numeric
#' 	[,40]	other_equations_tested	character
#' 	[,41]	log_biomass	numeric
#' 	[,42]	bias_corrected	character
#' 	[,43]	bias_correction_factor	numeric
#' 	[,44]	notes_fitting_model	character
#' 	[,45]	original_equation_id	character
#' 	[,46]	original_data_availability	character
#' 	[,47]	equation_notes	character
#'
#' ```
#' @source * Go to `references` table for equations original sources.
#'
#' @family database datasets
"equations"
#' @rdname equations
"equations_metadata"

#' A table with explanations of missing values codes
#'
#'  A list of codes used to indicate missing information in equation table:
#'* `missing_values`: Table with explanations of missing values codes.
#'
#' @format
#' A small data frame with 4 rows and 3 variables:
#' ```
#' 	[,1]	Code	character
#' 	[,2]	Definition	character
#' 	[,3]	Description	character
#' 	```
#' @family database datasets
"missing_values"

#' Tables of sites and tree species used in allo-db and associated metadata.
#'
#' * `sitespecies`: Table of extratropical ForestGEO sites used in allo-db (n=24) and their tree species.
#' * `sitespecies_metadata`: Metadata for `sitespecies` table.
#'
#'#' @format
#' A data frame with 1114 rows and 10 variables:
#' ```
#' [,1]	site	character
#' [,2]	family	character
#' [,3]	genus	character
#' [,4]	species	character
#' [,5]	variety	character
#' [,6]	subspecies	character
#' [,7]	latin_name	character
#' [,8]	species_code	character
#' [,9]	life_form	character
#' [,10]	warning	character
#'
#'```
#' @family database datasets
"sitespecies"
#'
#' @name sitespecies
"sitespecies_metadata"


#' Tables of equation references and associated metadata
#'
#' Bibliography from where equations where sourced. Links to equations table by ref_id.
#'
#' * `references`: A dataframe listing all references used in equation table.
#' * `references_metadata`: Table of metadata of `reference`.
#'
#'#'#' @format
#' A data frame with 57 rows and 6 variables:
#' ```
#' [,1]	ref_id	character
#' [,2]	ref_doi	character
#' [,3]	ref_author	character
#' [,4]	ref_year	integer
#' [,5]	ref_title	character
#' [,6]	References full citation	character
#'
#'```
#' @family database datasets
"references"

#' @name references
"references_metadata"
