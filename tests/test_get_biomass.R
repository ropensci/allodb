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
sitespecies[latin_name == "Pinus sylvatica", latin_name := "Pinus sylvestris"]
sitespecies$species = tstrsplit(sitespecies$latin_name, " ")[[2]]
sitespecies[species %in% c("sp.", "spp.", "x", "", "species", "unknown"), species := NA]

site_species = unique(sitespecies[-grep("any-", site), c("genus", "species", "site")])
## merge with site coordinates
load("data/sites_info.rda")
site_species = merge(site_species, sites_info[, c("site", "lat", "long")], by = "site")
site_species$nb = 1:nrow(site_species)
## TODO add Asia sites?

data = data.table(expand.grid(dbh=1:150, nb = 1:nrow(site_species)))
data = merge(data, site_species, by = "nb")
data$nb = NULL

data[, agb := get_biomass(dbh=data$dbh, genus=data$genus, species = data$species,
                          coords = cbind(data$long, data$lat))/1000]
data[, name := paste(genus, species)]

## number of species/site pair of plots (natural + log scale) per page
n_pplots = 3
# create folder if it does not already exist
if (!file.exists("tests/graphs"))
  dir.create("tests/graphs")

## split data by site
ls_site_species = split(data, by = "site")

# save graphs in this new directory
# for (i in 1:ceiling(length(ls_site_species)/n_pplots)) {
for (i in 1:length(ls_site_species)) {
  # list_indices = (3*i-2):(3*i)
  df = ls_site_species[[i]]
  n_species = length(unique(df$name))
  df = rbindlist(ls_site_species[list_indices])
  g = ggplot(df, aes(x=dbh, y=agb)) +
    geom_line() +
    facet_wrap(~ name, ncol=3) +
    theme_bw() +
    theme(legend.position = "none") +
    labs(y="AGB (tons)", x = "DBH (cm)")
  # ggarrange(g, g + scale_x_log10() + scale_y_log10() + labs(y=""))
  name_file = paste0("tests/graphs/test_get_biomass_", gsub(" ", "", names(ls_site_species)[i]))
  g
  ggsave(paste0(name_file, ".pdf"), height = n_species, width = 10)
  g + scale_x_log10() + scale_y_log10()
  ggsavepaste0(name_file, "_log.pdf"), height = n_species, width = 10)
}

