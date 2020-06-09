#' Function to compute aboveground biomass (or other variables ) from allometric
#' equations.
#'
#' This function creates S3 objects of class "numeric".
#'
#' @param dbh A numerical vector containing tree diameter at breast height (dbh)
#'   measurements, in cm
#' @param h A numerical vector (same length as dbh) containing tree height
#'   measurements, in m. Default is NULL, when no measurement is available.
#' @param genus A character vector (same length as dbh), containing the genus
#'   (e.g. "Quercus") of each tree. Default is NULL, when no identification is
#'   available.
#' @param species A character vector (same length as dbh), containing the
#'   species (e.g. "rubra")  of each tree. Default is NULL, when no
#'   identification is available.
#' @param coords A numerical vector of length 2 with longitude and latitude (if
#'   all trees were measured in the same location) or a matrix with 2 numerical
#'   columns giving the coordinates of each tree. Default is NULL when no
#'   information is available.
#' @param new_equations Optional. An equation table created with the xxx function.
#' @param var What dependent variable(s) should be provided in the output? Default
#'   is `Total aboveground biomass` and `Whole tree (above stump)`, other possible values are:
#'   `Bark biomass`, `Branches (dead)`, `Branches (live)`, `Branches total (live, dead)`,
#'   `Foliage total`, `Height`, `Leaves`, `Stem (wood only)`, `Stem biomass`,
#' `Stem biomass (with bark)`, `Stem biomass (without bark)`, `Whole tree (above and belowground)`.
#'  Be aware that only a few equations exist for those other variables, so estimated values might not be
#' very acurate.
#' @param add_weight Should the relative weigth given to each equation in the
#'   `equations` data frame be added to the output? Default is FALSE.
#' @param use_height_allom A logical value: should the height allometries from
#'   Bohn et al (2014) be used in the AGB allometries from Jansen et al (1996)?
#'   Default is TRUE.
#'
#' @return A vector of class "numeric" of the same length as dbh, containing AGB
#'   value (in kg) for every stem, or the dependent variable as defined in
#'   `var`.
#' @export
#'
#' @examples
#' data(scbi_stem1)
#' get_biomass(
#' dbh = scbi_stem1$dbh,
#' genus = scbi_stem1$genus,
#' species = scbi_stem1$species,
#' coords = c(-78.2, 38.9)
#' )
get_biomass = function(dbh,
                       h = NULL,
                       genus = rep(NA, length(dbh)),
                       species = NULL,
                       coords,
                       new_equations = NULL,
                       var = c("Total aboveground biomass", "Whole tree (above stump)"),
                       add_weight = FALSE,
                       use_height_allom = TRUE) {
  data("equations")
  dfequation = equations
  if (!is.null(new_equations))
    dfequation = new_equations

  ## replace height with height allometry from Bohn et al. 2014 in Jansen et al 1996
  if (use_height_allom & "jansen_1996_otvb" %in% dfequation$ref_id) {
    eq_jansen = subset(equations, ref_id=="jansen_1996_otvb")
    ## height allometries defined per genus -> get info in jansen allometries
    eq_jansen$genus = data.table::tstrsplit(eq_jansen$equation.notes, " ")[[5]]
    ## vreate height allometry dataframe
    hallom = subset(equations, ref_id=="bohn_2014_ocai" & dependent_variable == "Height" )
    hallom = hallom[, c("equation_taxa", "equation_allometry")]
    colnames(hallom) = c("genus", "hsub")
    ## merge with jansen allometries (equations that do not have a corresponding height allometry will not be substituted)
    eq_jansen = merge(eq_jansen, hallom, by = "genus")
    # substitute H by its DBH-based estimation
    toMerge = eq_jansen[, c("hsub", "equation_allometry")]
    eq_jansen$equation_allometry = apply(toMerge, 1, function(X) {
      gsub("\\(h", paste0("((", X[1], ")"), X[2])
    })
    # replace independent_variable column
    eq_jansen$independent_variable = "DBH"
    # replace in equation table
    dfequation = rbind(subset(dfequation, !equation_id %in% eq_jansen$equation_id),
                       eq_jansen[, colnames(dfequation)])
  }

  equations_ids = dfequation$equation_id
  equations_ids = equations_ids[!is.na(equations_ids)]
  dfequation = subset(dfequation, equation_id %in% equations_ids)

  ## keep only useful equations
  dfequation = subset(dfequation, dependent_variable %in% var)
  if (is.null(h))
    dfequation = subset(dfequation,!independent_variable == "DBH, H")

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

  agb_all = matrix(0, nrow = length(dbh), ncol = nrow(dfequation))
  # modifiy allometry to insert unit conversion
  for (i in 1:nrow(dfequation)) {
    orig_equation = dfequation$equation_allometry[i]
    new_dbh = paste0("(dbh*", dfequation$dbh_unit_CF[i], ")")
    new_equation = gsub("dbh|DBH", new_dbh, orig_equation)
    agb_all[, i] = eval(parse(text = new_equation)) * dfequation$output_units_CF[i]
  }

  # koppen climate
  # (1) get koppen climate for all locations
  # koppen climate raster downloaded from http://koeppen-geiger.vu-wien.ac.at/present.htm on the 2/10/2020
  data("koppenRaster")
  # if only one location, transform coords into matrix with 2 numeric columns
  if (length(unlist(coords)) == 2) {
    coordsSite = t(as.numeric(coords))
  } else if (length(unlist(unique(coords))) == 2) {
    coordsSite = t(apply(unique(coords), 2, as.numeric))
  } else
    coordsSite = apply(unique(coords), 2, as.numeric)
  ## extract koppen climate of every location
  climates = koppenRaster@data@attributes[[1]][, 2]
  koppenObs = climates[raster::extract(koppenRaster, coordsSite)]

  # weight function
  ## TODO solve NA sample size and dbh range problem
  weight = weight_allom(
    dbh = dbh,
    koppen = koppenObs,
    genus = genus,
    species = species,
    equation_table = dfequation
  )
  relative_weight = weight / matrix(rowSums(weight, na.rm = TRUE),
                                    nrow = length(dbh),
                                    ncol = nrow(dfequation))

  agb = rowSums(agb_all * relative_weight, na.rm = TRUE)

  if (!add_weight) {
    return(agb)
  } else
    return(cbind(agb, relative_weight))
}

weight_allom = function(dbh,
                        koppen = NULL,
                        genus = NULL,
                        species = NULL,
                        equation_table,
                        replace_dbhrange = 0.1,
                        ## wieght value in weight_D matrix when there is no DBH range for the equation
                        a = 1,
                        b = 0.03,
                        steep = 3  ## controls the steepness of the dbh range transition, should be > 1
) {
  dfweights = data.table::setDT(equation_table[, c("equation_id", "sample_size", "dbh_min_cm", "dbh_max_cm", "koppen", "equation_taxa")])
  ## keep equation_id order by making it into a factor
  dfweights$equation_id = factor(dfweights$equation_id)
  ## add observations IDs
  combinations = expand.grid(obs_id = 1:length(dbh), equation_id = equation_table$equation_id)
  dfweights = merge(dfweights, combinations, by  = "equation_id")
  ## add observation info
  dfobs = data.table::data.table(obs_id = 1:length(dbh), dbh, koppenObs = koppen, genus, species)
  dfweights = merge(dfweights, dfobs, by = "obs_id")

  ## weight by sample size ##
  dfweights$wN = a * (1 - exp(-b * as.numeric(dfweights$sample_size)))
  # a : max value that weight_N can reach (here: 1)
  # b=0.03 -> we reach 95% of the max value of weight_N when Nobs = log(20)/0.03 = 100
  # implication: new observations will not increase weight_N much when Nobs > 100
  dfweights$wN[is.na(dfweights$wN)] = 0.1 ## for now: give 0.1 to equations with no samle size; find why they don't have a sample size

  ## weight by dbh range ##
  ## This weight function is inspired of the tricube weight function in local regressions
  ## it equals 1 inside the dbh range, quickly drops to 0 outside the dbh range.
  # steep controls how fast the weight decreases at the edges of the dbh range.
  #
  # f = function(x, min, max, steep=4, pow=3) {
  #   y = (1-abs((x-(min+max)/2)/(max-min))^steep)^pow
  #   return(apply(cbind(0,y), 1, max))
  # }
  # We log-transform it because dbhs are > 0
  # See: curve(f(log(x), log(5), log(20)), xlim=c(0,50)); abline(v=c(5,20))
  dfweights$dmax = as.numeric(dfweights$dbh_max_cm)
  dfweights$dmin = as.numeric(dfweights$dbh_min_cm)
  dfweights$wD = (1 - abs((dfweights$dbh - (as.numeric(dfweights$dmax) + dfweights$dmin) / 2) / (dfweights$dmax - dfweights$dmin)) ^ steep) ^ 3
  dfweights$wD[dfweights$wD < 0 & !is.na(dfweights$wD)] = 0   ## keep only positive values, transform values < 0 into 0
  dfweights$wD[is.na(dfweights$wD)] = replace_dbhrange ## weight (independent of DBH) when equation does not have DBH range

  ### koppen climate weight
  if (is.null(koppen)) {
    dfweights$wE = 1
  } else {
    dfkoppen = unique(dfweights[, c("koppenObs", "koppen")])
    data("koppenMatrix")
    compare_koppen = function(Z) {
      z1 = tolower(Z[1])
      z2 = tolower(unlist(strsplit(Z[2], ", |; |,|;")))
      max(koppenMatrix$wE[tolower(koppenMatrix$zone1)==z1 & tolower(koppenMatrix$zone2)%in%z2])
    }
    dfkoppen$wE = apply(dfkoppen, 1, compare_koppen)
    dfweights = merge(dfweights, dfkoppen, by = c("koppenObs", "koppen"))
  }

  ### taxonomic weight
  if (is.null(genus)) {
    dfweights$wT = 1
  } else {
    dfweights$wT = 1e-6
    # same species
    dfweights$wT[dfweights$equation_taxa == paste(dfweights$genus, dfweights$species)] = 1
    # same genus
    dfweights$wT[dfweights$equation_taxa == dfweights$genus] = 0.8
    ## TODO complete
    # same genus, different species
    # dfweights$wT[dfweights$equation_taxa != paste(dfweights$genus, dfweights$species)] = 0.7
    # # same family
    # dfweights$wT[dfweights$equation_taxa == dfweights$genus] = 0.5
    # # same family, different genus
    # dfweights$wT[dfweights$equation_taxa != paste(dfweights$genus, dfweights$species)] = 0.2
  }

  dfweights$w = dfweights$wN * dfweights$wD * dfweights$wE * dfweights$wT
  # multiplicative weights: if one is zero, the total weight should be zero too
  ## find a way to check order of equations
  data.table::setorder(dfweights, obs_id, equation_id)
  Mw = data.table::dcast(dfweights, obs_id ~ equation_id, value.var = "w")
  data.table::setorder(Mw, obs_id)
  Mw = as.matrix(Mw)[, -1]
  return(Mw)
}
