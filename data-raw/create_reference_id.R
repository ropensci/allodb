# Create a reference id from author and year

library(tidyverse)

strip_odd_chars <- function(x) gsub("[.,\\)\\(]", "", x)

# From commit SHA t f8962bc
master <- readr::read_csv("data-raw/allodb_master.csv")
author_year <- master %>%
  select(biomass_equation_source) %>%
  mutate(
    author_year = strip_odd_chars(tolower(paste0(
      map_chr(strsplit(master$biomass_equation_source, split = " "), first),
      "_",
      map_chr(strsplit(master$biomass_equation_source, split = " "), last)
    )))
  ) %>%
  select(-biomass_equation_source) %>%
  unique()




ref <- readr::read_csv("data-raw/data_references.csv")
references_table <- ref %>%
  mutate(
    ref_author = strip_odd_chars(tolower(ref_author)),
    ) %>%
  unite(author_year, ref_author, ref_year)



right_join(references_table, author_year) %>%
  unique() %>%
  write_csv("data-raw/data_references_id.csv")


