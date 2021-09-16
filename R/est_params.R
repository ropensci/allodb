#' Calibrate new allometric equations
#'
#' This function calibrates new allometric equations from sampling previous
#' ones. New allometric equations are calibrated for each species and location
#' by resampling the original compiled equations; equations with a larger sample
#' size, and/or higher taxonomic rank, and climatic similarity with the species
#' and location in question are given a higher weight in this process.
#' @param genus a character vector, containing the genus (e.g. "Quercus") of
#'   each tree.
#' @param coords a numeric vector of length 2 with longitude and latitude (if
#'   all trees were measured in the same location) or a matrix with 2 numerical
#'   columns giving the coordinates of each tree.
#' @param species a character vector (same length as genus), containing the
#'   species (e.g. "rubra")  of each tree. Default is `NULL`, when no species
#'   identification is available.
#' @param new_eqtable Optional. An equation table created with the
#'   `new_equations()` function. Default is the compiled \pkg{allodb}  equation table.
#' @param wna a numeric vector, this parameter is used in the `weight_allom()` function to determine
#'   the dbh-related and sample-size related weights attributed to equations
#'   without a specified dbh range or sample size, respectively. Default is 0.1
#' @param w95 a numeric vector, this parameter is used in the `weight_allom()` function to determine
#'   the value at which the sample-size-related weight reaches 95% of its
#'   maximum value (max=1). Default is 500.
#' @param nres number of resampled values. Default is "1e4".
#'
#' @return A data frame (`tibble::tibble()` object) of fitted coefficients (columns) of the non-linear
#'  least-square regression \deqn{AGB = a * dbh ^ b + e, \space \mathit{with} \space e ~ N(0, sigma^2)}{AGB = a * dbh ^ b + e, with e ~ N(0, sigma^2)}
#'
#' @seealso [weight_allom()], [new_equations()]
#'
#' @export
#'
#' @examples
#' # calibrate new allometries for all Lauraceae species
#' lauraceae <- subset(scbi_stem1, Family == "Lauraceae")
#' est_params(
#'   genus = lauraceae$genus,
#'   species = lauraceae$species,
#'   coords = c(-78.2, 38.9)
#' )
est_params <- function(genus,
                       coords,
                       species = NULL,
                       new_eqtable = NULL,
                       wna = 0.1,
                       w95 = 500,
                       nres = 1e4
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
  for (i in seq_len(nrow(dfobs))) {
    df <- resample_agb(genus = dfobs$genus[i],
                       species = dfobs$species[i],
                       coords = dfobs[i, c("long", "lat")],
                       new_eqtable = dfequation,
                       wna = wna,
                       w95 = w95,
                       nres = nres)
    ## special case: only one equation is resampled and it's of the form a*x^b
    ## nls will throw an error: add some 'grain' by adding 1 slightly different
    ## data point (it won't change the final results)
    if (length(unique(df$equation_id)) == 1) df[1, 3] <- df[1, 3] * 1.01
    reg <- summary(stats::nls(agb ~ a * dbh ** b,
          start = c(a = 0.5, b = 2), data = df))
    coefs <- rbind(coefs, c(reg$coefficients[, "Estimate"], reg$sigma))
  }
  colnames(coefs) <- c("a", "b", "sigma")

  return(tibble::as_tibble(cbind(dfobs, coefs)))
}
