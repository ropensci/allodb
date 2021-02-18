# Database data -------------------------------------------------------------

#'Tables of allometric equations and associated metadata.
#'
#'A compilation of best available allometry equations to calculate tree
#'above-ground biomass (AGB) per species based on extratropical ForestGEO sites:
#'* `equations`: Table of allometric equations.
#'* `equations_metadata`:
#'Explanation of columns for `equations` table.
#'
#' @format
#' `equations`: A data frame with 571 rows and 47 variables:
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
#'
#'```
#' @family database datasets
"missing_values"



#' Tables of sites and tree species used in allodb and associated metadata.
#'
#' * `sitespecies`: Table of extratropical ForestGEO sites
#' in allodb (n=24) and their tree species.
#' * `sitespecies_metadata`: Metadata for `sitespecies`
#' table.
#'
#' @format A data frame with 1114 rows and 10 variables:
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
#' [,10]	notes	character
#'
#'```
#' @family database datasets
"sitespecies"

#' @rdname sitespecies
"sitespecies_metadata"



#' Tables of equation references and associated metadata
#'
#' Bibliographical information for sourced equations. Links
#' to the `equations`table by ref_id.
#' * `references`: A data frame listing all references used in `equation` table.
#' * `references_metadata`: Metadata for `reference` table.
#'
#' @format A data frame with 57 rows and 6 variables:
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

#' @rdname references
"references_metadata"



#' ForestGEO sites used in allodb
#'
#' Table with geographical information for extratropical
#' ForestGEO sites used in allodb (n=24).
#'
#' More details on geographical aspects of these ForestGEO
#' sites can be found in the accompanying manuscript.
#'
#' @format
#' A data frame with 24 observations and 6 variables:
#' ```
#' [,1]	Site	character
#' [,2]	site	character
#' [,3]	lat	decimal
#' [,4]	long	decimal
#' [,5]	elevation.m	numeric
#' [,6]	koppen	character
#'
#'```
#' @family database datasets
"sites_info"



#' Tree census data from SCBI ForestGEO plot
#'
#' A table with tree data from the Smithsonian Conservation Biology Institute,
#' USA (SCBI) ForestGEO dynamics plot. These data is from the first tree census
#' in 2008, and only cover 1 hectare (SCBI is 25 ha).
#'
#'
#' @format
#' A data frame with 2287 observations and 6 variables:
#' ```
#' [,1]	treeID	numeric
#' [,2]	stemID	numeric
#' [,3]	dbh	numeric
#' [,4]	genus	character
#' [,5]	species	character
#' [,6]	Family	character
#'
#'```
#' @source Full data sets for tree census data at SCBI can be requested through
#'   the ForestGEO portal (https://forestgeo.si.edu/).
#'   Census 1, 2, and 3 can also
#'   be accessed at the public GitHub repository for SCBI-ForestGEO Data
#'   (https://github.com/SCBI-ForestGEO).
"scbi_stem1"



#' Genus and family table for selected ForestGEO sites
#'
#' Table with genus and their associated family identified in the ForestGEO
#' sites used in allodb. This data frame is an input in the weight_allom()
#' function.
#'
#' * `genus_family`: A data frame with genus and families identified in the
#' extratropical ForestGEO sites used in allodb.
#'
#' @format A data frame with 248 observations and 2 variables:
#' ```
#' [,1]	genus	character
#' [,2]	family	character
#'
#'```
"genus_family"



#'Gymnosperms identified in selected ForestGEO sites
#'
#'Table with genus and their associated family for Gymnosperms identified in the
#'ForestGEO sites used in allodb. This data frame is particularly important to
#'differentiate conifers as input in the weight_allom() function.
#'
#'* `gymno_genus`: A data frame with genus and families for Gymnosperms
#'identified in the extratropical ForestGEO sites used in allodb.
#'
#'@format A data frame with 95 observations and 3 variables:
#' ```
#'[,1]	Family	character
#'[,2]	Genus	character
#'[,3]  conifer logical
#'
#'```
"gymno_genus"



#' List of shrub identified in selected ForestGEO sites
#'
#' A list with genus and species of shrubby plants identified in the ForestGEO
#' sites used in allodb. The list is an input in the weight_allom() function.
#'
#' * `shrub_species`: A list with genus and species of shrubby plants identified
#' in the extratropical ForestGEO #'sites used in allodb.
#'
#' @format
#' A vector containing 179 observations
#'
"shrub_species"



#' Koppen climate classification matrix
#'
#' A table built to facilitate the comparison between the Koppen climate of a
#' site and the allometric equation in question. This table is used in the
#' weighting scheme in the weight_allom() function.
#'
#' * `koppenMatrix`: A data frame with two columns depicting the 3-letter system
#' of the Koppen climate scheme and the given weight when comparing
#' site/equation climate.
#'
#' The value of column `wE` is the weight given to the combination of
#' Koppen climates in columns `zone1`and `zone2`; the table is symmetric:
#' `zone1`and `zone2` can be interchanged. This weight is calculated in 3 steps:
#' (1) if the main climate group (first letter) is the same, the climate weight
#' starts at 0.4; if one of the groups is "C" (temperate climate) and the other
#' is "D" (continental climate), the climate weight starts at 0.2 because the 2
#' groups are considered similar enough; otherwise, the weight is 0; (2) if the
#' equation and site belong to the same group, the weight is incremented by an
#' additional value between 0 and 0.3 based on precipitation pattern similarity
#' (second letter of the Koppen zone), and (3) by an additional value between 0
#' and 0.3 based on temperature pattern similarity (third letter of the Koppen
#' zone). The resulting weight has a value between 0 (different climate groups)
#' and 1 (exactly the same climate classification).
#'
#' @format
#' A data frame with 900 observations and 3 variables:
#' ```
#' [,1]	zone1	character
#' [,2]	zone2	character
#' [,3]	wE	decimal
#'
#'```
"koppenMatrix"
