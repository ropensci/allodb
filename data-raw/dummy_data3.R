library(tidyverse)

sm <- tibble::tribble(~sp, ~equation, ~id, ~dbh,
                    "sp1",        NA, 200,   33,
                    "sp1", "3 * dbh", 111,   40,
                    "sp1", "7 * dbh", 221,   15,
                    "sp1", "5 * dbh", 332,   40)
sm

ss <- tibble::tribble(~sp, ~equation, ~id, ~dbh,
                    "sp1",        NA, 200,   33,
                    "sp2", "8 * dbh", 111,   40,
                    "sp2", "8 * dbh", 221,   15,
                    "sp4", "5 * dbh", 332,   40)
ss

se <- tibble::tribble(~sp, ~equation, ~id, ~dbh,
                    "sp1",        NA, 200,   33,
                    "sp2", "4 * dbh", 111,   40,
                    "sp3", "4 * dbh", 221,   15,
                    "sp4", "4 * dbh", 332,   40)
se





stem <- table_eqn(x = sm, eqn = "equation", sp = "sp", dbh = "dbh",
  site = "bci", eqn_type = "stem")

sp <- table_eqn(x = ss, eqn = "equation", sp = "sp", dbh = "dbh",
  site = "bci", eqn_type = "species")

site <- table_eqn(x = se, eqn = "equation", sp = "sp", dbh = "dbh",
  site = "bci", eqn_type = "site")

all_na <- tibble::tribble(~sp, ~eqn, ~dbh,
                           NA,   NA,   NA)
dummy_user_eqn <- combine_eqn(stem, site, sp) %>%
  arrange(eqn_type) %>%
  unique() %>%
  bind_rows(all_na)
usethis::use_data(dummy_user_eqn, overwrite = TRUE)
