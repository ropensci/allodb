# Wood density (with this scrip and master table we only take wsg for
# temperate sites, later to be merge with trop).

source(here::here("data-raw/data_master.R"))

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

wsg_metadata <- readr::read_csv(
  here::here("data-raw/data_wsg_metadata.csv")
)
usethis::use_data(wsg_metadata, overwrite = TRUE)
