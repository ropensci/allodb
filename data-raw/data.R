# Source this file to update all exported data.

library(here)

path_db <- here("data-raw/csv_database")
tor::load_csv(path_db)

use_data(
  equations,
  equations_metadata,
  missing_values_metadata,
  references_metadata,
  sitespecies,
  sitespecies_metadata,
  sites_info,
  wsg,
  wsg_metadata,
  overwrite = TRUE
)
