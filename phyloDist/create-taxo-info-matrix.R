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
## family
search_genus = unique(genusTaxo$genus)
