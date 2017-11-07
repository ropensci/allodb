# Source: "Gonzalez, Erika B." <GonzalezEB@si.edu>

allo_temperate <- as_tibble(
  readxl::read_excel("./data-raw/Allometries_Temperate sites.xlsx")
)

use_data(allo_temperate)

