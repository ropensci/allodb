#' Compute tree aboveground biomass (AGB) based on allometric equations.
#'
#' This function calculates the aboveground biomass (or other tree components)
#' of a given tree based on published allometric equations. Users need to
#' provide a table (i.e. dataframe) with DBH (cm), parsed species Latin names,
#' and site(s) coordinates. The biomass of all trees in one (or several)
#' censuses can be estimated using this function.
#'
#' The function can run into some memory problems when used on large datasets
#' (usually several hundred thousand observations). In that case, see the second
#' example below for how to apply the function to a split dataset.
#'
#' @param dbh a numerical vector containing tree diameter at breast height (dbh)
#'   measurements, in cm.
#' @param genus a character vector (same length as dbh), containing the genus
#'   (e.g. "Quercus") of each tree.
#' @param coords a numerical vector of length 2 with longitude and latitude (if
#'   all trees were measured in the same location) or a matrix with 2 numerical
#'   columns giving the coordinates of each tree.
#' @param species a character vector (same length as dbh), containing the
#'   species (e.g. "rubra")  of each tree. Default is NULL, when no species
#'   identification is available.
#' @param new_eqtable Optional. An equation table created with the
#'   new_equations() function.
#' @param wna this parameter is used in the weight_allom function to determine
#'   the dbh-related weight attributed to equations without a specified dbh
#'   range. Default is 0.1
#' @param w95 this parameter is used in the weight_allom function to determine
#'   the value at which the sample-size-related weight reaches 95% of its
#'   maximum value (max=1). Default is 500.
#' @param nres number of resampled values. Default is 1e4.
#'
#' @return A vector of class "numeric" of the same length as dbh, containing AGB
#'   value (in kg) for every stem
#'
#' @export
#'
#' @examples
#' data(scbi_stem1)
#' # estimate the biomass of all individuals from the Lauraceae family
#' data_laur <- subset(scbi_stem1, Family=="Lauraceae")
#' data_laur$agb <- get_biomass(
#'   dbh = data_laur$dbh,
#'   genus = data_laur$genus,
#'   species = data_laur$species,
#'   coords = c(-78.2, 38.9)
#' )
#'
get_biomass <- function(dbh,
                        genus,
                        coords,
                        species = NULL,
                        new_eqtable = NULL,
                        wna = 0.1,
                        w95 = 500,
                        nres = 1e4) {
  if (!is.null(new_eqtable)) {
    dfequation <- new_eqtable
  } else
    dfequation <- new_equations()

  if (length(unlist(coords)) == 2) {
    coords <- matrix(coords, ncol = 2)
  }
  colnames(coords) <- c("long", "lat")

  ## input data checks
  if (any(!is.na(dbh) & (dbh < 0 | dbh > 1e3)))
    stop("Your dbh data contain negative values and/or values > 1000 cm.
         Please check your data.")
  if (any(abs(coords[,1]) > 180 | abs(coords[,2]) > 90))
    stop("Your coords contain longitudes that are not between -180 and 180, or
         latitudes that are not between -90 and 90. Please check your data.")

  params <-
    est_params(genus = genus,
               coords = coords,
               species = species,
               new_eqtable = dfequation,
               wna = wna,
               w95 = w95,
               nres = nres)

  if (!is.null(species)) {
    df <-
      merge(
        data.frame(stringsAsFactors = FALSE, id = seq_len(length(dbh)), dbh, genus, species, coords),
        params,
        by = c("genus", "species", "long", "lat")
      )
  } else
    df <- merge(data.frame(stringsAsFactors = FALSE, id = seq_len(length(dbh)), dbh, genus, coords),
                params,
                by = c("genus", "long", "lat"))

  df <- df[order(df$id), ]
  agb <- df$a * df$dbh ^ df$b

  return(agb)
}
