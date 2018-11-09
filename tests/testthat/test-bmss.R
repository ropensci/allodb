context("bmss_lst")

# Arguments
dbh_sp <- scbi_tree1
species <- scbi_species
site <- "scbi"
# Standardize equations table (TODO: Store the standardized version for speed)
default_eqn <- bmss_default_eqn(allodb::master())

# Translate species codes to latin names
dbh_species <- bmss_cns(dbh_sp, species, site)

.eqn_types <- na.omit(unique(default_eqn$eqn_type))

get_eqn_type <- function(dbh_species, default_eqn, this_type) {
  this_eqn <- dplyr::filter(default_eqn, .data$eqn_type %in% this_type)
  bmss::get_allometry(dbh_species, "site", "sp", "dbh", default_eqn = this_eqn)
}


out <- purrr::map(
  eqn_types[1:2],
)




bmss_type <- function(dbh_sp, .type) {
  default_type <- master() %>%
    filter(allometry_specificity == .type) %>%
    bmss_default_eqn()

  suppressMessages(
    bmss(dbh_sp, default_type)
  )
}

types <- master() %>%
  pull(allometry_specificity) %>%
  unique() %>%
  na.omit()

by_type <- types %>%
  map(~bmss_type(dbh_sp, .type = .x)) %>%
  set_names(types)

by_type
