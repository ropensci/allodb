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
#' @param var What dependent variable should be provided in the output? Default
#'   is "Total aboveground biomass", other possible values are: "Bark biomass",
#'   "Branches (dead)", "Branches (live)", "Branches total (live, dead)",
#'   "Foliage total", "Height", "Leaves", "Stem (wood only)", "Stem biomass",
#'   "Stem biomass (with bark)", "Stem biomass (without bark)", "Whole tree
#'   (above and belowground)" , "Whole tree (above stump)". Be aware that only a
#'   few equations exist for those other variables, so estimated values might
#'   not be very acurate.
#' @param add_weight Should the relative weigth given to each equation in the
#'   `equations` data frame be added to the output? Default is FALSE.
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
                       genus = NULL,
                       species = NULL,
                       coords = NULL,
                       var = "Total aboveground biomass",
                       add_weight = FALSE) {
  library(data.table)
  load("data/equations.rda")
  load("data/taxo_weight.rda")
  ## temp - make sure all matrices have the same equations in the same order
  ## while equation table changes regularly
  equations_ids = equations$equation_id
  equations_ids = equations_ids[!is.na(equations_ids)]
  equations_ids = equations_ids[equations_ids %in% colnames(taxo_weight)[-1]]
  equations = subset(equations, equation_id %in% equations_ids)
  taxo_weight = taxo_weight[, c("nameC", equations$equation_id)]

  ## keep only useful equations
  equations = subset(equations, dependent_variable == var)
  if (is.null(h))
    equations = subset(equations,!independent_variable == "DBH, H")

  # transform columns to numeric
  suppressWarnings(equations$dbh_min_cm <-
                     as.numeric(equations$dbh_min_cm))
  suppressWarnings(equations$dbh_max_cm <-
                     as.numeric(equations$dbh_max_cm))
  suppressWarnings(equations$sample_size <-
                     as.numeric(equations$sample_size))
  suppressWarnings(equations$dbh_unit_CF <-
                     as.numeric(equations$dbh_unit_CF))
  suppressWarnings(equations$output_units_CF <-
                     as.numeric(equations$output_units_CF))

  agb_all = matrix(0, nrow = length(dbh), ncol = nrow(equations))
  # modifiy allometry to insert unit conversion
  for (i in 1:nrow(equations)) {
    orig_equation = equations$equation_allometry[i]
    new_dbh = paste0("(dbh*", equations$dbh_unit_CF[i], ")")
    new_equation = gsub("dbh|DBH", new_dbh, orig_equation)
    agb_all[, i] = eval(parse(text = new_equation)) * equations$output_units_CF[i]
  }

  # taxonomic distance - for now only at the genus level
  # TODO check that all species have an associated equation
  ## order by equation id, according to order in equation table
  names = paste(genus, species)
  names = gsub(" $| NA$", "", names) # remove space and NAs at the end of genus names
  idx = sapply(names, function(n)
    which(taxo_weight$nameC == n))
  ## replace integer(0) by NA -> taxo_weight = 1e-6 for all equations
  idx[sapply(idx, length) == 0] <- NA
  idx = unlist(idx)
  if (sum(!is.na(idx)) == 0) {
    ## when no species are in the table: only NAs (gives problem with data.table), do it manually
    taxo_weight_census = data.table(matrix(
      1e-6,
      ncol = ncol(taxo_weight) - 1,
      nrow = length(idx)
    ))
    colnames(taxo_weight_census) = colnames(taxo_weight)[-1]
  } else
    taxo_weight_census = taxo_weight[idx,-1]
  # replace all NAs with 1e-6 (used only of no other equation is available)
  for (col in names(taxo_weight_census))
    set(
      taxo_weight_census,
      i = which(is.na(taxo_weight_census[[col]])),
      j = col,
      value = 1e-6
    )

  # koppen climate
  # (1) get koppen climate for all locations
  # koppen climate raster downloaded from http://koeppen-geiger.vu-wien.ac.at/present.htm on the 2/10/2020
  load("data/koppenRaster.rda")
  load("data/koppenMatrix.rda")
  # if only one location, transform coords into matrix with 2 numeric columns
  if (length(coords) == 2) {
    coordsSite = t(as.numeric(coords))
  } else
    coordsSite = apply(unique(coords), 2, as.numeric)
  ## extract koppen climate of every location
  climates = koppenRaster@data@attributes[[1]][, 2]
  koppenSites = climates[raster::extract(koppenRaster, coordsSite)]
  ## climate similitude matrix (rows: sites, columns: equations)
  koppen_simil = t(sapply(koppenSites, function (z1) {
    m = subset(koppenMatrix, zone1 == z1)
    sapply(equations$koppen, function(z2) {
      all_z2 = unlist(strsplit(z2, "; "))
      max(c(subset(m, zone2 %in% all_z2)$simil, 0))
    })
  }))
  if (length(coords) == 2) {
    n = length(dbh)
    koppen_simil = matrix(rep(koppen_simil, n), nrow = n, byrow = TRUE)
  } else {
    koppen_simil = t(apply(coords, 1, function(c)
      koppen_simil[which(coordsSite[, 1] == c[1] &
                           coordsSite[, 2] == c[2]), ]))
  }

  # weight function
  ## TODO solve NA sample size and dbh range problem
  weight = weight_allom(
    Nobs = equations$sample_size,
    dbh = dbh,
    dbhrange = equations[, c("dbh_min_cm", "dbh_max_cm")],
    weight_T = taxo_weight_census,
    weight_E = koppen_simil
  )
  relative_weight = weight / matrix(rowSums(weight, na.rm = TRUE),
                                    nrow = length(dbh),
                                    ncol = nrow(equations))

  agb = rowSums(agb_all * relative_weight, na.rm = TRUE)

  if (!add_weight) {
    return(agb)
  } else
    return(cbind(agb, relative_weight))
}

weight_allom = function(Nobs,
                        dbh,
                        dbhrange,
                        weight_E = 1,
                        weight_T = 1,
                        replace_dbhrange = 0.1,
                        ## wieght value in weight_D matrix when there is no DBH range for the equation
                        a = 1,
                        b = 0.03,
                        steep = 3  ## controls the steepness of the dbh range transition, should be > 1
) {
  Nobs = as.numeric(Nobs)
  Nobs = matrix(Nobs,
                nrow = length(dbh),
                ncol = length(Nobs),
                byrow = TRUE)
  weight_N = a * (1 - exp(-b * Nobs))
  # a : max value that weight_N can reach (here: 1)
  # b=0.03 -> we reach 95% of the max value of weight_N when Nobs = log(20)/0.03 = 100
  # implication: new observations will not increase weight_N much when Nobs > 100

  dbhrange = matrix(as.numeric(unlist(dbhrange)), ncol = 2)
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
  Mdbh = log(matrix(dbh, nrow = length(dbh), ncol = nrow(dbhrange)))
  Mmin = log(matrix(
    dbhrange[, 1],
    nrow = length(dbh),
    ncol = nrow(dbhrange),
    byrow = TRUE
  ))
  Mmax = log(matrix(
    dbhrange[, 2],
    nrow = length(dbh),
    ncol = nrow(dbhrange),
    byrow = TRUE
  ))
  weight_D = (1 - abs((Mdbh - (Mmin + Mmax) / 2) / (Mmax - Mmin)) ^ steep) ^ 3
  weight_D[weight_D < 0] = 0   ## keep only positive values, transform values < 0 into 0
  weight_D[, which(apply(weight_D, 2, anyNA))] = replace_dbhrange ## weight (independent of DBH) when equation does not have DBH range

  # multiplicative weights: if one is zero, the total weight should be zero too
  return(weight_N * weight_D * weight_E * weight_T)
}
