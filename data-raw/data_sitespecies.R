# Site-species (includes non-tropical sites, links to equation table with eq
# Id).

source(here::here("data-raw/data_master.R"))

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

sitespecies_metadata <- readr::read_csv(
  here::here("data-raw/data_sitespecies_metadata.csv")
)
usethis::use_data(sitespecies_metadata, overwrite = TRUE)

