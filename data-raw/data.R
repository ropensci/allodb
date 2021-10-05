# Source this file to update all exported data.

library(usethis)
library(readr)
library(purrr)
library(fs)

# remember that your working directory should be allodb, use 'here" or getwd()
here::here()
getwd()

path_db <- "data-raw/csv_database"
db_nms <- path_ext_remove(path_file(dir_ls(path_db)))

db_ls <- dir_ls(path_db) %>%
  map(~ read_csv(.x, col_types = cols(.default = "c"))) %>%
  set_names(db_nms)

list2env(db_ls, globalenv())

# Ensure all equations are lowercase
equations$equation_allometry <- tolower(equations$equation_allometry)

# These datasets seem to only exist in data/
devtools::load_all()
# They once lacked the tbl subclass
scbi_stem1 <- tibble::as_tibble(scbi_stem1)
koppenMatrix <- tibble::as_tibble(koppenMatrix)
gymno_genus <- tibble::as_tibble(gymno_genus)
genus_family <- tibble::as_tibble(genus_family)

use_data(
  equations,
  equations_metadata,
  missing_values,
  references,
  references_metadata,
  sitespecies,
  sitespecies_metadata,
  sites_info,
  scbi_stem1,
  koppenMatrix,
  gymno_genus,
  genus_family,
  overwrite = TRUE
)
