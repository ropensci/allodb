get_biomass = function(dbh = NULL,
                       h = NULL,
                       species = NULL,
                       genus = NULL,
                       family = NULL,
                       conif = FALSE,
                       coords = NULL,
                       var = "Total aboveground biomass") {
  if (is.null(dbh))
    stop("You need to provide DBH")

  load("data/equations.rda")
  equations = subset(equations, dependent_variable == var)
    if (is.null(h) | is.null(dbh))
    equations = subset(equations, !independent_variable == "DBH, H")
  if (is.null(dbh))
    equations = subset(equations, !independent_variable == "DBH")

  # transform columns to numeric
  numeric_columns = c(
    "lat",
    "long",
    "elev_m",
    "dbh_min_cm",
    "dbh_max_cm",
    "sample_size",
    "dbh_unit_CF",
    "output_units_CF",
    "r_squared"
  )
  suppressWarnings(equations[, numeric_columns] <-
                     apply(equations[, numeric_columns], 2, as.numeric))

  agb_all = rep(0, nrow(equations))
  # modifiy allometry to insert unit conversion
  for (i in 1:nrow(equations)) {
    orig_equation = equations$equation_allometry[i]
    new_dbh = paste0("dbh*", equations$dbh_unit_CF[i])
    new_equation = gsub("dbh", new_dbh, orig_equation)
    agb_all[i] = eval(parse(text = new_equation))
  }
  agb_all = agb_all * equations$output_units_CF

  # taxonomical distance
  # TODO create function that deals with taxonimical distance
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

  midD = rowMeans(dbhrange)
  difD = apply(dbhrange, 1, diff) / 2 / (1-0.5^0.3333)^(1/15)
  weight_D = max(0, (1-abs((dbh-midD)/difD)^15)^3)
  ## This weight function is inspired of the tricube weight function in local regressions
  ## it equals 1 inside the dbh range, quickly drops to 0 outside the dbh range. The parameters
  # were chosen so that weight_D = 0.5 on the dbh range boundaries
  # See: curve((1-abs((x-midD)/difD)^15)^3, xlim=c(dbhrange))

  weight_E = 0   # environmental distance

  weight_T = 1 / taxo_dist      # taxonomical distance

  return(weight_N + weight_D + weight_E + weight_T)

}


#### test ####
dbh = 10
h = NULL
species = "Quercus ilex"
genus = "Quercus"
family = "Fagaceae"
conif = FALSE
coords = NULL
var = "Total aboveground biomass"

not_na = which(!is.na(weight_allom))
#plot(agb_all[not_na], weight[not_na])
#text(agb_all[not_na], weight[not_na], not_na)
