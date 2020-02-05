get_biomass = function(dbh,  ## in cm
                       h = NULL, # same size as dbh
                       genus = NULL,   # same size as dbh
                       species = NULL, # same size as dbh
                       family = NULL,  # same size as dbh
                       conif = FALSE,  # same size as dbh
                       coords = NULL,  # a vector of length 2 (longitude+latitude)
                       var = "Total aboveground biomass") {

  load("data/equations.rda")
  equations = subset(equations, dependent_variable == var)
  if (is.null(h))
    equations = subset(equations, !independent_variable == "DBH, H")


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

  agb_all = matrix(0, nrow = length(dbh), ncol = nrow(equations))
  # modifiy allometry to insert unit conversion
  for (i in 1:nrow(equations)) {
    orig_equation = equations$equation_allometry[i]
    new_dbh = paste0("(dbh*", equations$dbh_unit_CF[i],")")
    new_equation = gsub("dbh|DBH", new_dbh, orig_equation)
    agb_all[,i] = eval(parse(text = new_equation)) * equations$output_units_CF[i]
  }
  # TODO check why there is so much variation in outputs...

  # taxonomic distance - for now only at the genus level
  # TODO add species (genus = node) and families
  # TODO deal with large groups such as 'mixed hardwood'... = nightmare
  load("data/taxo_dmatrix.rda")

  genus_in_matrix = sapply(tolower(genus), function(g) which(rownames(dmatrix)==g))

  equations$genus = unlist(lapply(strsplit(equations$equation_taxa, " "), first))
  equations$genus = tolower(equations$genus)
  eq_in_matrix = sapply(equations$genus, function(g){
    x=which(colnames(dmatrix)==g)
    if (length(x)==0) x = NA
    return(x)
  })
  taxo_dist = dmatrix[genus_in_matrix,eq_in_matrix]

  # weight function
  weight = weight_allom(
    Nobs = equations$sample_size,
    dbh = dbh,
    dbhrange = equations[, c("dbh_min_cm", "dbh_max_cm")],
    taxo_dist = taxo_dist
  )
  relative_weight = weight/matrix(rowSums(weight, na.rm = TRUE), nrow=length(dbh), ncol=nrow(equations))

  agb = rowSums(agb_all * relative_weight, na.rm = TRUE)

  return(agb)
}

weight_allom = function(Nobs,
                        dbh,
                        dbhrange,
                        envi_dist = NULL,
                        taxo_dist = NULL,
                        a = 1,
                        b = 0.03,
                        steep = 4, ## controls the steepness of the dbh range transition, should be > 1
                        lambda = 2) {

  Nobs = matrix(Nobs, nrow=length(dbh), ncol=length(Nobs), byrow = TRUE)
  weight_N = a * (1 - exp(-b * Nobs))
  # a : max value that weight_N can reach (here: 1)
  # b=0.03 -> we reach 95% of the max value of weight_N when Nobs = log(20)/0.03 = 100
  # implication: new observations will not increase weight_N much when Nobs > 100

  midD = rowMeans(dbhrange)
  difD = apply(dbhrange, 1, diff) / 2
  ## This weight function is inspired of the tricube weight function in local regressions
  ## it equals 1 inside the dbh range, quickly drops to 0 outside the dbh range.
  # steep controls how fast the weight decreases at the edges of the dbh range.
  # See: curve((1-abs((x-midD)/difD)^15)^3, xlim=c(dbhrange))
  Mdbh = matrix(dbh, nrow=length(dbh), ncol=length(midD))
  MmidD = matrix(midD, nrow=length(dbh), ncol=length(midD), byrow=TRUE)
  MdifD = matrix(difD, nrow=length(dbh), ncol=length(midD), byrow=TRUE)
  weight_D =  (1-abs((Mdbh-MmidD)/MdifD)^steep)^3
  # no negative value
  weight_D[which(weight_D<0)] = 0

  weight_E = 1  # environmental distance

  weight_T = exp(-lambda*taxo_dist)      # taxonomic distance
  # lambda controls how the weight decreases with taxonomic distance:
  # the higher lambda, the lower the weight of distant relatives

  # multiplicative weights: if one is zero, the total weight should be zero too
  return(weight_N * weight_D * weight_E * weight_T)

}


#### test ####
library(data.table)
data = data.table(expand.grid(dbh=1:200, genus=c("Acer", "Prunus", "Fraxinus","Quercus")))
data[, agb := get_biomass(dbh=data$dbh, genus=data$genus)/1000]
library(BIOMASS)
data$wsg = getWoodDensity(genus = data$genus, species=rep("sp", nrow(data)))$meanWD
data[, agb_chave := exp(-2.023977 - 0.89563505 * 0.5 + 0.92023559 * log(wsg) + 2.79495823 * log(dbh) - 0.04606298 * (log(dbh)^2))/1000]

logscale = FALSE
library(ggplot2)
g = ggplot(data, aes(x=dbh, y=agb, color=genus)) +
  geom_line() +
  geom_line(aes(y=agb_chave), lty=2) +
  labs(y="AGB (tons)") +
  geom_text(x=10,y=40, label="Dotted lines: Chave equation with E = 0.5")
if (logscale)
  g = g + scale_x_log10() + scale_y_log10()
g
ggsave("get_biomass_plot.pdf")
