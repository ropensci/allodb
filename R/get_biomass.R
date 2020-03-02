get_biomass = function(dbh,  ## in cm
                       h = NULL,       # same size as dbh
                       genus = NULL,   # same size as dbh
                       species = NULL, # same size as dbh
                       coords = NULL,  # a vector of size 2 (if all trees come from the same location)
                       # or a matrix with 2 columns giving the coordinates (latitude and longitude) of each tree
                       var = "Total aboveground biomass") {

  load("data/equations.rda")
  equations = subset(equations, dependent_variable == var)
  if (is.null(h))
    equations = subset(equations, !independent_variable == "DBH, H")


  # transform columns to numeric
  numeric_columns = c(
    "lat",
    "long",
    # "elev_m",
    "dbh_min_cm",
    "dbh_max_cm",
    "sample_size",
    "dbh_unit_CF",
    "output_units_CF"#,
    # "r_squared"
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

  # taxonomic distance - for now only at the genus level
  # TODO add generic equations
  load("data/taxo_weight.rda")
  names = paste(genus, species)
  names = gsub(" $", "", names) # remove space at the end of genus names
  idx = sapply(names, function(n) which(taxo_weight$nameC==n))
  taxo_weight = taxo_weight[idx, -1]

  # koppen climate
  # (1) get koppen climate for all locations
  # koppen climate raster downloaded from http://koeppen-geiger.vu-wien.ac.at/present.htm on the 2/10/2020
  load("data/koppenRaster.rda")
  load("data/koppenMatrix.rda")
  # if only one location, transform coords into matrix with 2 columns
  if (length(coords) == 2) {
    coordsSite = t(coords)
  } else coordsSite = unique(coords)
  ## extract koppen climate of every location
  climates = koppenRaster@data@attributes[[1]][,2]
  koppenSites = climates[raster::extract(koppenRaster, coordsSite)]
  ## climate similitude matrix (rows: sites, columns: equations)
  koppen_simil = t(sapply(koppenSites, function (z1) {
    m = subset(koppenMatrix, zone1==z1)
    sapply(equations$koppen, function(z2) {
      all_z2 = unlist(strsplit(z2, "; "))
      max(c(subset(m, zone2 %in% all_z2)$simil, 0))
    })
  }))
  if (length(coords) == 2) {
    n=length(dbh)
    koppen_simil = matrix(rep(koppen_simil, n), nrow=n, byrow = TRUE)
  } else {
    koppen_simil = t(apply(coords, 1, function(c)
      koppen_simil[which(coordsSite[,1]==c[1] & coordsSite[,2]==c[2]),]
    ))
  }

  # weight function
  weight = weight_allom(
    Nobs = equations$sample_size,
    dbh = dbh,
    dbhrange = equations[, c("dbh_min_cm", "dbh_max_cm")],
    weight_T = taxo_weight,
    weight_E = koppen_simil
  )
  relative_weight = weight/matrix(rowSums(weight, na.rm = TRUE), nrow=length(dbh), ncol=nrow(equations))

  agb = rowSums(agb_all * relative_weight, na.rm = TRUE)

  return(agb)
}

weight_allom = function(Nobs,
                        dbh,
                        dbhrange,
                        weight_E = 1,
                        weight_T = 1,
                        a = 1,
                        b = 0.03,
                        steep = 4, ## controls the steepness of the dbh range transition, should be > 1
                        lambda = 2) {

  Nobs = as.numeric(Nobs)
  Nobs = matrix(Nobs, nrow=length(dbh), ncol=length(Nobs), byrow = TRUE)
  weight_N = a * (1 - exp(-b * Nobs))
  # a : max value that weight_N can reach (here: 1)
  # b=0.03 -> we reach 95% of the max value of weight_N when Nobs = log(20)/0.03 = 100
  # implication: new observations will not increase weight_N much when Nobs > 100

  dbhrange = matrix(as.numeric(unlist(dbhrange)), ncol = 2)
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

  ## TODO add geographic weight?

  # multiplicative weights: if one is zero, the total weight should be zero too
  return(weight_N * weight_D * weight_E * weight_T)
}


#### test ####
library(data.table)
data = data.table(expand.grid(dbh=1:150, genus=c("Acer", "Prunus", "Fraxinus", "Quercus"), location = c("scbi", "zaragoza", "nice", "sivas")))
data = merge(data, data.frame(location = c("scbi", "zaragoza", "nice", "ivas"),
                              long = c(-78.15, -0.883, 7.266, 37.012),
                              lat = c(38.9, 41.65, 43.70, 39.75)))
data[, agb := get_biomass(dbh=data$dbh, genus=data$genus, coords = cbind(data$long, data$lat))/1000]
library(BIOMASS)
data$wsg = getWoodDensity(genus = data$genus, species=rep("sp", nrow(data)))$meanWD
data[, agb_chave := exp(-2.023977 - 0.89563505 * 0.5 + 0.92023559 * log(wsg) + 2.79495823 * log(dbh) - 0.04606298 * (log(dbh)^2))/1000]

logscale = FALSE
library(ggplot2)
g = ggplot(data, aes(x=dbh, y=agb, color=genus)) +
  geom_line() +
  geom_line(aes(y=agb_chave), lty=2) +
  labs(y="AGB (tons)") +
  facet_wrap( ~ location) +
  # annotate(geom = "text", x=80,y=40, label="Dotted lines: Chave equation with E = 0.5")
if (logscale)
  g = g + scale_x_log10() + scale_y_log10()
g
# ggsave("get_biomass_plot.pdf", height=8, width=10)
