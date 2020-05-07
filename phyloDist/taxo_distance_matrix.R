##########################################################
###### Create a taxonomic distance matrix with: ##########
###### (1) all taxa (and groups of taxa) in the ##########
###### equations in the columns                 ##########
###### (2) all taxa in the census as rows       ##########
##########################################################

## packages needed
packages_needed = c("data.table", "taxize")
packages_to_install = packages_needed[!( packages_needed %in% rownames(installed.packages()))]
if (length(packages_to_install) > 0)
  install.packages(packages_to_install)
lapply(packages_needed, require, character.only = TRUE)


## taxa in the equations
equations <- read.csv("data-raw/csv_database/equations.csv", stringsAsFactors = FALSE)

# correct species names
equations$equation_taxa = gsub(x = equations$equation_taxa, pattern = "Virburnum", replacement = "Viburnum")
equations$equation_taxa = gsub(x = equations$equation_taxa, pattern = "/ ", replacement = "/")

equationTaxa = data.table(equations[, c("equation_id", "equation_taxa", "allometry_specificity")])
equationTaxa[allometry_specificity == "Family", family := equation_taxa]
equationTaxa[allometry_specificity == "Genus", genus := equation_taxa]
equationTaxa[allometry_specificity == "Species", `:=`(genus = tstrsplit(equation_taxa, " ")[[1]],
                                                      species = tstrsplit(equation_taxa, " ")[[2]])]
equationTaxa[allometry_specificity == "Species" & grepl("/", equation_taxa),
             species := paste(species, tstrsplit(equation_taxa, " |/")[[5]], sep = " /")]
equationTaxaReal = equationTaxa

# find family based on genus
## get previous families from temp data frames
load("data/temp_equationTaxa.rda")
load("data/temp_censusTaxa.rda")
families = unique(rbind(equationTaxa[!is.na(genus), c("genus", "family")],
                        censusTaxa[!is.na(censusTaxa$family), c("genus", "family")]))
colnames(families) = c("genus", "familytemp")
families = subset(families, !is.na(genus))

genusList = unique(equationTaxa[!is.na(genus) & !genus %in% families$genus]$genus)
if (length(genusList) > 0) {
  temp = tax_name(query = genusList, get = "family", db = "ncbi")[,-1]
  colnames(temp) = c("genus", "familytemp")
  families = rbind(families, temp)
}
equationTaxa = data.table(merge(equationTaxaReal, families, by = "genus", all.x = TRUE))
equationTaxa[!is.na(genus) & is.na(family), family := familytemp]
equationTaxa[, familytemp := NULL]
# save(equationTaxa, file = "data/temp_equationTaxa.rda")
colnames(equationTaxa) = c("genusE", "eqID", "nameE", "specifE", "familyE", "speciesE")

## Taxa in ForestGEO temperate sites
load("data/sitespecies.rda")
censusTaxa = data.table(unique(sitespecies[, c("family", "genus", "latin_name", "life_form")]))
censusTaxa[latin_name == "Pinus sylvatica", latin_name := "Pinus sylvestris"]

## correct names
censusTaxa[, genus := tstrsplit(latin_name, "[ \t]")[[1]]]
censusTaxa[, species := tstrsplit(latin_name, "[ \t]")[[2]]]
censusTaxa[species %in% c("sp.", "spp.", "x", "unknown", "species"), species := NA]
temp = BIOMASS::correctTaxo(genus=censusTaxa$genus, species = censusTaxa$species)
censusTaxa[, c("genus", "species")] = temp[, c("genusCorrected", "speciesCorrected")]
censusTaxa$latin_name = NULL
censusTaxa[, name := genus]
censusTaxa[!is.na(species), name := paste(genus, species)]

# get updated family names from genus
genusList = unique(censusTaxa[!is.na(genus) & !genus %in% families$genus]$genus)
genusList = genusList[! genusList %in% c("Unidentified", "Unk")]
if (length(genusList) > 0) {
  temp2 = tax_name(query = genusList[1], get = "family", db = "ncbi")[,-1]
  for (gen in genusList[-1]) {
    temp2temp = tax_name(query = gen, get = "family", db = "ncbi")[,-1]
    temp2 = rbind(temp2, temp2temp)
  }
  colnames(temp2) = c("genus", "familytemp")
  temp2$familytemp[temp2$genus=="Acanthopanax"] = "Araliaceae" ## accepted genus: Eleutherococcus
  temp2$familytemp[temp2$genus=="Laurocerasus"] = "Rosaceae" ## accepted genus: Prunus
  temp2$familytemp[temp2$genus%in% c("Dendrobenthamia","Dendrobenthemia")] = "Cornaceae" ## accepted genus: Cornus
  temp2$familytemp[temp2$genus=="Algaia"] = "Meliaceae" ## accepted genus: Aglaia
  temp2$familytemp[temp2$genus=="Aphania"] = "Sapindaceae" ## accepted genus: Lepisanthes
  temp2$familytemp[temp2$genus=="Boniodendron"] = "Sapindaceae"
  temp2$familytemp[temp2$genus=="Lirianthe"] = "Magnoliaceae"
  temp2$familytemp[temp2$genus=="Cyclobalanopsis"] = "Fagaceae"  ## accepted genus: Quercus
  temp2$familytemp[temp2$genus=="Sterospermum"] = "Bignoniaceae" ## accepted genus: Stereospermum

  families = rbind(families, temp2)
}

# ## complete those that were not found in the NCBI database
# temp2b = tax_name(query = temp2[is.na(temp2$family),]$query, get = "family", db = "itis")
# ## Pentaphylloides not found, belongs to  Rosaceae family
# temp2b$family[temp2b$query=="Pentaphylloides"] = "Rosaceae"
# temp2 = rbind(temp2[!is.na(temp2$family),], temp2b)
# correct Arceuthobium, belongs to Santalaceae family
families$familytemp[families$genus=="Arceuthobium"] = "Santalaceae"
# merge with main census taxa data frame
censusTaxa = merge(censusTaxa, families, by = "genus")
censusTaxa[!is.na(familytemp), family := familytemp]
censusTaxa[, familytemp := NULL]
censusTaxa[, life_form := tolower(life_form)]
censusTaxa[, life_form := gsub("treelet|small tree", "tree", life_form)]
censusTaxa = unique(censusTaxa)
dupnames = censusTaxa[duplicated(name)]$name
censusTaxa[name %in% dupnames, life_form := "tree, shrub"]
censusTaxa = unique(censusTaxa)
# save(censusTaxa, file = "data/temp_censusTaxa.rda")
colnames(censusTaxa) = paste0(colnames(censusTaxa), "C")

## weight for each combination of species in the census and equation taxa
Wtaxo = data.table(expand.grid(nameC = censusTaxa$nameC, eqID = equationTaxa$eqID))
Wtaxo = merge(Wtaxo, censusTaxa, by = "nameC")
Wtaxo = merge(Wtaxo, equationTaxa, by = "eqID")

# define weights
Wtaxo$weight = 1e-6
## when species has been indentified in census
## same species: weight = 1
Wtaxo[!is.na(speciesC) & !is.na(speciesE) & genusE==genusC & speciesE==speciesC,
      weight := 1]
# TODO - equations with several species/families etc
## same genus but different species: weight = 0.7
Wtaxo[!is.na(speciesC) & !is.na(speciesE) & genusE==genusC & speciesE!=speciesC,
      weight := 0.7]
## same genus and equation defined at genus level: weight = 0.8
Wtaxo[!is.na(speciesC) & !is.na(genusE) & is.na(speciesE) & genusE==genusC,
      weight := 0.8]
## same family and equation defined at family level: weight = 0.5
Wtaxo[!is.na(speciesC) & !is.na(familyE) & is.na(genusE) & familyE==familyC,
      weight := 0.5]
## same family and equation defined at genus or species level: weight = 0.2
Wtaxo[!is.na(speciesC) & !is.na(genusE) & familyE==familyC & genusE!=genusC,
      weight := 0.2]

## when genus has been identified in census ###
## same genus and equation defined at genus level: weight = 1
Wtaxo[is.na(speciesC) & !is.na(genusE) & is.na(speciesE) & genusE==genusC,
      weight := 1]
## same genus and equation defined at species level: weight = 0.7
Wtaxo[is.na(speciesC) & !is.na(genusE) & !is.na(speciesE) & genusE==genusC,
      weight := 0.7]
## same family and equation defined at family level: weight = 0.5
Wtaxo[is.na(speciesC) & !is.na(familyE) & is.na(genusE) & familyE==familyC,
      weight := 0.5]
## same family and equation defined at genus or species level: weight = 0.2
Wtaxo[is.na(speciesC) & !is.na(genusE) & familyE==familyC & genusE!=genusC,
      weight := 0.2]

## when there are no equations corresponding to a particular taxon: use generic equations
subset(equationTaxa, !specifE%in% c("Family", "Genus", "Species"))
Wtaxo[nameE %in% c("Woody species"), weight := 0.1]

## conifer families
conifers = c("Pinaceae", "Podocarpaceae", "Cupressaceae", "Araucariaceae", "Cephalotaxaceae",
             "Phyllocladaceae", "Sciadopityaceae", "Taxaceae")
Wtaxo[(familyC %in% conifers | grepl("onifer", nameC)) & nameE=="Conifers", weight := 0.2]

# Shrubs
Wtaxo[grepl("hrub", life_formC) & nameE == "Shrubs", weight := 0.2]
## Shrubs (angiosperms)
Wtaxo[grepl("hrub", life_formC) & nameE == "Shrubs (Angiosperms)" &
        !(familyC %in% conifers | grepl("onifer", nameC)),
      weight := 0.2]
## Angiosperms
Wtaxo[!(familyC %in% conifers | grepl("onifer", nameC)) & nameE %in% c("Broad-leaved species", "Trees and shrubs (Angiosperms)"),
      weight := 0.2]
## Trees
Wtaxo[life_formC == "tree" & nameE == "Trees (Angio and Gymnosperms)", weight := 0.2]
## Angiosperm trees
Wtaxo[life_formC == "tree" & !(familyC %in% conifers | grepl("onifer", nameC)) & nameE == "Mixed hardwood", weight := 0.2]


taxo_weight = as.data.frame(dcast(Wtaxo, nameC ~ eqID, value.var = "weight"))

save(taxo_weight, file = "data/taxo_weight.rda")
