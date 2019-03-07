# Source this file to update all exported data.

library(here)
library(tidyverse)
library(fs)

path_db <- here("data-raw/csv_database")
db_nms <- path_ext_remove(path_file(dir_ls(path_db)))

db_ls <- dir_ls(path_db) %>%
  map(~read_csv(.x, col_types = cols(.default = "c"))) %>%
  set_names(db_nms)

list2env(db_ls, globalenv())

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
