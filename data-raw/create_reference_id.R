# Create a reference id from author and year

library(tidyverse)



strip_odd_chars <- function(x) gsub("[.,\\)\\(]", "", x)

four <- function(x) {
  out <- x[1:4]
  if (length(x) <= 4) out <- x
  out
}

glue4initials <- function(x){
  strsplit(x, " ")[[1]] %>%
    purrr::map(strsplit, "") %>%
    purrr::modify_depth(2, dplyr::first) %>%
    unlist() %>%
    four() %>%
    paste0(collapse = "")
}



#' Create a citation id.
#'
#' Citation ID in the form [last name of first author][year][first letter of
#' first four words of title, when applicable].

# From commit SHA t f8962bc
master <- readr::read_csv("data-raw/allodb_master.csv")
author_year <- master %>%
  select(biomass_equation_source, equation_allometry) %>%
  mutate(
    ref_author = strip_odd_chars(tolower(
      map_chr(strsplit(master$biomass_equation_source, split = " "), first)
    )),
    ref_year = strip_odd_chars(tolower(
      map_chr(strsplit(master$biomass_equation_source, split = " "), last)
    ))
  ) %>%
  purrr::modify(as.character)
author_year

ref <- readr::read_csv("data-raw/data_references.csv")
references_table <- ref %>%
  mutate(
    ref_author = strip_odd_chars(tolower(ref_author)),
    ) %>%
  purrr::modify(as.character)

combo <- right_join(
  references_table, author_year, by = c("ref_author", "ref_year")
  ) %>%
  unique()

refid <- combo %>%
  mutate(title4 = map_chr(tolower(ref_title), glue4initials)) %>%
  unite("refid", ref_author, ref_year, title4, remove = FALSE) %>%
  select(-title4) %>%
  select(
    refid, ref_doi, ref_author, ref_year, ref_title, ref_journal, everything()
  )

equations <- readr::read_csv(here::here("data-raw/csv_database/equations.csv"))

refid %>%
  select(refid, equation_allometry) %>%
  right_join(equations) %>%
  select(refid, ref_id, everything()) %>%
  unique() %>%
  readr::write_csv(here::here("data-raw/csv_database/equations_refid.csv"))
