###################################################
### Produce graphs to test get_biomass function ###
###################################################

library(data.table)
library(ggplot2)
library(ggpubr)
library(allodb)

#### test 1 ####
#generic test

data = data.table(expand.grid(dbh=1:150, genus=c("Acer", "Prunus", "Fraxinus", "Quercus"), location = c("scbi", "zaragoza", "nice", "sivas")))
data = merge(data, data.frame(location = c("scbi", "zaragoza", "nice", "ivas"),
                              long = c(-78.15, -0.883, 7.266, 37.012),
                              lat = c(38.9, 41.65, 43.70, 39.75)))
data[, agb := get_biomass(dbh=data$dbh, genus=data$genus, coords = cbind(data$long, data$lat))/1000]

#if you want to check the weight given to each equation
Mweigth =  get_biomass(dbh=data$dbh, genus=data$genus, species = data$species,
                       coords = cbind(data$long, data$lat), add_weight = TRUE)/1000

library(BIOMASS)
data$wsg = getWoodDensity(genus = data$genus, species=rep("sp", nrow(data)))$meanWD
data[, agb_chave := exp(-2.023977 - 0.89563505 * 0.5 + 0.92023559 * log(wsg) + 2.79495823 * log(dbh) - 0.04606298 * (log(dbh)^2))/1000]

logscale = FALSE
g = ggplot(data, aes(x=dbh, y=agb, color=genus)) +
  geom_line() +
  geom_line(aes(y=agb_chave), lty=2) +
  labs(y="AGB (tons)") +
  facet_wrap( ~ location) # +
# annotate(geom = "text", x=80, y=40, label="Dotted lines: Chave equation with E = 0.5")
if (logscale)
  g = g + scale_x_log10() + scale_y_log10()
g
# ggsave("get_biomass_plot.pdf", height=8, width=10)


#### test 2 ####

# species list in allodb / per site ##
load("data/sitespecies.rda")
sitespecies = data.table(sitespecies)

## keep only non tropical sites
load("data/sites_info.rda")
tropical = sites_info$site[abs(as.numeric(sites_info$lat)) < 23.5]
sitespecies = subset(sitespecies, ! site %in% tropical)

#sitespecies[latin_name == "Pinus sylvatica", latin_name := "Pinus sylvestris"]
sitespecies[, genus := tstrsplit(latin_name, " ")[[1]]]
sitespecies[, species := tstrsplit(latin_name, " ")[[2]]]
sitespecies[species == "x", species := paste(tstrsplit(latin_name, " ")[[2]],
                                             tstrsplit(latin_name, " ")[[3]])]
sitespecies[species %in% c("sp.", "spp.", "", "species", "unknown"), species := NA]

site_species = unique(sitespecies[, c("genus", "species", "site")])
## merge with site coordinates
site_species = merge(site_species, sites_info[, c("site", "lat", "long")], by = "site")
site_species$nb = 1:nrow(site_species)

data = data.table(expand.grid(dbh=1:200, nb = 1:nrow(site_species)))
data = merge(data, site_species, by = "nb")
data$nb = NULL

## parallelize agb calculation to avoid memory over usage
data_site = split(data, by = "site")
agb = lapply(data_site, function(df) get_biomass(dbh=df$dbh,
                                                 genus=df$genus,
                                                 species = df$species,
                                                 coords = cbind(df$long, df$lat))/1000)
data$agb = do.call(c, agb)

data[, name := paste(genus, species)]
data[, name := gsub(" NA", "", name)]

# create folder if it does not already exist
if (!file.exists("tests/graphs"))
  dir.create("tests/graphs")

load("data/equations.rda")

## split data by site
ls_site_species = split(data, by = "site")

# save graphs in this new directory
for (i in 1:length(ls_site_species)) {
  ## create folder for the site's graphs
  dir_site = paste0("tests/graphs/",names(ls_site_species)[i])
  if (!file.exists(dir_site))
    dir.create(dir_site)

  df_site = ls_site_species[[i]]

  ## make plots by species
  species_site = unique(paste(df_site$name))

  for (sp in species_site) {
    df = subset(df_site, name == sp)
    g = ggplot(df, aes(x=dbh, y=agb)) +
      geom_line() +
      facet_wrap(~ name, ncol=3) +
      theme_bw() +
      theme(legend.position = "none") +
      labs(y="AGB (tons)", x = "DBH (cm)")

    # # equation weight
    weight = get_biomass(dbh = df$dbh, genus =  df$genus, species = df$species,
                         coords = df[1, c("long", "lat")], add_weight = TRUE)[, -1]
    totalW = colSums(weight, na.rm=TRUE)
    # ## show only top 10 equations
    weightMax = weight[,order(totalW, decreasing = TRUE)[1:10]][, 10:1]
    dt = melt(data.table(dbh = df$dbh, weightMax), id.vars = "dbh", variable.name = "equationID", value.name = "weight")
    dt = merge(dt, equations[, c("equation_id", "equation_taxa", "dbh_min_cm", "dbh_max_cm", "koppen")],
               by.x = "equationID", by.y = "equation_id")
    dt[, `:=`(dbh_min_cm = as.numeric(dbh_min_cm), dbh_max_cm = as.numeric(dbh_max_cm))]
    DFtaxaID = unique(dt[, c("equationID", "equation_taxa")])
    equationTaxaID = sapply(colnames(weightMax), function(j)
      paste(j, DFtaxaID$equation_taxa[DFtaxaID$equationID == j], sep=" - "))
    dt$equationTaxaID = factor(paste(dt$equationID, dt$equation_taxa, sep=" - "), levels = equationTaxaID)

    w = ggplot(dt, aes(x=dbh, y = equationTaxaID, fill=weight)) +
      geom_raster() +
      lims(x = range(dt$dbh)) +
      scale_fill_gradientn(colours = rev(terrain.colors(10))) +
      geom_point(aes(x=dbh_min_cm), col="blue") +
      geom_point(aes(x=dbh_max_cm), col="red") +
      labs(x="DBH (cm)", y = "")

    ggarrange(g, g + scale_x_log10() + scale_y_log10() + labs(y=""), w, ncol = 3, widths = c(0.25,0.25,0.5))
    name_file = paste0(dir_site, "/", gsub(" ", "_", sp), ".pdf")
    ggsave(name_file, height = 3, width = 15)
  }
}

## agb < 0
subset(data, agb < 0)

## subset data: species-site combination with non monotonic AGB allometry
data = setorder(data, site, name, dbh)
which_nonmon = subset(data[, .(non_mon = any(diff(agb) < 0)), .(site, name)], (non_mon))
data_nonmon = merge(data, which_nonmon[, -"non_mon"], by = c("site", "name"))

if (nrow(data_nonmon) > 0) {
  ggplot(data_nonmon, aes(x=dbh, y=agb)) +
    geom_line() +
    facet_wrap(~ site + name, ncol=5) +
    theme_bw() +
    theme(legend.position = "none") +
    labs(y="AGB (tons)", x = "DBH (cm)") +
    scale_x_log10() + scale_y_log10()
  ggsave("tests/graphs/non_monotonous_allometries_log.pdf", height=36, width=15)
  ggplot(data_nonmon, aes(x=dbh, y=agb)) +
    geom_line() +
    facet_wrap(~ site + name, ncol=5) +
    theme_bw() +
    theme(legend.position = "none") +
    labs(y="AGB (tons)", x = "DBH (cm)")
  ggsave("tests/graphs/non_monotonous_allometries.pdf", height=36, width=15)
}



## test 3 - Compare allodb AGB results with widely used models (Chave and Chojnacky) -use scbi-census-1 (census 2008, 40166 stems) ####

scbi = data.table(read.csv("tests/scbi.stem1-agb.csv"))
scbi = subset(scbi, !is.na(dbh))

# split dataset (to avoid running into memory issues)
data_split = split(scbi, cut(1:nrow(scbi), breaks = 10, labels = FALSE))

agb = lapply(data_split, function(df) get_biomass(dbh=df$dbh/10,
                                                  genus=df$genus,
                                                  species = df$species,
                                                  coords = c(-78.2, 38.9)))

scbi$agb_allodb = do.call(c, agb)/1000

sum(scbi$agb)
sum(scbi$agb_allodb)

# get species names
load("tests/scbi.spptable.rdata")
scbi = merge(scbi[, -grep("genus|amily|pecies", colnames(scbi)), with = FALSE], scbi.spptable, by = "sp", all.x = TRUE)
# get wood densities
library(BIOMASS)
wd = getWoodDensity(genus = scbi$genus, species = scbi$species)
scbi$wsg = wd$meanWD

source("tests/evaluation_of_equations/chojnackyParams.R")
scbi = data.table(scbi, chojnackyParams(scbi$Family, scbi$genus, scbi$wsg))

scbi[, agb_choj := exp(V1 + V2*log(dbh/10))/1000]

# built graphs to compare with other models
# tropical (Chave eq) vs. allodb
gchave_allodb = ggplot(scbi, aes(x = agb, y = agb_allodb, color = paste(genus, species))) +
  geom_abline(slope=1, intercept=0, lty=2) +
  geom_point() +
  theme(legend.position = "none") +
  labs(x = "Predictions from Chave et al. 2005", y = "Predictions from allodb")

# regional model (Chojnacky) vs. allodb
gchojn_allodb = ggplot(scbi, aes(x = agb_choj, y = agb_allodb, color = paste(genus, species))) +
  geom_abline(slope=1, intercept=0, lty=2) +
  geom_point() +
  theme(legend.position = "none") +
  labs(x = "Predictions from Chojnacky et al. 2014", y = "Predictions from allodb")

# regional model (Chojnacky) vs. tropical model (Chave)
gchojn_chave = ggplot(scbi, aes(x = agb_choj, y = agb, color = paste(genus, species))) +
  geom_abline(slope=1, intercept=0, lty=2) +
  geom_point() +
  theme(legend.position = "none")

## check which set of equations gives the most different results
deltaCaCo = abs(scbi$agb-scbi$agb_choj)
deltaCaA = abs(scbi$agb-scbi$agb_allodb)
deltaACo = abs(scbi$agb_choj-scbi$agb_allodb)
minDist = apply(cbind(deltaCaCo, deltaCaA, deltaACo), 1, which.min)
maxDist = c("allodb", "chojnacky", "chave")[minDist]
table(maxDist)/length(maxDist)*100

library(plotly)
ggplotly(gchave_allodb)
ggplotly(gchojn_allodb)
ggplotly(gchojn_chave)

#sum of AGB
sum(scbi$agb_choj, na.rm = TRUE)
sum(scbi$agb_choj)/25.6 #per ha-1
sum(scbi$agb_allodb)
sum(scbi$agb_allodb)/25.6 #per ha-1

write.csv(scbi, "scbi.csv")
getwd()
