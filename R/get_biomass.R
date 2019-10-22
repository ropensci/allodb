get_biomass = function(dbh = NULL,
                       h = NULL,
                       dba = NULL,
                       BA = NULL,
                       species = NULL,
                       genus = NULL,
                       family = NULL,
                       conif = FALSE,
                       coords = NULL,
                       var = "Total aboveground biomass") {
  if (is.null(dbh) & is.null(dba))
    stop("You need to provide either DBH or DBA.")

  load("data/equations.rda")
  equations = subset(equations, dependent_variable == var)
  if (is.null(dba))
    equations = subset(equations, !independent_variable == "DBA")
  if (is.null(h) | is.null(dbh))
    equations = subset(equations, !independent_variable == "DBH, H")
  if (is.null(dbh))
    equations = subset(equations, !independent_variable == "DBH")
  if (is.null(BA))
    equations = subset(equations, !independent_variable == "BA")

  # transform columns to numeric
  numeric_columns = c(
    "lat",
    "long",
    "elev_m",
    "dbh_min_cm",
    "dbh_max_cm",
    "sample_size",
    "dbh_unit_convert",
    "units_original_convert",
    "r_squared"
  )
  suppressWarnings(equations[, numeric_columns] <-
                     apply(equations[, numeric_columns], 2, as.numeric))

  agb_all = rep(0, nrow(equations))
  # modifiy allometry to insert unit conversion
  for (i in 1:nrow(equations)) {
    orig_equation = equations$equation_allometry[i]
    new_dbh = paste0("dbh*", equations$dbh_unit_convert[i])
    new_equation = gsub("dbh", new_dbh, orig_equation)
    agb_all[i] = eval(parse(text = new_equation))
  }
  agb_all = agb_all * equations$units_original_convert

  # taxonomical distance
  equations$taxo_dist = equations$allometry_specificity
  equations$taxo_dist[grep("Mixed", equations$taxo_dist)] = "Mixed"
  equations$taxo_dist = factor(
    equations$taxo_dist,
    levels = c("Species", "Genus", "Family",  "Mixed", "Woody species")
  )
  equations$taxo_dist = as.numeric(equations$taxo_dist)
  # TODO: replace with NA if equation is not relevant (different taxon)
  # species name -> get accepted species name + family with package taxize
  equations$taxo_dist[!equations$equation_taxa %in% c(family, genus, species) &
                        equations$allometry_specificity %in% c("Family", "Genus", "Species")] = NA
  # conifers vs hardwood:
  if (conif) {
    equations$taxo_dist[equations$allometry_specificity == "Mixed hardwood"] = NA
  }  else {
    equations$taxo_dist[equations$allometry_specificity == "Mixed conifers"] = NA
  }

  # weight function
  weight = weight_allom(
    Nobs = equations$sample_size,
    dbh = dbh,
    dbhrange = equations[, c("dbh_min_cm", "dbh_max_cm")],
    taxo_dist = equations$taxo_dist
  )

  agb = sum(agb_all * weight, na.rm = TRUE) / sum(weight, na.rm = TRUE)

  return(agb)
}

weight_allom = function(Nobs,
                        dbh,
                        dbhrange,
                        envi_dist = NULL,
                        taxo_dist = NULL,
                        a = 1,
                        b = 0.03) {
  weight_N = a * (1 - exp(-b * Nobs))
  # a : max value that weight_N can reach (here: 1)
  # b=0.03 -> we reach 95% of the max value of weight_N when Nobs = log(20)/0.03 = 100
  # implication: new observations will not increase weight_N much when Nobs > 100

  meanD = rowMeans(dbhrange)
  sdD = apply(dbhrange, 1, diff) / 4
  weight_D = dnorm(dbh, meanD, sdD) / dnorm(meanD, meanD, sdD)
  ## we use a weight proportional to the expected distribution density of DBH of trees
  ## measured for each equation. The only information we have is the dbh range.
  ## We hypothesize that measured DBH have a normal distribution and that the
  ## mean is the middle of the dbh range, and the sd is dbhrange/4 so that all
  ## measurements are in the 95% confidence interval of the distribution.
  ## We then divide by dnorm(meanD, modeD, sdD) so that max(weight_D) = 1.

  weight_E = 0   # environmental distance

  weight_T = 1 / taxo_dist      # taxonomical distance

  return(weight_N + weight_D + weight_E + weight_T)

}


#### test ####
dbh = 10
h = NULL
dba = NULL
BA = NULL
species = "Quercus ilex"
genus = "Quercus"
family = "Fagaceae"
conif = FALSE
coords = NULL
var = "Total aboveground biomass"

not_na = which(!is.na(weight))
plot(agb_all[not_na], weight[not_na])
text(agb_all[not_na], weight[not_na], 1:nrow(equations)[not_na])
