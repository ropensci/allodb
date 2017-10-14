# Create dummy tables of allometric equations.

library(dplyr)
library(purrr)
library(tidyr)
library(tibble)
library(pryr)
library(usethis)



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
  "beilpe", function(dbh) {6 * dbh}
  "faraoc", function(dbh) {7 * dbh},
  "tet2pa", function(dbh) {8 * dbh},
  "pila",   function(dbh) {9 * dbh},
  "abco",   function(dbh) {10 * dbh}
  # ---------------------------------
)

use_data(spp_eqn, overwrite = TRUE)



# User's equations.
user_eqn <- tribble(
  # ---------------------------------
  ~site, ~spp,     ~spp_eqn,                 ~dbh,
  # ------- -------------------------
  "bci", "swars1", function(dbh) {11 * dbh}, 50,
  "bci", "hybapr", function(dbh) {12 * dbh}, 12,
  "bci", "aegipa", function(dbh) {13 * dbh}, 26,
  "bci", "beilpe", function(dbh) {14 * dbh}, 40,
  "bci", "faraoc", function(dbh) {15 * dbh}, 88,
  "bci", "tet2pa", function(dbh) {16 * dbh}, 58,
  "bci", "pila",   function(dbh) {17 * dbh}, 124,
  "bci", "abco",   function(dbh) {18 * dbh}, 20
  # ---------------------------------
)
use_data(user_eqn, overwrite = TRUE)
