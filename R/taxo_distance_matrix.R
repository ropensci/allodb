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
load("data/listSpeciesFGEO.rda")
censusTaxa = data.table(listSpeciesFGEO, do.call(cbind, tstrsplit(listSpeciesFGEO, " ")))
colnames(censusTaxa) = c("name", "genus", "species")
censusTaxa[genus%in% c("Padus", "Cerasus"), genus := "Prunus"]

## find family based on genus
temp = tax_name(query = unique(censusTaxa$genus), get = "family", db = "both")
taxfam = unique(temp[!is.na(temp$family), -1])
# correct duplicates
taxfam = taxfam[!taxfam$family %in% c("Viscaceae", "Diervillaceae"),]
# add missing info
taxfam$family[taxfam$query == "Pentaphylloides"] = "Rosaceae"
censusTaxa = merge(censusTaxa, taxfam, by.x = "genus", by.y = "query", all.x = TRUE)
# save(censusTaxa, file = "data/temp_censusTaxa.rda")
colnames(censusTaxa) = paste0(colnames(censusTaxa), "C")

## weight for each combination of species in the census and equation taxa
Wtaxo = data.table(expand.grid(nameC = censusTaxa$nameC, eqID = equationTaxa$eqID))
Wtaxo = merge(Wtaxo, censusTaxa, by = "nameC")
Wtaxo = merge(Wtaxo, equationTaxa, by = "eqID")

# define weights
Wtaxo$weight = 0
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
Wtaxo[familyC %in% conifers & nameE=="Conifers", weight := 0.2]

# Shrubs
# angiosperms

taxo_weight = dcast(Wtaxo, nameC ~ eqID, value.var = "weight")
save(taxo_weight, file = "data/taxo_weight.rda")
