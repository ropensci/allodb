# Allometric equations (doesn't include sites, but sp? not sure)

source(here::here("data-raw/data_master.R"))

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

equations_metadata <- readr::read_csv(
  here::here("data-raw/data_equations_metadata.csv")
)
usethis::use_data(equations_metadata, overwrite = TRUE)
