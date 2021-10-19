#' Compute tree aboveground biomass (AGB) based on allometric equations.
#'
#' This function calculates the aboveground biomass (or other tree components)
#' of a given tree based on published allometric equations. Users need to
#' provide a table (i.e. dataframe) with DBH (cm), parsed species Latin names,
#' and site(s) coordinates. The biomass of all trees in one (or several)
#' censuses can be estimated using this function.
#'
#' The function can run into some memory problems when used on large datasets
#' (usually several hundred thousand observations).
#'
#' @param dbh a numeric vector containing tree diameter at breast height (dbh)
#' measurements, in cm.
#' @param genus a character vector (same length as dbh), containing the genus
#' (e.g. "Quercus") of each tree.
#' @param coords a numeric vector of length 2 with longitude and latitude (if
#' all trees were measured in the same location) or a matrix with 2 numerical
#' columns giving the coordinates of each tree.
#' @param species a character vector (same length as dbh), containing the
#' species (e.g. "rubra")  of each tree. Default is `NULL`, when no species
#' identification is available.
#' @param new_eqtable Optional. An equation table created with the
#' `new_equations()` function.
#' @param wna a numeric vector, this parameter is used in the `weight_allom()`
#' function to determine
#' the dbh-related weight attributed to equations without a specified dbh
#' range. Default is 0.1
#' @param w95 a numeric vector, this parameter
#' is used in the `weight_allom()` function to determine
#' the value at which the sample-size-related weight reaches 95% of its
#' maximum value (max=1). Default is 500.
#' @param nres number of resampled values. Default is "1e4".
#'
#' @details `allodb` estimates AGB by calibrating a new allometric equation for
#' each taxon (arguments `genus` and  `species`) and location (argument
#' `coords`) in the user-provided census data. The new allometric equation is
#' based on a set of allometric equations that can be customized using the
#' `new_eqtable` argument. Each equation is then given a weight with the
#' `weight_allom()` function, based on: 1) its original sample size (numbers of
#' trees used to develop a given allometry), 2) its climatic similarity with
#' the target location, and 3) its taxonomic similarity with the target taxon
#' (see documentation of the `weight_allom()` function). The final weight
#' attributed to each equation is the product of those three weights.
#' Equations are then resampled with the`resample_agb()` funtion: the number
#' of samples per equation is proportional to its weight, and the total number
#' of samples is provided by the argument `nres`. The resampling is done by
#' drawing DBH values from a uniform distribution on the DBH range of the
#' equation, and estimating the AGB with the equation. The couples of values
#' (DBH, AGB) obtained are then used in the
#' function `est_params()` to calibrate
#' a new allometric equation, by applying a linear regression to the
#' log-transformed data. The parameters of the new allometric equations are
#' then used in the `get_biomass()` function by back-transforming the AGB
#' predictions based on the user-provided DBHs.
#'
#' @return A vector of class "numeric" of the same length as dbh, containing AGB
#' value (in kg) for every stem
#'
#' @seealso [weight_allom()], [new_equations()]
#'
#' @export
#'
#' @examples
#' # Estimate biomass of all individuals from the Lauraceae family at the SCBI
#' # plot
#' lau <- subset(scbi_stem1, Family == "Lauraceae")
#' lau$agb <- get_biomass(lau$dbh, lau$genus, lau$species,
#'   coords = c(-78.2, 38.9)
#' )
#' lau
#'
#' # Estimate biomass from multiple sites (using scbi_stem1 as example with
#' # multiple coord)
#' dat <- scbi_stem1[1:100, ]
#' dat$long <- c(rep(-78, 50), rep(-80, 50))
#' dat$lat <- c(rep(40, 50), rep(41, 50))
#' dat$biomass <- get_biomass(
#'   dbh = dat$dbh,
#'   genus = dat$genus,
#'   species = dat$species,
#'   coords = dat[, c("long", "lat")]
#' )
#' dat
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
  } else {
    dfequation <- new_equations()
  }

  if (length(unlist(coords)) == 2) {
    coords <- matrix(coords, ncol = 2)
  }
  colnames(coords) <- c("long", "lat")

  ## input data checks
  if (any(!is.na(dbh) & (dbh < 0 | dbh > 1e3))) {
    abort(c(
      "Each value of `dbh` must be positive and < 1000 cm.",
      i = "Do you need to check your data?"
    ))
  }
  if (any(abs(coords[, 1]) > 180 | abs(coords[, 2]) > 90)) {
    abort(c(
      "`coords` longitudes must range -180 to 180, and latitudes -90 to 90.",
      i = "Do you need to check your data?"
    ))
  }

  params <-
    est_params(
      genus = genus,
      coords = coords,
      species = species,
      new_eqtable = dfequation,
      wna = wna,
      w95 = w95,
      nres = nres
    )

  if (!is.null(species)) {
    data <- tibble::tibble(
      id = seq_len(length(dbh)),
      dbh,
      genus,
      species,
      long = coords[[1]],
      lat = coords[[2]]
    )
    df <-
      merge(
        data,
        params,
        by = c("genus", "species", "long", "lat")
      )
  } else {
    df <- merge(data.frame(stringsAsFactors = FALSE, id = seq_len(length(dbh)), dbh, genus, coords),
      params,
      by = c("genus", "long", "lat")
    )
  }

  df <- df[order(df$id), ]
  agb <- df$a * df$dbh^df$b

  return(agb)
}
