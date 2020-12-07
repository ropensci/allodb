#' Function to calibrate new allometric equations from sampling previous ones
#'
#' This function creates S3 objects of class "numeric".
#'
#' @param genus A character vector, containing the genus (e.g. "Quercus") of
#'   each tree. Default is NULL, when no identification is available.
#' @param species A character vector (same length as genus), containing the
#'   species (e.g. "rubra")  of each tree. Default is NULL, when no
#'   identification is available.
#' @param coords A numerical vector of length 2 with longitude and latitude (if
#'   all trees were measured in the same location) or a matrix with 2 numerical
#'   columns giving the coordinates of each tree.
#' @param new_equations Optional. An equation table created with the
#'   add_equation() function. Default is the base allodb equation table.
#' @param wna this parameter is used in the weighting function to determine the
#'   dbh-related and sample-size related weights attributed to equations without
#'   a specified dbh range or sample size, respectively. Default is 0.1
#' @param wsteep this parameter controls the steepness of the dbh-related weight
#'   in the weighting function. Default is 3.
#' @param w95 this parameter is used in the weighting function to determine the
#'   value at which the sample-size-related weight reaches 95% of its maximum
#'   value (max=1). Default is 500.
#'
#' @return A data frame xxx
#' @export
#'
#' @examples
#' data(scbi_stem1)
#' weight_allom(
#'   genus = scbi_stem1$genus,
#'   species = scbi_stem1$species,
#'   coords = c(-78.2, 38.9)
#' )
#'
est_params <- function(genus,
                       species = NULL,
                       coords,
                       new_equations = NULL,
                       wna = 0.1,
                       wsteep = 3,
                       w95 = 500
) {

  ## get equations
  data("equations", envir = environment())
  dfequation <- equations
  if (!is.null(new_equations)) {
    dfequation <- new_equations
  }

  dfequation <-
    subset(
      dfequation,
      dependent_variable %in% c(
        "Total aboveground biomass",
        "Whole tree (above stump)" & independent_variable == "DBH"
      )
    )
  # transform columns to numeric
  suppressWarnings(dfequation$dbh_min_cm <-
                     as.numeric(dfequation$dbh_min_cm))
  suppressWarnings(dfequation$dbh_max_cm <-
                     as.numeric(dfequation$dbh_max_cm))
  suppressWarnings(dfequation$sample_size <-
                     as.numeric(dfequation$sample_size))
  suppressWarnings(dfequation$dbh_unit_CF <-
                     as.numeric(dfequation$dbh_unit_CF))
  suppressWarnings(dfequation$output_units_CF <-
                     as.numeric(dfequation$output_units_CF))

  ## get all combinations of species x site
  if (length(unlist(coords)) == 2) {
    coordsSite <- t(as.numeric(coords))
  } else if (length(unlist(unique(coords))) == 2) {
    coordsSite <- t(apply(unique(coords), 2, as.numeric))
  } else {
    coordsSite <- apply(unique(coords), 2, as.numeric)
  }
  dfobs = unique(data.table::data.table(genus, species, coordsSite))

  for (i in 1:nrow(dfobs)) {
    weights <- weight_allom(genus = dfobs$genus[i],
                            species = dfobs$species[i],
                            coords = dfobs[i, c("V1", "V2")],
                            new_equations = new_equations,
                            wna = wna,
                            wsteep = wsteep,
                            w95 = w95)
    dfequation$resample = floor(c(weights)*1e4)  ## check order or change weight_allom function to have names in output
    dfsub = subset(dfequation, resample > 0)[, c(
      "dbh_min_cm",
      "dbh_max_cm",
      "resample",
      "equation_allometry",
      "dbh_unit_CF",
      "output_units_CF"
    )]
    dfsub$dbh_min_cm[is.na(dfsub$dbh_min_cm)] <- 1
    dfsub$dbh_max_cm[is.na(dfsub$dbh_max_cm)] <- 200
    list_dbh = apply(dfsub[, 1:3], 1, function(X) runif(X[3], X[1], X[2]))

    ### adapt code below to get biomass

    list_agb <- lapply(1:length(list_dbh), function(j) {
      sampled_dbh = list_dbh[[j]]
      orig_equation <- dfsub$equation_allometry[j]
      new_dbh <- paste0("(sampled_dbh*", dfsub$dbh_unit_CF[j], ")")
      new_equation <- gsub("dbh|DBH", new_dbh, orig_equation)
      agb <- eval(parse(text = new_equation)) * dfsub$output_units_CF[j]
    })

  }



}
