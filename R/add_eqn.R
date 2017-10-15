x <- sample_n(bciex::bci12s7mini, 10) %>% as_tibble()
x

add_eqn <- function(x,
                    eqn,
                    eqn_site,
                    eqn_type = c("site", "species", "stem"),
                    eqn_source = c("user", "default")) {

  # Ensure unique identifier
  x <- tibble::rowid_to_column(x)
  x$eqn <- eqn
  x$eqn_site <- eqn_site
  x$eqn_type <- eqn_type[[1]]
  x$eqn_source <- eqn_source[[1]]
  dplyr::select(x, rowid, eqn_site, eqn_type, eqn_source, eqn, dplyr::everything())
}

add_eqn(x = x, eqn = "3 * dbh", eqn_site = "bci")


