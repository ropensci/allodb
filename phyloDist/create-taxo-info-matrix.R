#### create genus - family - life form - group data frame ####
library(data.table)

data("sitespecies")
genusTaxo = unique(sitespecies[, c("genus", "species", "family", "life_form", "warning")])
setDT(genusTaxo)
genusTaxo[!is.na(warning) & grepl("ccepted family", warning),
          family := gsub("Accepted family is ", "", warning)]
genusTaxo$warning = NULL

## correct some problems in the original site data
genusTaxo[grep("Litsea", genus), genus := "Litsea"]
genusTaxo = unique(genusTaxo)

## homogenize ####
## life form
genusTaxo[grep("reelet", life_form), life_form := "Shrub"]
genusTaxo[grep("ree", life_form), life_form := "Tree"]
shrubs = unique(genusTaxo[, c("genus", "species", "life_form")])
## if there's a conflict, consider it a tree (more conservative)
indeterm = shrubs[duplicated(paste(genus, species)), paste(genus, species)]
shrubs[paste(genus, species) %in% indeterm, life_form := "Tree"]
shrubs = unique(shrubs)

## is genus a good enough information?
pshrub = shrubs[, .(p = sum(life_form=="Shrub")/length(life_form), n = sum(life_form=="Shrub")), .(genus)]
hist(pshrub$p)
shrub_genus = pshrub[p==1 & n>1, genus]
shrub_species = shrubs[life_form == "Shrub" & ! genus %in% shrub_genus, paste(genus, species)]
shrub_species = c(paste(shrub_genus, "sp."), shrub_species)
save(shrub_species, file = "data/shrub_species.rda")

## family
search_genus = unique(genusTaxo$genus)
library(taxize)

