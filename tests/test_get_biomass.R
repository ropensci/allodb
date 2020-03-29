###################################################
### Produce graphs to test get_biomass function ###
###################################################

source("R/get_biomass.R")

library(data.table)
library(ggplot2)
library(ggpubr)

#### test 1 ####
data = data.table(expand.grid(dbh=1:150, genus=c("Acer", "Prunus", "Fraxinus", "Quercus"), location = c("scbi", "zaragoza", "nice", "sivas")))
data = merge(data, data.frame(location = c("scbi", "zaragoza", "nice", "ivas"),
                              long = c(-78.15, -0.883, 7.266, 37.012),
                              lat = c(38.9, 41.65, 43.70, 39.75)))
data[, agb := get_biomass(dbh=data$dbh, genus=data$genus, coords = cbind(data$long, data$lat))/1000]
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

# species list per site ##
load("data/sitespecies.rda")
sitespecies = data.table(sitespecies)
## correct spelling in sitespecies: niobrara instead of niobara
sitespecies[site == "niobara", site := "niobrara"]

## keep only non tropical sites
load("data/sites_info.rda")
tropical = sites_info$site[abs(as.numeric(sites_info$lat)) < 23.5]
sitespecies = subset(sitespecies, ! site %in% tropical)

sitespecies[latin_name == "Pinus sylvatica", latin_name := "Pinus sylvestris"]
sitespecies[, genus := tstrsplit(latin_name, " ")[[1]]]
sitespecies[, species := tstrsplit(latin_name, " ")[[2]]]
sitespecies[species == "x", species := paste(tstrsplit(latin_name, " ")[[2]],
                                             tstrsplit(latin_name, " ")[[3]])]
sitespecies[species %in% c("sp.", "spp.", "", "species", "unknown"), species := NA]

site_species = unique(sitespecies[, c("genus", "species", "site")])
## merge with site coordinates
site_species = merge(site_species, sites_info[, c("site", "lat", "long")], by = "site")
site_species$nb = 1:nrow(site_species)
## TODO add Asia sites?

data = data.table(expand.grid(dbh=1:200, nb = 1:nrow(site_species)))
data = merge(data, site_species, by = "nb")
data$nb = NULL

data[, agb := get_biomass(dbh=data$dbh, genus=data$genus, species = data$species,
                          coords = cbind(data$long, data$lat))/1000]
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
    # ## first 20 equations
    weightMax = weight[,order(totalW, decreasing = T)[1:20], with=FALSE]
    dt = melt(cbind(dbh = df$dbh, weightMax), id.vars = "dbh", variable.name = "equationID", value.name = "weight")
    dt = merge(dt, equations[, c("equation_id", "equation_taxa", "dbh_min_cm", "dbh_max_cm", "koppen")],
               by.x = "equationID", by.y = "equation_id")
    dt[, `:=`(dbh_min_cm = as.numeric(dbh_min_cm), dbh_max_cm = as.numeric(dbh_max_cm))]

    w = ggplot(dt, aes(x=dbh, y = paste(equationID, equation_taxa, sep=" - "), fill=weight)) +
      geom_raster() +
      scale_fill_gradientn(colours = rev(terrain.colors(10))) +
      geom_point(aes(x=dbh_min_cm), col="blue") +
      geom_point(aes(x=dbh_max_cm), col="red") +
      labs(x="DBH (cm)", y = "")

    ggarrange(g, g + scale_x_log10() + scale_y_log10() + labs(y=""), w, ncol = 3, widths = c(0.25,0.25,0.5))
    name_file = paste0(dir_site, "/", gsub(" ", "_", sp), ".pdf")
    ggsave(name_file, height = 3, width = 15)
  }
}
