# Database data -------------------------------------------------------------

#' Tables of allometric equations and associated metadata for ForestGEO sites.
#'
#' A compilation of best available allometry equations to calculate tree
#' above-ground biomass (AGB) per species at ForestGEO sites:
#' * `equations`: Table of allometric equations.
#' * `equations_metadata`: Metadata for `equations` table.
#'
#' @details
#' * Refer to `references` table for equations source.
#'
#' @format
#' A data frame with 225 rows and 24 variables:
#' ```
#'	[,1]	ref_id	Unique reference identification number for biomass equation source. Links to Reference table.	character
#'	[,2]	equation_id	Unique equation identification number given arbitrarely. Links to Site_Species table.	character
#'	[,3]	equation_allometry	Equation to calculate biomass (includes coeficients given in original publication)	character
#'	[,4]	equation_form	Algebraic form of the biomass equation (as function of DBH, HT, WD or others)	character
#'	[,5]	dependent_variable	Tree component characterized by the equation	character
#'	[,6]	independent_variable	Parameters included in biomass model (HT: tree height (m); DBH: diameter breast heigh (1.3 m); DBA: diameter at base; WD: wood density)	character	Units = mm, cm, inch
#'	[,7]	equation_taxa	Species, genus, family, or plant group for which the allomery was developed (sometimes used as proxy species to calculate AGB when a specific-species equation is not available)	character (string)
#'	[,8]	allometry_specificity	Specific taxonomic level for which the biomass equation was developed (species, genus, family or plant group)	character
#'	[,9]	geographic_area	Geographic location from which trees were sampled to develop the original equation	character
#'	[,10]	dbh_min_cm	Minimun DBH sampled to develop the equation (cm)	numeric	Units= cm. Range = 0-31
#'	[,11]	dbh_max_cm	Maximun DBH sampled to develop the equation (cm)	numeric	Units= cm. Range = 0-641
#'	[,12]	sample_size	Number of trees sampled to develop the equation	integer	Range = 0-2635
#'	[,13]	dbh_units_original	DBH unit used in original publication	character	Units= cm, inch, mm
#'	[,14]	units_original	Mass or length unit used in original publication	character	Units = g, kg, lbs, Mg
#'	[,15]	allometry_development_method	Method used to develop the allometry. Traditionally, this is done by harvesting whole trees, drying, and weighing ("harvest").  However, we anticipate that many future allometries will be developed using ground-based LiDAR ("lidar").	character
#'	[,16]	regression_model	Regression model used in original publication	character
#'	[,17]	other_equations_tested	Comparable models if reported in publication (given equation form)	character
#'	[,18]	log_biomass	Whether the regression fit is done with biomass as the response variable (i.e log(biomass) base 10)	numeric	0 - false; 1 - true
#'	[,19]	bias_corrected	Indicates if a correction factor (CF) or a relative standard error (RSE) was included in model	numeric	0 - false; 1 - true
#'	[,20]	bias_correction_factor	Correction factor for the specific equation, pulled from original publication, if included	numeric
#'	[,21]	notes_fitting_model	Other details on statistical methods	character
#'	[,22]	original_equation_id	Unique identification  or clues given in original publications	character
#'	[,23]	original_data_availability	Indicates whether or not the original source data is available	character	0 - false; 1 - true
#'	[,24]	notes	Notes or error message to indicate any pitfall that could spoil the AGB estimate based on equation selected	character
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

#Test 5/9/2019
