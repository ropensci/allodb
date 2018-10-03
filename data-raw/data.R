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

use_data(equations, overwrite = TRUE)
use_data(equations_metadata, overwrite = TRUE)
use_data(missing_values_metadata, overwrite = TRUE)
use_data(references_metadata, overwrite = TRUE)
use_data(sitespecies, overwrite = TRUE)
use_data(sitespecies_metadata, overwrite = TRUE)
use_data(sites_info, overwrite = TRUE)
use_data(wsg, overwrite = TRUE)
use_data(wsg_metadata, overwrite = TRUE)
