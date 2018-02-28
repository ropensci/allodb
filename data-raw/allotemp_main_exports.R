# Build the core tables of the data paper.

# Setup and import --------------------------------------------------------

# install.package("readr")
# install.package("here")
# install.package("usethis")
# install.package("stringr")

path_to_data <- here::here("data-raw/allotemp_main.csv")
master <- readr::read_csv(path_to_data)



# Subset and export -------------------------------------------------------

# FIXME: Remove ambiguity of this code chunk (#29; https://goo.gl/rmuzmH)
# eliminate rows where fam or sp is unknown #use unique(allo_main$species)
master <- subset(master, family != "Unkown")
# chnage name of "equation" column to "equation_form"



# Basic info ForestGEO sites (could be modified from
# forestgeo/Site-Data repository).
# TODO: Add table. See https://goo.gl/ic7uya.



# Site-species (includes non-tropical sites, links to equation table
# with eq Id).
sitespecies_cols <- c(
    "site",
    "family",
    "species",
    "species_code",
    "life_form",
    "model_parameters",
    "allometry_development_method",
    "equation_id",
    "regression_model",
    "wsg",
    "wsg_id"
)
sitespecies <- master[sitespecies_cols]
usethis::use_data(sitespecies, overwrite = TRUE)



# Allometric equations (doesn't include sites, but sp? not sure)
# Needs to include a column after'equation_form' to combine
# coeficienss+formula so we get "unique" equations, then give unique id
equations_cols <- c(
    "equation_id",
    "model_parameters",
    "biomass_units_original",
    "regression_model",
    "other_equations_tested",
    "log (biomass)",
    "d",
    "dbh_min_cm",
    "dbh_max_cm",
    "n_trees",
    "dbh_units_original",
    "equation",
    "equation_grouping",
    "bias correction _CF"
)
equations <- master[equations_cols]
usethis::use_data(equations, overwrite = TRUE)

# Wood density (with this scrip and master table we only take wsg for
# temperate sites, later to be merge with trop).
wsg_cols <- c(
  "wsg_id",
  "family",
  "species",
  "wsg",
  "wsg_specificity",
  "variable",
  "site"
)
wsg <- master[wsg_cols]
usethis::use_data(wsg, overwrite = TRUE)



# References (links to wood density table with an id, my raw reference
# table includes sites for my own sanity!).
# TODO: Add table.
