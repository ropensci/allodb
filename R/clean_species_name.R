### clean species name ###
library(taxize)

load("data/equations.rda")
equations_names = tnrs(equations$equation_taxa, source = "iPlant_TNRS")

species_list = strsplit(unique(equations$equation_taxa), "/|,|Or")

species_list2 = tnrs(unlist(species_list), source = "iPlant_TNRS")
