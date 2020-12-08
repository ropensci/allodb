#' Function to compute aboveground biomass (or other variables) from allometric
#' equations.
#'
#' This function creates S3 objects of class "numeric".
#'
#' The function can run into some memory problems when used on large datasets
#' (usually several hundred thousand observations). In that case, see the 2nd
#' example below for how to apply the function to a splitted dataset.
#'
#' @param dbh A numerical vector containing tree diameter at breast height (dbh)
#'   measurements, in cm.
#' @param h A numerical vector (same length as dbh) containing tree height
#'   measurements, in m. Default is NULL, when no measurement is available.
#' @param genus A character vector (same length as dbh), containing the genus
#'   (e.g. "Quercus") of each tree.
#' @param species A character vector (same length as dbh), containing the
#'   species (e.g. "rubra")  of each tree. Default is NULL, when no
#'   identification is available.
#' @param shrub A logical vector (same length as dbh): is the observation a
#'   shrub? Default is `NULL` (no information), in which case allometric
#'   equations designed for shrubs will be used only for species recorded as
#'   shrubs in ForestGEO sites.
#' @param coords A numerical vector of length 2 with longitude and latitude (if
#'   all trees were measured in the same location) or a matrix with 2 numerical
#'   columns giving the coordinates of each tree.
#' @param new_eqtable Optional. An equation table created with the
#'   new_equations() function.
#' @param wna this parameter is used in the weighting function to determine the
#'   dbh-related weight attributed to equations without a specified dbh range.
#'   Default is 0.1
#' @param wsteep this parameter controls the steepness of the dbh-related weight
#'   in the weighting function. Default is 3.
#' @param w95 this parameter is used in the weighting function to determine the
#'   value at which the sample-size-related weight reaches 95% of its maximum
#'   value (max=1). Default is 500.
#'
#' @return A vector of class "numeric" of the same length as dbh, containing AGB
#'   value (in kg) for every stem, or the dependent variable as defined in
#'   `var`.
#' @export
#'
#' @examples
#' data(scbi_stem1)
#' get_biomass(
#'   dbh = scbi_stem1$dbh,
#'   genus = scbi_stem1$genus,
#'   species = scbi_stem1$species,
#'   coords = c(-78.2, 38.9)
#' )
#'
#' # split dataset to avoid memory over usage
#' data_split <- split(scbi_stem1, cut(1:nrow(scbi_stem1), breaks = 10, labels = FALSE))
#' agb <- lapply(data_split, function(df) {
#'   get_biomass(
#'     dbh = df$dbh,
#'     genus = df$genus,
#'     species = df$species,
#'     coords = c(-78.2, 38.9)
#'   )
#' })
#' scbi_stem1$agb <- do.call(c, agb)
get_biomass <- function(dbh,
                        # h = NULL,
                        genus,
                        species = NULL,
                        # shrub = NULL,
                        coords,
                        new_eqtable = NULL,
                        wna = 0.1,
                        w95 = 500) {

  if (!is.null(new_eqtable)) {
    dfequation <- new_eqtable
  } else dfequation <- new_equations()

  params <- est_params(genus, species, coords, dfequation, wna, w95)

  if (length(unlist(coords)) == 2) {
    coords <- matrix(coords, ncol = 2)
  }
  colnames(coords) <- c("long", "lat")

  if (!is.null(species)) {
    df <- merge(data.frame(id = 1:length(dbh), dbh, genus, species, coords),
                params, by = c("genus", "species", "long", "lat"))
  } else  df <- merge(data.frame(id = 1:length(dbh), dbh, genus, coords),
                      params, by = c("genus", "long", "lat"))

  df <- df[order(df$id),]
  agb <- exp(df$a) * df$dbh^df$b * + exp(0.5 * df$sigma^2)

  return(agb)
}


