##########################################################
###### Create a taxonomic distance matrix with: ##########
###### (1) all taxa (and groups of taxa) in the ##########
###### equations in the columns                 ##########
###### (2) all taxa in the census as rows       ##########
##########################################################

## phylo dstance
## packages needed
packages_needed = c("data.table", "taxize", "adephylo", "V.PhyloMaker")
packages_to_install = packages_needed[!(packages_needed %in% rownames(installed.packages()))]
if (length(packages_to_install) > 0)
  install.packages(packages_to_install)
lapply(packages_needed, require, character.only = TRUE)

data("sitespecies")
data("equations")
### keep all genera in both census and equation tables, and all families in equation table
genus_equations = equations$equation_taxa[equations$allometry_specificity %in% c("Genus", "Species")]
## replace special chinese characters
sitespecies$genus = gsub("  ", " ", gsub("<[^>]+>", " ", enc2native(sitespecies$genus)))
genus_all = unique(tstrsplit(c(sitespecies$genus, genus_equations), " ")[[1]])
genus_all = genus_all[-grep("evergreen|uniden|unk", tolower(genus_all))]
genus_tree = unique(tstrsplit(GBOTB.extended$tip.label, "_")[[1]])
genus_all[!genus_all %in% genus_tree]

species_tree = GBOTB.extended$tip.label
species_tree_incl = species_tree[tstrsplit(species_tree, "_")[[1]] %in% genus_all]

#### retrieve from itis data base
taxoInfo = c()
lgenus = split(genus_all, ceiling(seq_along(genus_all)/20))
for (i in 1:length(lgenus)) {
  temp = tax_name(query = lgenus[[i]], get = "family", db = "itis", accepted = TRUE,
                  rank_filter = "genus", division_filter = "dicot")[, -1]
  taxoInfo = rbind(taxoInfo, temp)
}
colnames(taxoInfo)[1] = "genus"
## TODO add life form info + gymnosperm or not? (add all gymnosperm genera)
## family information for all species present in target sites was extracted from the ITIS database using the R package taxize.
## Life forms for all species were provided by site PIs (source?).
save(taxoInfo, file = "data/taxoInfo.rda")




speciestable = unique(sitespecies[!is.na(sitespecies$species), c("latin_name", "family")])
speciestable = speciestable[!grepl(" sp\\.|ukn", tolower(speciestable$latin_name)),]
speciestable$species = do.call(paste, data.table::tstrsplit(speciestable$latin_name, " | x ")[1:2])
speciestable$species[grep(" x ", speciestable$latin_name)] = speciestable$latin_name[grep(" x ", speciestable$latin_name)]
speciestable = speciestable[-duplicated(speciestable$species),]
## TODO check spelling and family (accepted)
## TODO add a function that does it for new
tree = phylo.maker(speciestable)$scenario.3
distance = distTips(tree, method = "patristic")
L = length(labels(distance))
sp1 = rep(labels(distance), each = length(labels(distance))) ## species by column in the distance matrix
sp2 = rep(labels(distance), length(labels(distance)))  ## species by row in the distance matrix
rmL = unlist(sapply(1:L, function(i) (i-1)*L + 1:i))  ## species names to be removed (duplicated distance, not in the dist matrix)
dfdist = data.frame(sp1 = sp1[-rmL], sp2 = sp2[-rmL], dist = c(distance))
# dfdist$simil = exp(-0.01*dfdist$dist) ## adjust lambda / check values same genus, family, etc
## add all combinations (symmetry sp1 - sp2)
dfdistb = dfdist
colnames(dfdistb)[1:2] = c("sp2", "sp1")
dfdist = rbind(dfdist, dfdistb)

## now genus/family level? -> node-to-tip distance? try distRoot(tree)?
## for now (discuss with Erika and Krista): mean(paired distances of all species in same taxa)/2

dfdist$ge1 = data.table::tstrsplit(dfdist$sp1, "_")[[1]]
dfdist$ge2 = data.table::tstrsplit(dfdist$sp2, "_")[[1]]

## are all genera represented?
genusPhylo = unique(tstrsplit(labels(distance), "_")[[1]])
genusTable = unique(tstrsplit(speciestable$species, " ")[[1]])
genusTable[!(genusTable %in%  genusPhylo)]

subset(dfdist, ge1 == ge2 & ge1=="Salix")

## check that all species are in the list
speciesAll = unique(speciestable$species)
speciesAll[!(speciesAll %in%  gsub("_", " ", labels(distance)))]
speciesAll = unique(speciestable$species)
speciesAll[!(speciesAll %in%  gsub("_", " ", labels(distance)))]

## in equations
data("equations")
equation





### get all genus and species from equation table + site species ###
data("equations")
data("sitespecies")
corrected = correctTaxo(site_taxa$genus)


### get corrected and accepted names in site specific data ####
site_taxa = unique(sitespecies[, c("family", "genus")])


equation_genus = subset(equations,
                        !(equation_categ %in% c("fa_spec", "generic")) &
                          allometry_specificity %in% c("Genus", "Species"))$equation_taxa
equation_genus = unique(tstrsplit(equation_genus, " ")[[1]])
equation_genus[!equation_genus %in% site_taxa$genus]



### create correction matrix ####
## associates new corrected names ##

### create family-genus-species table that will be used to calculate taxo weight ###



### deprecated - remove taxo_weight.rda ###

## taxa in the equations
equations <-
  read.csv("data-raw/csv_database/equations.csv", stringsAsFactors = FALSE)

# correct species names
equations$equation_taxa = gsub(x = equations$equation_taxa,
                               pattern = "Virburnum",
                               replacement = "Viburnum")
equations$equation_taxa = gsub(x = equations$equation_taxa,
                               pattern = "/ ",
                               replacement = "/")

equationTaxa = data.table(equations[, c("equation_id", "equation_taxa", "allometry_specificity")])
equationTaxa[allometry_specificity == "Family", family := equation_taxa]
equationTaxa[allometry_specificity == "Genus", genus := equation_taxa]
equationTaxa[allometry_specificity == "Species", `:=`(genus = tstrsplit(equation_taxa, " ")[[1]],
                                                      species = tstrsplit(equation_taxa, " ")[[2]])]
equationTaxa[allometry_specificity == "Species" &
               grepl("/", equation_taxa),
             species := paste(species, tstrsplit(equation_taxa, " |/")[[5]], sep = " /")]
equationTaxaReal = equationTaxa

# find family based on genus
## get previous families from temp data frames
load("data/temp_equationTaxa.rda")
load("data/temp_censusTaxa.rda")
families = unique(rbind(equationTaxa[!is.na(genus), c("genus", "family")],
                        censusTaxa[!is.na(censusTaxa$family), c("genus", "family")]))
colnames(families) = c("genus", "familytemp")
families = subset(families,!is.na(genus))

genusList = unique(equationTaxa[!is.na(genus) &
                                  !genus %in% families$genus]$genus)
if (length(genusList) > 0) {
  temp = tax_name(query = genusList, get = "family", db = "ncbi")[, -1]
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
temp = BIOMASS::correctTaxo(genus = censusTaxa$genus, species = censusTaxa$species)
censusTaxa[, c("genus", "species")] = temp[, c("genusCorrected", "speciesCorrected")]
censusTaxa$latin_name = NULL
censusTaxa[, name := genus]
censusTaxa[!is.na(species), name := paste(genus, species)]

# get updated family names from genus
genusList = unique(censusTaxa[!is.na(genus) &
                                !genus %in% families$genus]$genus)
genusList = genusList[!genusList %in% c("Unidentified", "Unk")]
if (length(genusList) > 0) {
  temp2 = tax_name(query = genusList[1], get = "family", db = "ncbi")[, -1]
  for (gen in genusList[-1]) {
    temp2temp = tax_name(query = gen,
                         get = "family",
                         db = "ncbi")[, -1]
    temp2 = rbind(temp2, temp2temp)
  }
  colnames(temp2) = c("genus", "familytemp")
  temp2$familytemp[temp2$genus == "Acanthopanax"] = "Araliaceae" ## accepted genus: Eleutherococcus
  temp2$familytemp[temp2$genus == "Laurocerasus"] = "Rosaceae" ## accepted genus: Prunus
  temp2$familytemp[temp2$genus %in% c("Dendrobenthamia", "Dendrobenthemia")] = "Cornaceae" ## accepted genus: Cornus
  temp2$familytemp[temp2$genus == "Algaia"] = "Meliaceae" ## accepted genus: Aglaia
  temp2$familytemp[temp2$genus == "Aphania"] = "Sapindaceae" ## accepted genus: Lepisanthes
  temp2$familytemp[temp2$genus == "Boniodendron"] = "Sapindaceae"
  temp2$familytemp[temp2$genus == "Lirianthe"] = "Magnoliaceae"
  temp2$familytemp[temp2$genus == "Cyclobalanopsis"] = "Fagaceae"  ## accepted genus: Quercus
  temp2$familytemp[temp2$genus == "Sterospermum"] = "Bignoniaceae" ## accepted genus: Stereospermum

  families = rbind(families, temp2)
}

# ## complete those that were not found in the NCBI database
# temp2b = tax_name(query = temp2[is.na(temp2$family),]$query, get = "family", db = "itis")
# ## Pentaphylloides not found, belongs to  Rosaceae family
# temp2b$family[temp2b$query=="Pentaphylloides"] = "Rosaceae"
# temp2 = rbind(temp2[!is.na(temp2$family),], temp2b)
# correct Arceuthobium, belongs to Santalaceae family
families$familytemp[families$genus == "Arceuthobium"] = "Santalaceae"
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
Wtaxo[!is.na(speciesC) &
        !is.na(speciesE) & genusE == genusC & speciesE == speciesC,
      weight := 1]
# TODO - equations with several species/families etc
## same genus but different species: weight = 0.7
Wtaxo[!is.na(speciesC) &
        !is.na(speciesE) & genusE == genusC & speciesE != speciesC,
      weight := 0.7]
## same genus and equation defined at genus level: weight = 0.8
Wtaxo[!is.na(speciesC) &
        !is.na(genusE) & is.na(speciesE) & genusE == genusC,
      weight := 0.8]
## same family and equation defined at family level: weight = 0.5
Wtaxo[!is.na(speciesC) &
        !is.na(familyE) & is.na(genusE) & familyE == familyC,
      weight := 0.5]
## same family and equation defined at genus or species level: weight = 0.2
Wtaxo[!is.na(speciesC) &
        !is.na(genusE) & familyE == familyC & genusE != genusC,
      weight := 0.2]

## when genus has been identified in census ###
## same genus and equation defined at genus level: weight = 1
Wtaxo[is.na(speciesC) &
        !is.na(genusE) & is.na(speciesE) & genusE == genusC,
      weight := 1]
## same genus and equation defined at species level: weight = 0.7
Wtaxo[is.na(speciesC) &
        !is.na(genusE) & !is.na(speciesE) & genusE == genusC,
      weight := 0.7]
## same family and equation defined at family level: weight = 0.5
Wtaxo[is.na(speciesC) &
        !is.na(familyE) & is.na(genusE) & familyE == familyC,
      weight := 0.5]
## same family and equation defined at genus or species level: weight = 0.2
Wtaxo[is.na(speciesC) &
        !is.na(genusE) & familyE == familyC & genusE != genusC,
      weight := 0.2]

## when there are no equations corresponding to a particular taxon: use generic equations
subset(equationTaxa,!specifE %in% c("Family", "Genus", "Species"))
Wtaxo[nameE %in% c("Woody species"), weight := 0.1]

## conifer families
conifers = c(
  "Pinaceae",
  "Podocarpaceae",
  "Cupressaceae",
  "Araucariaceae",
  "Cephalotaxaceae",
  "Phyllocladaceae",
  "Sciadopityaceae",
  "Taxaceae"
)
Wtaxo[(familyC %in% conifers |
         grepl("onifer", nameC)) & nameE == "Conifers", weight := 0.2]

# Shrubs
Wtaxo[grepl("hrub", life_formC) & nameE == "Shrubs", weight := 0.2]
## Shrubs (angiosperms)
Wtaxo[grepl("hrub", life_formC) & nameE == "Shrubs (Angiosperms)" &
        !(familyC %in% conifers | grepl("onifer", nameC)),
      weight := 0.2]
## Angiosperms
Wtaxo[!(familyC %in% conifers |
          grepl("onifer", nameC)) &
        nameE %in% c("Broad-leaved species", "Trees and shrubs (Angiosperms)"),
      weight := 0.2]
## Trees
Wtaxo[life_formC == "tree" &
        nameE == "Trees (Angio and Gymnosperms)", weight := 0.2]
## Angiosperm trees
Wtaxo[life_formC == "tree" &
        !(familyC %in% conifers |
            grepl("onifer", nameC)) & nameE == "Mixed hardwood", weight := 0.2]


taxo_weight = as.data.frame(dcast(Wtaxo, nameC ~ eqID, value.var = "weight"))

save(taxo_weight, file = "data/taxo_weight.rda")
