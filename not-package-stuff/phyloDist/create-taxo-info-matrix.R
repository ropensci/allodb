#### create genus - family - life form - group data ####
packages_needed = c("data.table", "taxize")
packages_to_install = packages_needed[!(packages_needed %in% rownames(installed.packages()))]
if (length(packages_to_install) > 0)
  install.packages(packages_to_install)
lapply(packages_needed, require, character.only = TRUE)

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

## shrub species ####
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

## family ####
data("sitespecies")
data("equations")
### keep all genera in both census and equation tables, and all families in equation table
genus_equations = equations$equation_taxa[equations$allometry_specificity %in% c("Genus", "Species")]
## replace special chinese characters
sitespecies$genus = gsub("  ", " ", gsub("<[^>]+>", " ", enc2native(sitespecies$genus)))
genus_all = unique(tstrsplit(c(sitespecies$genus, genus_equations), " ")[[1]])
genus_all = genus_all[-grep("evergreen|uniden|unk", tolower(genus_all))]
## some corrections
genus_all = paste0(toupper(substring(genus_all, 1,1)), substring(genus_all, 2))
genus_all[genus_all=="Heteropanaxfragrans"] = "Heteropanax"
genus_all[grep("cerasus", genus_all)] = "Prunus"
genus_all = unique(genus_all)

#### retrieve from itis data base
taxoInfo = c()
lgenus = split(genus_all, ceiling(seq_along(genus_all)/20))
for (i in 1:length(lgenus)) {
  temp = tax_name(query = lgenus[[i]], get = "family", db = "itis", accepted = TRUE,
                  rank_filter = "genus", division_filter = "dicot")[, -1]
  taxoInfo = rbind(taxoInfo, temp)
}
colnames(taxoInfo)[1] = "genus"
taxoInfo[is.na(taxoInfo$family),]
## complete missing information
taxoInfo$family[taxoInfo$genus == "Acanthopanax"] = "Araliaceae"
taxoInfo$family[taxoInfo$genus == "Cyclobalanopsis"] = "Fagaceae"
taxoInfo$family[taxoInfo$genus == "Mahonia"] = "Berberidaceae"
taxoInfo$family[taxoInfo$genus == "Manglietia"] = "Magnoliaceae"
taxoInfo$family[taxoInfo$genus == "Michelia"] = "Magnoliaceae"
taxoInfo$family[taxoInfo$genus == "Chimonanthus"] = "Calycanthaceae"
taxoInfo$family[taxoInfo$genus == "Machilus"] = "Lauraceae"
taxoInfo$family[taxoInfo$genus == "Neolitsea"] = "Lauraceae"
taxoInfo$family[taxoInfo$genus == "Distylium"] = "Hamamelidaceae"
taxoInfo$family[taxoInfo$genus == "Loropetalum"] = "Hamamelidaceae"
taxoInfo$family[taxoInfo$genus == "Evodia"] = "Rutaceae"
taxoInfo$family[taxoInfo$genus == "Phyllanthus"] = "Phyllanthaceae"
taxoInfo$family[taxoInfo$genus == "Daphniphyllum"] = "Daphniphyllaceae"
taxoInfo$family[taxoInfo$genus == "Euscaphis"] = "Staphyleaceae"
taxoInfo$family[taxoInfo$genus == "Adinandra"] = "Pentaphylacaceae"
taxoInfo$family[taxoInfo$genus == "Schima"] = "Theaceae"
taxoInfo$family[taxoInfo$genus == "Pyrenaria"] = "Theaceae"
taxoInfo$family[taxoInfo$genus == "Idesia"] = "Salicaceae"
taxoInfo$family[taxoInfo$genus == "Alangium"] = "Cornaceae"
taxoInfo$family[taxoInfo$genus == "Dendrobenthamia"] = "Cornaceae"
taxoInfo$family[taxoInfo$genus == "Pieris"] = "Ericaceae"
taxoInfo$family[taxoInfo$genus == "Alniphyllum"] = "Styracaceae"
taxoInfo$family[taxoInfo$genus == "Callicarpa"] = "Lamiaceae"
taxoInfo$family[taxoInfo$genus == "Pertusadina"] = "Rubiaceae"
taxoInfo$family[taxoInfo$genus == "Sinoadina"] = "Rubiaceae"
taxoInfo$family[taxoInfo$genus == "Adina"] = "Rubiaceae"
taxoInfo$family[taxoInfo$genus == "Blastus"] = "Melastomataceae"
taxoInfo$family[taxoInfo$genus == "Bretschneidera"] = "Akaniaceae"
taxoInfo$family[taxoInfo$genus == "Carallia"] = "Rhizophoraceae"
taxoInfo$family[taxoInfo$genus == "Craibiodendron"] = "Ericaceae"
taxoInfo$family[taxoInfo$genus == "Dichroa"] = "Hydrangeaceae"
taxoInfo$family[taxoInfo$genus == "Engelhardia"] = "Juglandaceae"
taxoInfo$family[taxoInfo$genus == "Exbucklandia"] = "Hamamelidaceae"
taxoInfo$family[taxoInfo$genus == "Hartia"] = "Theaceae"
taxoInfo$family[taxoInfo$genus == "Heteropanax"] = "Araliaceae"
taxoInfo$family[taxoInfo$genus == "Huodendron"] = "Styracaceae"
taxoInfo$family[taxoInfo$genus == "Ixonanthes"] = "Ixonanthaceae"
taxoInfo$family[taxoInfo$genus == "Microtropis"] = "Celastraceae"
taxoInfo$family[taxoInfo$genus == "Mytilaria"] = "Hamamelidaceae"
taxoInfo$family[taxoInfo$genus == "Olea"] = "Oleaceae"
taxoInfo$family[taxoInfo$genus == "Pentaphylax"] = "Pentaphylacaceae"
taxoInfo$family[taxoInfo$genus == "Polyalthia"] = "Annonaceae"
taxoInfo$family[taxoInfo$genus == "Rapanea"] = "Primulaceae"
taxoInfo$family[taxoInfo$genus == "Rehderodendron"] = "Styracaceae"
taxoInfo$family[taxoInfo$genus == "Saurauia"] = "Actinidiaceae"
taxoInfo$family[taxoInfo$genus == "Sinosideroxylon"] = "Sapotaceae"
taxoInfo = rbind(taxoInfo, c("Sarcosperma", "Sapotaceae")) ## accepted name of Sinosideroxylon
taxoInfo$family[taxoInfo$genus == "Tsoongiodendron"] = "Magnoliaceae"
taxoInfo = rbind(taxoInfo, c("Magnolia", "Magnoliaceae")) ## accepted name of Tsoongiodendron
taxoInfo = unique(taxoInfo)

genus_family = taxoInfo
save(genus_family, file = "data/genus_family.rda")

### get all coniferous genera ####
## dowloaded from http://www.theplantlist.org/1.1/browse/G/ on 2020-08-06
gymno_files = list.files("phyloDist/gymno_the-plant-list/", full.names = TRUE)
gymno_species = rbindlist(lapply(gymno_files, read.csv))

gymno_genus = unique(gymno_species[, c("Family", "Genus")])
gymno_genus$conifer = gymno_genus$Family %in% c("Pinaceae", "Podocarpaceae",
                                            "Cupressaceae", "Araucariaceae",
                                            "Cephalotaxaceae", "Phyllocladaceae",
                                            "Sciadopityaceae", "Taxaceae")
save(gymno_genus, file = "data/gymno_genus.rda")
