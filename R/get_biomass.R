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
#'   (e.g. "Quercus") of each tree. Default is NULL, when no identification is
#'   available.
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
#' @param new_equations Optional. An equation table created with the
#'   add_equation() function.
#' @param var What dependent variable(s) should be provided in the output?
#'   Default is `Total aboveground biomass` and `Whole tree (above stump)`,
#'   other possible values are: `Bark biomass`, `Branches (dead)`, `Branches
#'   (live)`, `Branches total (live, dead)`, `Foliage total`, `Height`,
#'   `Leaves`, `Stem (wood only)`, `Stem biomass`, `Stem biomass (with bark)`,
#'   `Stem biomass (without bark)`, `Whole tree (above and belowground)`. Be
#'   aware that only a few equations exist for those other variables, so
#'   estimated values might not be very accurate.
#' @param add_weight Should the relative weight given to each equation in the
#'   `equations` data frame be added to the output? Default is FALSE.
#' @param use_height_allom A logical value: should the height allometries from
#'   Bohn et al (2014) be used in the AGB allometries from Jansen et al (1996)?
#'   Default is TRUE.
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
                        h = NULL,
                        genus = rep(NA, length(dbh)),
                        species = NULL,
                        shrub = NULL,
                        coords,
                        new_equations = NULL,
                        var = c("Total aboveground biomass", "Whole tree (above stump)"),
                        add_weight = FALSE,
                        use_height_allom = TRUE,
                        wna = 0.1,
                        wsteep = 3,
                        w95 = 500) {
  data("equations", envir = environment())
  dfequation <- equations
  if (!is.null(new_equations)) {
    dfequation <- new_equations
  }

  ## replace height with height allometry from Bohn et al. 2014 in Jansen et al 1996
  if (use_height_allom & "jansen_1996_otvb" %in% dfequation$ref_id) {
    eq_jansen <- subset(equations, ref_id == "jansen_1996_otvb")
    ## height allometries defined per genus -> get info in Jansen allometries
    eq_jansen$genus <- data.table::tstrsplit(eq_jansen$equation_notes, " ")[[5]]
    ## create height allometry dataframe
    hallom <- subset(equations, ref_id == "bohn_2014_ocai" & dependent_variable == "Height")
    hallom <- hallom[, c("equation_taxa", "equation_allometry")]
    colnames(hallom) <- c("genus", "hsub")
    ## merge with jansen allometries (equations that do not have a corresponding height allometry will not be substituted)
    eq_jansen <- merge(eq_jansen, hallom, by = "genus")
    # substitute H by its DBH-based estimation
    toMerge <- eq_jansen[, c("hsub", "equation_allometry")]
    eq_jansen$equation_allometry <- apply(toMerge, 1, function(X) {
      gsub("\\(h", paste0("((", X[1], ")"), X[2])
    })
    # replace independent_variable column
    eq_jansen$independent_variable <- "DBH"
    # replace in equation table
    dfequation <- rbind(
      subset(dfequation, !equation_id %in% eq_jansen$equation_id),
      eq_jansen[, colnames(dfequation)]
    )
  }

  equations_ids <- dfequation$equation_id
  equations_ids <- equations_ids[!is.na(equations_ids)]
  dfequation <- subset(dfequation, equation_id %in% equations_ids)

  ## keep only useful equations
  dfequation <- subset(dfequation, dependent_variable %in% var)
  if (is.null(h)) {
    dfequation <- subset(dfequation, !independent_variable == "DBH, H")
  }

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

  agb_all <- matrix(0, nrow = length(dbh), ncol = nrow(dfequation))
  # modifiy allometry to insert unit conversion
  for (i in 1:nrow(dfequation)) {
    orig_equation <- dfequation$equation_allometry[i]
    new_dbh <- paste0("(dbh*", dfequation$dbh_unit_CF[i], ")")
    new_equation <- gsub("dbh|DBH", new_dbh, orig_equation)
    agb_all[, i] <- eval(parse(text = new_equation)) * dfequation$output_units_CF[i]
  }
  ## remove some absurdly low or high values given by some equations when outside of their dbh range
  agb_all[!is.na(agb_all) & (agb_all < 0 | agb_all > 1e6)] <- NA

  # weight function
  weight <- weight_allom(
    dbh = dbh,
    coords = coords,
    genus = genus,
    species = species,
    new_equations = dfequation,
    wna = wna,
    w95 = w95,
    wsteep = wsteep
  )
  relative_weight <- weight / matrix(rowSums(weight, na.rm = TRUE),
    nrow = length(dbh),
    ncol = nrow(dfequation)
  )

  agb <- rowSums(agb_all * relative_weight, na.rm = TRUE)
  agb[is.na(dbh)] <- NA

  if (!add_weight) {
    return(agb)
  } else {
    return(cbind(agb, relative_weight))
  }
}


