# References (links to wood density table with an id, my raw reference
# table includes sites for my own sanity!).

# source(here::here("data-raw/data_master.R"))

# TODO: Add table.

# usethis::use_data(references, overwrite = TRUE)

references_metadata <- readr::read_csv(
  here::here("data-raw/data_references_metadata.csv")
)
usethis::use_data(references_metadata, overwrite = TRUE)
