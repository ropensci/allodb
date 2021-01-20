#' Calibrate new allometric equations
#'
#' This function calibrates new allometric equations from sampling previous ones. New allometric equations are calibrated for each species and location by resampling the original compiled equations; equations with a larger sample size, and/or higher taxonomic rank, and climatic similarity with the species and location in question are given a higher weight in this process.
#' @param genus a character vector, containing the genus (e.g. "Quercus") of
#'   each tree.
#' @param species a character vector (same length as genus), containing the
#'   species (e.g. "rubra")  of each tree. Default is NULL, when no species
#'   identification is available.
#' @param coords a numerical vector of length 2 with longitude and latitude (if
#'   all trees were measured in the same location) or a matrix with 2 numerical
#'   columns giving the coordinates of each tree.
#' @param new_eqtable Optional. An equation table created with the
#'   add_equation() function. Default is the compiled allo-db equation table.
#' @param wna this parameter is used in the weight_allom() function to determine the
#'   dbh-related and sample-size related weights attributed to equations without
#'   a specified dbh range or sample size, respectively. Default is 0.1
#' @param w95 this parameter is used in the weight_allom() function to determine the
#'   value at which the sample-size-related weight reaches 95% of its maximum
#' value (max=1). Default is 500.
#' @param Nres number of resampled values. Default is 1e4.
#'
#' @return A data frame of fitted coefficients (columns) of the log-log
#'   regression: a (intercept), b (slope) and sigma (standard deviation). Each
#'   row corresponds to a species x site combination. The back-transformed
#'   equation is then AGB = exp(a) x DBH^b x + exp(0.5 x sigma^2).
#' @export
#'
#' @examples
#' data(scbi_stem1)
#' est_params(
#'   genus = scbi_stem1$genus,
#'   species = scbi_stem1$species,
#'   coords = c(-78.2, 38.9)
#' )
#'
est_params <- function(genus,
                       species = NULL,
                       coords,
                       new_eqtable = NULL,
                       wna = 0.1,
                       w95 = 500,
                       Nres = 1e4
) {

  if (!is.null(new_eqtable)) {
    dfequation <- new_eqtable
  } else dfequation <- new_equations()

  ## get all combinations of species x site
  if (length(unlist(coords)) == 2) {
    coords <- t(as.numeric(coords))
  }
  colnames(coords) <- c("long", "lat")
  dfobs <- unique(data.table::data.table(genus, species, coords))

  coefs <- c()
  for (i in 1:nrow(dfobs)) {
    df <- resample_agb(genus = dfobs$genus[i],
                       species = dfobs$species[i],
                       coords = dfobs[i, c("long","lat")],
                       new_eqtable = dfequation,
                       wna = wna,
                       w95 = w95,
                       Nres = Nres)

    reg <- summary(lm(log(agb) ~ log(dbh), data = df))
    coefs <- rbind(coefs, c(reg$coefficients[, "Estimate"], reg$sigma))
  }
  colnames(coefs) <- c("a", "b", "sigma")

  return(cbind(dfobs, coefs))
}
