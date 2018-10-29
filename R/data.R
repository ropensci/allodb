#' SCBI plot stem data (census 1)
#'
#'Dataset of stem data for census 1 at SCBI. Data is also public in Bourg et al. 2013.
#'
"scbi_stem1"


#' Tables of allometric equations and associated metadata for ForestGEO sites.
#'
#' A compilation of best available allometry equations to calculate tree above-ground biomass (AGB)
#'  per species at ForestGEO sites:
#' * `equations`: Table of allometric equations.
#' * `equations_metadata`: Table of metadata of `equations`.
#'
#' @format
#' A data frame with 154 observations on 6 variables.
#' ```
#' [,1]	Ozone	 numeric	 Ozone (ppb)
#' [,2]	Solar.R	 numeric	 Solar R (lang)
#' [,3]	Wind	 numeric	 Wind (mph)
#' [,4]	Temp	 numeric	 Temperature (degrees F)
#' [,5]	Month	 numeric	 Month (1--12)
#' [,6]	Day	 numeric	 Day of month (1--31)
#' ```
"equations"

#' @rdname equations
"equations_metadata"

#' @format A data frame with 168 rows and 22 variables:
#' \describe{
#'   \item{equation_id}{Unique equation identification number given arbitrarely.}
#'   \item{equation_form}{Darn I don't know how to make a table like in dataset::airquality!}
#'   ...
#' }
#'

#' Table of metadata associated to the table `missing_values`.
#'
#'  Example of alternative format for meta-data documentation:
#' * NA: Not Applicable; Data does not apply to that particular case
#'
"missing_values_metadata"

#' Table of metadata associated to the table `references`.
#'
"references_metadata"



#' Tables of ForestGEO sites and tree species and associated metadata.
#'
#' * `sitespecies`: Table of ForestGEO sites and tree species.
#' * `sitespecies_metadata`: Metadata for `sitespecies` table.
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
