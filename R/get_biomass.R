#' Compute tree aboveground biomass (AGB) base on allometric
#' equations.
#'
#' This function calculates the above ground biomass of a given tree (or other tree components) based on published allometric equations.
#'
#' The function can run into some memory problems when used on large datasets
#' (usually several hundred thousand observations). In that case, see the second
#' example below for how to apply the function to a splitted dataset.
#'
#' @param dbh a numerical vector containing tree diameter at breast height (dbh)
#'   measurements, in cm.
#' @param genus a character vector (same length as dbh), containing the genus
#'   (e.g. "Quercus") of each tree.
#' @param species a character vector (same length as dbh), containing the
#'   species (e.g. "rubra")  of each tree. Default is NULL, when no
#'   species identification is available.
#' @param coords a numerical vector of length 2 with longitude and latitude (if
#'   all trees were measured in the same location) or a matrix with 2 numerical
#'   columns giving the coordinates of each tree.
#' @param new_eqtable Optional. An equation table created with the
#'   new_equations() function.
#' @param wna this parameter is used in the weight_allom function to determine the
#'   dbh-related weight attributed to equations without a specified dbh range.
#'   Default is 0.1
#' @param w95 this parameter is used in the weight_allom function to determine the
#'   value at which the sample-size-related weight reaches 95% of its maximum
#'   value (max=1). Default is 500.
#' @param Nres number of resampled values. Default is 1e4.
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
                        genus,
                        species = NULL,
                        coords,
                        new_eqtable = NULL,
                        wna = 0.1,
                        w95 = 500,
                        Nres = 1e4) {

  if (!is.null(new_eqtable)) {
    dfequation <- new_eqtable
  } else dfequation <- new_equations()

  params <- est_params(genus, species, coords, dfequation, wna, w95, Nres)

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
  agb <- exp(df$a) * df$dbh^df$b * exp(0.5 * df$sigma^2)

  return(agb)
}


