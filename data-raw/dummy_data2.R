# Create equation's tables at different levels.

library(tidyverse)
library(dplyr)
library(purrr)
library(tibble)



# Some data to use generally ----

some_bci <- bciex::bci12s7mini %>%
  filter(!is.na(sp), !is.na(dbh)) %>%
  select(sp, matches("dbh")) %>%
  filter(!duplicated(sp)) %>%
  sample_n(10)



# Site equations ----

fake_bci_site_eqn_default <- tibble_site_eqn(eqn = "3 * dbh", eqn_site = "bci",
  eqn_source = "default")

fake_bci_site_eqn_user <- tibble_site_eqn(eqn = "4 * dbh", eqn_site = "bci",
  eqn_source = "user")



# Species equations ----

equations <- paste0(1:10, " * dbh")
raw_spp_eqn <- some_bci %>%
  bind_cols(eqn = equations) %>%
  select(sp, eqn)

# default equations
fake_spp_eqn_default <- tibble_sp_eqn(x = raw_spp_eqn, eqn = "eqn", sp = "sp",
  eqn_site = "bci", eqn_source = "default")
fake_spp_eqn_default

# user's equations
raw_spp_eqn_user <- fake_spp_eqn_default[1:5, ]
fake_spp_eqn_user <- tibble_sp_eqn(x = raw_spp_eqn_user, eqn = "eqn", sp = "sp",
  eqn_site = "bci", eqn_source = "user") %>%
  # Change user's equation to make them different from default ones
  mutate(eqn = paste0(21:25, " * dbh"))
fake_spp_eqn_user



# Stem equations ----

raw_fake_stem_eqn_user <- fake_spp_eqn_default %>%
  left_join(some_bci) %>%
  mutate(eqn = paste0(31:40, " * dbh")) %>%
  rowid_to_column()

fake_stem_eqn_user <- tibble_stem_eqn(x = raw_fake_stem_eqn_user,
  eqn = "eqn", sp = "sp", stemid = "rowid",
dbh = "dbh", eqn_site = "bci")
fake_stem_eqn_user



# Combine all tables ----

fake_default_eqn <- tibble_all_eqn(fake_bci_site_eqn_default,
  fake_spp_eqn_default)
usethis::use_data(fake_default_eqn, overwrite = TRUE)

fake_user_eqn <- tibble_all_eqn(fake_bci_site_eqn_user, fake_spp_eqn_user,
  fake_stem_eqn_user)
usethis::use_data(fake_user_eqn, overwrite = TRUE)

