##########################################################
###### Create a taxonomic distance matrix with: ##########
###### (1) all taxa (and groups of taxa) in the ##########
###### equations in the columns                 ##########
###### (2) all taxa in the census as rows       ##########
##########################################################

## packages needed
packages_needed = c("data.table","brranching","phytools","taxize")
packages_to_install = packages_needed[!( packages_needed %in% rownames(installed.packages()))]
if (length(packages_to_install) > 0)
  install.packages(packages_to_install)
lapply(packages_needed, require, character.only = TRUE)


## taxa in the equations
equations <- read.csv("https://raw.githubusercontent.com/forestgeo/allodb/master/data-raw/csv_database/equations.csv", stringsAsFactors = FALSE)
eq_genus <- equations$equation_taxa[equations$allometry_specificity%in%c("Genus","Species")]
eq_genus <- unique(tstrsplit(eq_genus, " ")[[1]])

# using scbi species table as example
scbi <- read.csv("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/scbi.spptable.csv", stringsAsFactors = FALSE)
scbi_genus <- unique(tstrsplit(scbi$Latin, " ")[[1]])
scbi_genus <- scbi_genus[-grep("niden", scbi_genus)]

all_genus <- unique(c(eq_genus, scbi_genus))
# check taxonomy with package taxize
temp = tnrs(query = all_genus, source = "iPlant_TNRS")
changed = which(temp$acceptedname!=temp$submittedname & temp$acceptedname!="")
all_genus[changed] = temp$acceptedname[changed]

tree <- phylomatic(taxa=all_genus, get = 'GET')
tree <- modified.Grafen(tree, power=2)
dmatrix1 <- cophenetic(tree)
dmatrix2 <- dist.nodes(tree)


dmatrix = dmatrix1[rownames(dmatrix1) %in% tolower(scbi_genus), colnames(dmatrix1) %in% tolower(eq_genus)]
save(dmatrix, file="data/taxo_dmatrix.rda")
