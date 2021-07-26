#' Tables of allometric equations and associated metadata.
#'
#' A compilation of best available allometry equations to calculate tree
#' above-ground biomass (AGB) per species based on extratropical ForestGEO
#' sites.
#'
#'* `equations`: Table of allometric equations.
#'* `equations_metadata`: Explanation of columns for `equations` table.
#'
#' @source * Go to `references` table for equations original sources.
#'
#' @family database datasets
#'
#' @examples
#' equations
"equations"

#' @rdname equations
#' @examples
#' equations_metadata
"equations_metadata"



#' A table with explanations of missing values codes
#'
#' A list of codes used to indicate missing information in equation table.
#'
#' * `missing_values`: Table with explanations of missing values codes.
#'
#' @family database datasets
#'
#' @examples
#' missing_values
"missing_values"



#' Tables of sites and tree species used in allodb and associated metadata.
#'
#' * `sitespecies`: Table of extratropical ForestGEO sites in allodb (n=24) and
#' their tree species.
#' * `sitespecies_metadata`: Metadata for `sitespecies` table.
#'
#' @family database datasets
#'
#' @examples
#' sitespecies
"sitespecies"

#' @rdname sitespecies
#' @examples
#' sitespecies_metadata
"sitespecies_metadata"



#' Tables of equation references and associated metadata
#'
#' Bibliographical information for sourced equations. Links to the
#' `equations`table by ref_id.
#'
#' * `references`: A data frame listing all references used in `equation` table.
#' * `references_metadata`: Metadata for `reference` table.
#'
#' @family database datasets
#'
#' @examples
#' references
"references"

#' @rdname references
#' @examples
#' references_metadata
"references_metadata"



#' ForestGEO sites used in allodb
#'
#' Table with geographical information for extratropical ForestGEO sites used in
#' allodb (n=24).
#'
#' More details on geographical aspects of these ForestGEO sites can be found in
#' the accompanying manuscript.
#'
#' @family database datasets
#'
#' @examples
#' sites_info
"sites_info"



#' Tree census data from SCBI ForestGEO plot
#'
#' A table with tree data from the Smithsonian Conservation Biology Institute,
#' USA (SCBI) ForestGEO dynamics plot. These data is from the first tree census
#' in 2008, and only cover 1 hectare (SCBI is 25 ha).
#'
#' @source Full data sets for tree census data at SCBI can be requested through
#'   the ForestGEO portal (https://forestgeo.si.edu/). Census 1, 2, and 3 can
#'   also be accessed at the public GitHub repository for SCBI-ForestGEO Data
#'   (https://github.com/SCBI-ForestGEO).
#'
#' @examples
#' scbi_stem1
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
#' @examples
#' genus_family
"genus_family"



#' Gymnosperms identified in selected ForestGEO sites
#'
#' Table with genus and their associated family for Gymnosperms identified in
#' the ForestGEO sites used in allodb. This data frame is particularly important
#' to differentiate conifers as input in the weight_allom() function.
#'
#' * `gymno_genus`: A data frame with genus and families for Gymnosperms
#'identified in the extratropical ForestGEO sites used in allodb.
#'
#' @examples
#' gymno_genus
"gymno_genus"



#' List of shrub identified in selected ForestGEO sites
#'
#' A list with genus and species of shrubby plants identified in the ForestGEO
#' sites used in allodb. The list is an input in the weight_allom() function.
#'
#' * `shrub_species`: A list with genus and species of shrubby plants identified
#' in the 24 extratropical ForestGEO sites used in allodb.
#'
#' @examples
#' shrub_species
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
#' The value of column `wE` is the weight given to the combination of Koppen
#' climates in columns `zone1`and `zone2`; the table is symmetric: `zone1`and
#' `zone2` can be interchanged. This weight is calculated in 3 steps: (1) if the
#' main climate group (first letter) is the same, the climate weight starts at
#' 0.4; if one of the groups is "C" (temperate climate) and the other is "D"
#' (continental climate), the climate weight starts at 0.2 because the 2 groups
#' are considered similar enough; otherwise, the weight is 0; (2) if the
#' equation and site belong to the same group, the weight is incremented by an
#' additional value between 0 and 0.3 based on precipitation pattern similarity
#' (second letter of the Koppen zone), and (3) by an additional value between 0
#' and 0.3 based on temperature pattern similarity (third letter of the Koppen
#' zone). The resulting weight has a value between 0 (different climate groups)
#' and 1 (exactly the same climate classification).
#'
#' @examples
#' koppenMatrix
"koppenMatrix"
