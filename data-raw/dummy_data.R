# Create dummy tables of allometric equations.

library(dplyr)
library(purrr)
library(tidyr)
library(tibble)
library(pryr)
library(usethis)



# Iteration 1. Separate tables. -------------------------------------------


# This is replaced by the section below

# Get species from two sites in ForestGEO's network
site <- list(bci = bci::bci12stem7, yosemite = yosemite::yosemite_s2_lao)

# Link site with species
site_spp <- site %>%
  map(., select, matches("sp")) %>%
  map(unique) %>%
  # map(head) %>%
  enframe() %>%
  unnest() %>%
  set_names(c("site", "spp")) %>%
  map_df(tolower) %>%
  arrange(site, spp)
use_data(site_spp, overwrite = TRUE)



# Create fake equations by site and species.
# Note: Each equation has the format <param * dbh>, where I invent the value of
# param, and also invent the relationship between param and dbh; dbh represents
# the dbh value that the user provides for each stem.

# Site equations.
site_eqn <- tribble(
  # ----------------------------------
  ~site,      ~site_eqn,
  # --------- ------------------------
  "bci",      function(dbh) {1 * dbh},
  "yosemite", function(dbh) {2 * dbh}
  # ----------------------------------
)
use_data(site_eqn, overwrite = TRUE)

# Species equations.
spp_eqn <- tribble(
  # ---------------------------------
  ~spp,     ~spp_eqn,
  # ------- -------------------------
  "swars1", function(dbh) {3 * dbh},
  "hybapr", function(dbh) {4 * dbh},
  "aegipa", function(dbh) {5 * dbh},
  "beilpe", function(dbh) {6 * dbh},
  "faraoc", function(dbh) {7 * dbh},
  "tet2pa", function(dbh) {8 * dbh},
  "pila",   function(dbh) {9 * dbh},
  "abco",   function(dbh) {10 * dbh}
  # ---------------------------------
)
use_data(spp_eqn, overwrite = TRUE)



# Create fake user's data, with some species for which the user knows the
# equations; some other for which the user lacks equations, and some rows
# where dbh is NA.

# User's equations.
user_eqn <- tribble(
  # ---------------------------------
  ~site, ~spp,     ~user_eqn,                ~dbh,
  # ------- -------------------------
  "bci", "swars1", function(dbh) {11 * dbh}, 50,
  "bci", "hybapr", function(dbh) {12 * dbh}, 12,
  "bci", "aegipa", function(dbh) {13 * dbh}, 26,
  "bci", "beilpe", function(dbh) {14 * dbh}, 40,
  "bci", "faraoc", NA,                       88,
  "bci", "tet2pa", NA,                       58,
  "bci", "pila",   NA,                       124,
  "bci", "abco",   NA,                       20,
  "bci", NA,       NA,                       NA,
  "bci", NA,       NA,                       NA
  # ---------------------------------
)
user_eqn <- select(user_eqn, site, spp, dbh, user_eqn)
use_data(user_eqn, overwrite = TRUE)










# Iteration 2: Composite table. -------------------------------------------

# User's equations.

library(tidyverse)

default_eqn <- tibble(
  site = "bci",
  sp = ,
  eqn = ,
  eqn_type = ,
  eqn_source = "defaul"
)

# Some sp and dbh data from bciex
some_ok_dbh <- bciex::bci12s7mini %>%
  select(sp, dbh) %>%
  filter(!is.na(dbh)) %>%
  unique() %>%
  sample_n(6)
some_na_dbh <- bciex::bci12s7mini %>%
  select(sp, dbh) %>%
  filter(is.na(dbh)) %>%
  unique() %>%
  sample_n(2)
all_na <- tibble(sp = rep(NA_character_, 2), dbh = rep(NA_real_, 2))
sp_dbh <- reduce(list(some_ok_dbh, some_na_dbh, all_na), bind_rows)

type <- c(rep("sp", nrow(sp_dbh) - nrow(some_na_dbh)),
  rep("site", nrow(some_na_dbh)))
add_to_user_eqn <- tibble(
  site = "bci",
  eqn = paste(sample(1:100, nrow(sp_dbh)), paste("*", "dbh")),
  eqn_type = type,
  eqn_source = "user")
user_eqn <- bind_cols(sp_dbh, add_to_user_eqn) %>%
  select(site, sp, dbh)




# This replaces all of the above.

# Write funcitons:
# add_stem_eqn(x, stemid, dbh, eqn, , site, type = "stem", source = c("user", "default))
# add_sp_eqn(x, eqn, sp, site, type = "sp", source =  c("user", "default))
# add_site_eqn(x, eqn, site, type = "site", source =  c("user", "default))

# With this buils both user and default equations.
# Then join to make composite.

