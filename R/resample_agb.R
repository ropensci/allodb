#' Resample \pkg{allodb} equations to calibrate new allometries.
#'
#' After attributing a weight to each equation in \pkg{allodb}
#' using the `weight_allom()`
#' function, equations are then resampled within their original DBH range using
#' `resample_agb()`: the number of resampled values for each equation is
#' proportional to its weight. It creates S3 objects of class "numeric".
#'
#' @param genus a character value, containing the genus (e.g. "Quercus") of the
#'   tree.
#' @param coords a numeric vector of length 2 with longitude and latitude.
#' @param species a character value, containing the species (e.g. "rubra") of
#'   the tree. Default is "NULL", when no species identification is available.
#' @param new_eqtable Optional. An equation table created with the
#'  `new_equations()` function. Default is the original \pkg{allodb}
#' equation table.
#' @param wna a numeric vector, this parameter is used in the `weight_allom()` function to determine
#' the dbh-related and sample-size related weights attributed
#' to equations without a specified dbh range or sample size,
#' respectively. Default is 0.1
#' @param w95 a numeric vector, this parameter is used in the `weight_allom()` function to determine
#'   the value at which the sample-size-related weight reaches 95% of its
#'   maximum value (max=1). Default is 500.
#' @param nres number of resampled values. Default is "1e4".
#'
#' @return A data frame (`tibble::tibble()` object) of resampled DBHs and associated AGB from the equation
#'   table; the number of  resampled DBHs is proportional to the weight provided
#'   by the `weight_allom()` function.
#'
#' @seealso [weight_allom()], [new_equations()]
#'
#' @export
#'
#' @examples
#' resample_agb(
#'   genus = "Quercus",
#'   species = "rubra",
#'   coords = c(-78.2, 38.9)
#' )
resample_agb <- function(genus,
                         coords,
                         species = NULL,
                         new_eqtable = NULL,
                         wna = 0.1,
                         w95 = 500,
                         nres = 1e4) {
  if (length(genus) > 1 | length(unlist(coords)) != 2) {
    stop("This function should not be used for several taxa
         and/or locations at once.")
  }

  if (!is.null(new_eqtable)) {
    dfequation <- new_eqtable
  } else {
    dfequation <- new_equations()
  }

  weights <- weight_allom(
    genus = genus,
    species = species,
    coords = coords,
    new_eqtable = dfequation,
    wna = wna,
    w95 = w95
  )
  weights <- data.table::data.table(
    weight = weights,
    equation_id = names(weights)
  )
  if ("weight" %in% colnames(dfequation)) {
    dfequation$weight <- NULL
  }
  dfequation <- merge(dfequation, weights, by = "equation_id")
  dfequation$weight <- dfequation$weight / sum(dfequation$weight)
  dfequation$resample <- floor(dfequation$weight * nres)
  dfsub <- subset(dfequation, resample > 0)[, c(
    "dbh_min_cm",
    "dbh_max_cm",
    "resample",
    "equation_id",
    "equation_allometry",
    "dbh_unit_cf",
    "output_units_cf",
    "equation_taxa"
  )]
  dfsub$dbh_min_cm[is.na(dfsub$dbh_min_cm)] <- 1
  dfsub$dbh_max_cm[is.na(dfsub$dbh_max_cm)] <- 200
  list_dbh <- apply(dfsub[, 1:3], 1, function(x) {
    withr::with_seed(40, stats::runif(x[3], x[1], x[2]))
  })

  ## if possible, introduce some randomness
  ## when we have some information from the allometry: use it,
  ## otherwise use a conservative sigma
  if (nrow(dfsub) == 1) {
    ## only 1 equation selected
    list_dbh <- c(list_dbh)
    sampled_dbh <- list_dbh
    orig_equation <- dfsub$equation_allometry
    new_dbh <- paste0("(sampled_dbh * ", dfsub$dbh_unit_cf, ")")
    new_equation <- gsub("dbh|DBH", new_dbh, orig_equation)
    list_agb <-
      eval(parse(text = new_equation)) * dfsub$output_units_cf
  } else {
    list_agb <- lapply(seq_len(length(list_dbh)), function(j) {
      sampled_dbh <- list_dbh[[j]]
      orig_equation <- dfsub$equation_allometry[j]
      new_dbh <- paste0("(sampled_dbh * ", dfsub$dbh_unit_cf[j], ")")
      new_equation <- gsub("dbh|DBH", new_dbh, orig_equation)
      agb <-
        eval(parse(text = new_equation)) * dfsub$output_units_cf[j]
    })
  }

  equation_id <-
    unlist(lapply(seq_len(nrow(dfsub)), function(i) {
      rep(dfsub$equation_id[i], each = dfsub$resample[i])
    }))

  df <- tibble::tibble(equation_id,
    dbh = unlist(list_dbh),
    agb = unlist(list_agb)
  )
  return(df)
}
