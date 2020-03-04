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
equations <- read.csv("https://raw.githubusercontent.com/forestgeo/allodb/master/data/equations.csv", stringsAsFactors = FALSE)

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

# find family based on genus
genusList = unique(equationTaxa$genus)
genusList = genusList[!is.na(genusList)]
temp = tax_name(query = genusList, get = "family", db = "ncbi")
colnames(temp) = c("db", "genus", "familytemp")
equationTaxa = merge(equationTaxa, temp[, c("genus", "familytemp")], by = "genus", all.x = TRUE)
equationTaxa[!is.na(genus) & is.na(family), family := familytemp]
equationTaxa[, familytemp := NULL]
# save(equationTaxa, file = "data/temp_equationTaxa.rda")
colnames(equationTaxa) = c("genusE", "eqID", "nameE", "specifE", "familyE", "speciesE")

## Taxa in ForestGEO temperate sites
load("data/sitespecies.rda")
censusTaxa = data.table(unique(sitespecies[, c("family", "genus", "latin_name", "life_form")]))
censusTaxa[latin_name == "Pinus sylvatica", latin_name := "Pinus sylvestris"]

## correct names
censusTaxa[, species := tstrsplit(latin_name, " ")[[2]]]
censusTaxa[species %in% c("sp.", "spp.", "x", "unknown", "species"), species := NA]
temp = BIOMASS::correctTaxo(genus=censusTaxa$genus, species = censusTaxa$species)
censusTaxa[, c("genus", "species")] = temp[, c("genusCorrected", "speciesCorrected")]
censusTaxa$latin_name = NULL
censusTaxa[, name := genus]
censusTaxa[!is.na(species), name := paste(genus, species)]

# get updated family names from genus
temp2 = tax_name(query = unique(censusTaxa$genus), get = "family", db = "ncbi")
# ## complete those that were not found in the NCBI database
# temp2b = tax_name(query = temp2[is.na(temp2$family),]$query, get = "family", db = "itis")
# ## Pentaphylloides not found, belongs to  Rosaceae family
# temp2b$family[temp2b$query=="Pentaphylloides"] = "Rosaceae"
# temp2 = rbind(temp2[!is.na(temp2$family),], temp2b)
# correct Arceuthobium, belongs to Santalaceae family
temp2$family[temp2$query=="Arceuthobium"] = "Santalaceae"
# merge with main census taxa data frame
censusTaxa = merge(censusTaxa[, -"family"], temp2[, -1], by.x = "genus", by.y = "query")
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


taxo_weight = dcast(Wtaxo, nameC ~ eqID, value.var = "weight")
save(taxo_weight, file = "data/taxo_weight.rda")
