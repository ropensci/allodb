Gather raw data,clean it and export it to data/
================

# Overview

This document exports data. It takes data from data-raw/, cleans it, and
places a .rda version of it in data/. To update all exported data you
can do either of two things: (1) Click Knit (Ctrl+Shift+K), which will
also update data.md, or (2) Run \> Run All (Ctrl+Alt+R). You can also
update the data in specific code chunks. (Learn more about RMarkdown
documents [here](https://rmarkdown.rstudio.com/lesson-1.html).)

# Setup

``` r
library(tidyverse)
#> -- Attaching packages ---------------------------------------------- tidyverse 1.2.1 --
#> v ggplot2 2.2.1     v purrr   0.2.4
#> v tibble  1.4.2     v dplyr   0.7.4
#> v tidyr   0.8.0     v stringr 1.3.0
#> v readr   1.1.1     v forcats 0.3.0
#> -- Conflicts ------------------------------------------------- tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(here)
#> here() starts at C:/Users/LeporeM/Dropbox/git_repos/allodb
library(usethis)
```

# Gather raw master data and clean it

``` r
master <- read_csv(here("data-raw/allotemp_main.csv"))
#> Parsed with column specification:
#> cols(
#>   .default = col_character(),
#>   n_sampled = col_integer(),
#>   a = col_double(),
#>   b = col_double(),
#>   c = col_double(),
#>   d = col_double(),
#>   n_trees = col_integer()
#> )
#> See spec(...) for full column specifications.
```

``` r
# FIXME: Remove ambiguity of this code chunk (#29; https://goo.gl/rmuzmH)
# eliminate rows where fam or sp is unknown #use unique(allo_main$species)
master <- subset(master, family != "Unkown")
# chnage name of "equation" column to "equation_form"
```

# Export subsets of the clean master data

This section exports subsets of the clean master data to data/. Each
dataset documented in R/data.R to produce a help file that can be
accessed from the R console with `?name-of-the-dataset` and also from
the Functions Index tab of the website of **allodb**.

## `equations`

Allometric equations (doesn’t include sites, but sp? not sure)

``` r
# Needs to include a column after'equation_form' to combine
# coeficienss+formula so we get "unique" equations, then give unique id
equations_cols <- c(
  "equation_id",
  "model_parameters",
  "biomass_units_original",
  "regression_model",
  "other_equations_tested",
  "log (biomass)",
  "d",
  "dbh_min_cm",
  "dbh_max_cm",
  "n_trees",
  "dbh_units_original",
  "equation",
  "equation_grouping",
  "bias correction _CF"
)
equations <- as.tibble(master[equations_cols])
use_data(equations, overwrite = TRUE)
#> <U+2714> Saving equations to data/equations.rda

equations_metadata <- read_csv(
  here("data-raw/data_equations_metadata.csv")
)
#> Parsed with column specification:
#> cols(
#>   Column = col_character(),
#>   Field = col_character(),
#>   Description = col_character(),
#>   `Alphanumeric attributes/ storage type (present data values)` = col_character(),
#>   `Variable codes` = col_character(),
#>   Units = col_character(),
#>   Range = col_character(),
#>   `Erikas notes to delete before publication` = col_character()
#> )
use_data(equations_metadata, overwrite = TRUE)
#> <U+2714> Saving equations_metadata to data/equations_metadata.rda
```

## `missing_values`

``` r
missing_values_metadata <- read_csv(
  here("data-raw/data_missing_values_metadata.csv")
)
#> Warning: Missing column names filled in: 'X4' [4], 'X5' [5], 'X6' [6],
#> 'X7' [7]
#> Parsed with column specification:
#> cols(
#>   Code = col_character(),
#>   Definition = col_character(),
#>   Description = col_character(),
#>   X4 = col_character(),
#>   X5 = col_character(),
#>   X6 = col_character(),
#>   X7 = col_character()
#> )
use_data(missing_values_metadata, overwrite = TRUE)
#> <U+2714> Saving missing_values_metadata to data/missing_values_metadata.rda
```

## `references`

References (links to wood density table with an id, my raw reference
table includes sites for my own sanity\!).

``` r
# TODO: Add table.

references_metadata <- read_csv(
  here("data-raw/data_references_metadata.csv")
)
#> Parsed with column specification:
#> cols(
#>   Column = col_character(),
#>   Field = col_character(),
#>   Description = col_character(),
#>   `Alphanumeric attributes/ storage type (present data values)` = col_character(),
#>   `Variable codes` = col_character(),
#>   Units = col_character(),
#>   Range = col_character(),
#>   `Notes to be deleted later` = col_character()
#> )
use_data(references_metadata, overwrite = TRUE)
#> <U+2714> Saving references_metadata to data/references_metadata.rda
```

## `sites_info`

``` r
sites_info <- read_csv(
  here("data-raw/data_sites_info.csv")
)
#> Parsed with column specification:
#> cols(
#>   id = col_double(),
#>   Site = col_character(),
#>   site = col_character(),
#>   lat = col_double(),
#>   long = col_double(),
#>   UTM_Zone = col_integer(),
#>   UTM_X = col_character(),
#>   UTM_Y = col_character(),
#>   intertropical = col_character(),
#>   size.ha = col_double(),
#>   E = col_double(),
#>   wsg.site.name = col_character()
#> )
use_data(sites_info, overwrite = TRUE)
#> <U+2714> Saving sites_info to data/sites_info.rda
```

## `sitespecies`

Site-species (includes non-tropical sites, links to equation table with
eq Id).

``` r
sitespecies_cols <- c(
  "site",
  "family",
  "species",
  "species_code",
  "life_form",
  "model_parameters",
  "allometry_development_method",
  "equation_id",
  "regression_model",
  "wsg",
  "wsg_id"
)
sitespecies <- as.tibble(master[sitespecies_cols])
use_data(sitespecies, overwrite = TRUE)
#> <U+2714> Saving sitespecies to data/sitespecies.rda

sitespecies_metadata <- read_csv(
  here("data-raw/data_sitespecies_metadata.csv")
)
#> Parsed with column specification:
#> cols(
#>   Column = col_character(),
#>   Field = col_character(),
#>   Description = col_character(),
#>   `Alphanumeric attributes/ storage type (present data values)` = col_character(),
#>   `Variable codes` = col_character(),
#>   Units = col_character(),
#>   Range = col_character(),
#>   `Erikas notes to delete before publication` = col_character()
#> )
use_data(sitespecies_metadata, overwrite = TRUE)
#> <U+2714> Saving sitespecies_metadata to data/sitespecies_metadata.rda
```

## `wsg`

Wood density (with this scrip and master table we only take wsg for
temperate sites, later to be merge with trop).

``` r
wsg_cols <- c(
  "wsg_id",
  "family",
  "species",
  "wsg",
  "wsg_specificity",
  "variable",
  "site"
)
wsg <- as.tibble(master[wsg_cols])
use_data(wsg, overwrite = TRUE)
#> <U+2714> Saving wsg to data/wsg.rda

wsg_metadata <- read_csv(
  here("data-raw/data_wsg_metadata.csv")
)
#> Parsed with column specification:
#> cols(
#>   Column = col_character(),
#>   Field = col_character(),
#>   Description = col_character(),
#>   `Alphanumeric attributes/ storage type (present data values)` = col_character(),
#>   `Variable codes` = col_character(),
#>   Units = col_character(),
#>   Range = col_character(),
#>   `Erikas notes to delete before publication` = col_character()
#> )
use_data(wsg_metadata, overwrite = TRUE)
#> <U+2714> Saving wsg_metadata to data/wsg_metadata.rda
```
