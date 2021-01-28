###################################################
### Produce graphs to test get_biomass function ###
###################################################

library(data.table)
library(ggplot2)
library(ggpubr)
library(allodb)


#### illustration - Fig1 - Liriodendron tulipifera at SCBI ####
illustrate_allodb("Liriodendron", "tulipifera", c(-78, 40),
                  neq = 12, eqinfo = c("equation_taxa", "geographic_area")) +
  labs(title = "Example: Liriodendron tulipifera at SCBI")
ggsave("not-package-stuff/graphs/Liriodendron-tulipifera_SCBI.png", height = 3.5, width = 12)


#### illustration - all sites ####

# species list in allodb / per site ##
load("data/sitespecies.rda")
setDT(sitespecies)
sitespecies$site <- gsub(" ", "-", sitespecies$site)

## keep only non tropical sites
load("data/sites_info.rda")
tropical <- sites_info$site[abs(as.numeric(sites_info$lat)) < 23.5]
sitespecies <- subset(sitespecies, !site %in% tropical)

sitespecies[, genus := tstrsplit(latin_name, " ")[[1]]]
sitespecies[, species := tstrsplit(latin_name, " ")[[2]]]
sitespecies[species == "x", species := paste(
  tstrsplit(latin_name, " ")[[2]],
  tstrsplit(latin_name, " ")[[3]]
)]
sitespecies[species %in% c("sp.", "spp.", "", "species", "unknown"), species := NA]

sitespecies <- unique(sitespecies[, c("genus", "species", "site")])
## merge with site coordinates
sitespecies <- merge(sitespecies, sites_info[, c("site", "lat", "long")], by = "site")

# create folder if it does not already exist
if (!file.exists("not-package-stuff/graphs/sites")) {
  dir.create("not-package-stuff/graphs/sites")
}

# save graphs in this new directory
for (st in unique(sitespecies$site)) {
  ## create folder for the site's graphs
  dir_site <- paste0("not-package-stuff/graphs/sites/", st)
  if (!file.exists(dir_site)) {
    dir.create(dir_site)
  }
  df <- subset(sitespecies, site==st)
  for (i in seq_len(nrow(df))) {
    g <- illustrate_allodb(genus = df$genus[i],
                      species = df$species[i],
                      coords = df[i, c("long", "lat")],
                      logxy = FALSE)
    ggarrange(g + theme(legend.position = "none"), g + scale_x_log10() + scale_y_log10(), widths = c(1,2))
    name_file <- paste0(dir_site, "/", df$genus[i], "_", df$species[i], ".png")
    ggsave(name_file, height = 4, width = 12)
  }
}


## test 3 - Compare allodb AGB results with widely used models (Chave and Chojnacky) -use scbi-census-1 (census 2008, 40166 stems) ####

scbi <- data.table(read.csv("tests/scbi.stem1-agb.csv"))
scbi <- subset(scbi, !is.na(dbh))

# split dataset (to avoid running into memory issues)
data_split <- split(scbi, cut(1:nrow(scbi), breaks = 10, labels = FALSE))

agb <- lapply(data_split, function(df) {
  get_biomass(
    dbh = df$dbh / 10,
    genus = df$genus,
    species = df$species,
    coords = c(-78.2, 38.9)
  )
})

scbi$agb_allodb <- do.call(c, agb) / 1000

sum(scbi$agb)
sum(scbi$agb_allodb)

# get species names
load("tests/scbi.spptable.rdata")
scbi <- merge(scbi[, -grep("genus|amily|pecies", colnames(scbi)), with = FALSE], scbi.spptable, by = "sp", all.x = TRUE)
# get wood densities
library(BIOMASS)
wd <- getWoodDensity(genus = scbi$genus, species = scbi$species)
scbi$wsg <- wd$meanWD

source("tests/evaluation_of_equations/chojnackyParams.R")
scbi <- data.table(scbi, chojnackyParams(scbi$Family, scbi$genus, scbi$wsg))

scbi[, agb_choj := exp(V1 + V2 * log(dbh / 10)) / 1000]

# built graphs to compare with other models
# tropical (Chave eq) vs. allodb
gchave_allodb <- ggplot(scbi, aes(x = agb, y = agb_allodb, color = paste(genus, species))) +
  geom_abline(slope = 1, intercept = 0, lty = 2) +
  geom_point() +
  theme(legend.position = "none") +
  labs(x = "Predictions from Chave et al. 2005", y = "Predictions from allodb")

# regional model (Chojnacky) vs. allodb
gchojn_allodb <- ggplot(scbi, aes(x = agb_choj, y = agb_allodb, color = paste(genus, species))) +
  geom_abline(slope = 1, intercept = 0, lty = 2) +
  geom_point() +
  theme_classic() +
  theme(legend.position = "none") +
  labs(x = "Predictions from Chojnacky et al. 2014", y = "Predictions from allodb")
gchojn_allodb
ggsave("tests/choj_vs_allodb.jpg", height = 4, width = 4)

# regional model (Chojnacky) vs. tropical model (Chave)
gchojn_chave <- ggplot(scbi, aes(x = agb_choj, y = agb, color = paste(genus, species))) +
  geom_abline(slope = 1, intercept = 0, lty = 2) +
  geom_point() +
  theme(legend.position = "none")

## check which set of equations gives the most different results
deltaCaCo <- abs(scbi$agb - scbi$agb_choj)
deltaCaA <- abs(scbi$agb - scbi$agb_allodb)
deltaACo <- abs(scbi$agb_choj - scbi$agb_allodb)
minDist <- apply(cbind(deltaCaCo, deltaCaA, deltaACo), 1, which.min)
maxDist <- c("allodb", "chojnacky", "chave")[minDist]
table(maxDist) / length(maxDist) * 100

library(plotly)
ggplotly(gchave_allodb)
ggplotly(gchojn_allodb)
ggplotly(gchojn_chave)

# sum of AGB
sum(scbi$agb_choj, na.rm = TRUE)
sum(scbi$agb_choj) / 25.6 # per ha-1
sum(scbi$agb_allodb)
sum(scbi$agb_allodb) / 25.6 # per ha-1
