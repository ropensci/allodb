
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://i.imgur.com/39pvr4n.png" align="right" height=44 /> allodb: Database of allometric equations

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/forestgeo/allodb.svg?branch=master)](https://travis-ci.org/forestgeo/allodb)
[![Coverage
status](https://coveralls.io/repos/github/forestgeo/allodb/badge.svg)](https://coveralls.io/r/forestgeo/allodb?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/allodb)](https://cran.r-project.org/package=allodb)

The goal of allodb is to develop, host and give access to tables of
allometric equations for ForestGEO’s network.

## Installation

    # install.packages("remotes")
    remotes::install_github("forestgeo/allodb", auth_token = "abc")

For details in how to install packages from GitHub see [this
article](https://fgeo.netlify.com/2018/02/05/2018-02-05-installing-packages-from-github/).

## Example

``` r
library(allodb)
```

Helpers.

``` r
# Helpers
show <- function(...) {
  out <- lapply(...)
  invisible(out)
}

allodb_datasets <- function() {
  sort(utils::data(package = "allodb")$results[ , "Item"])
}

glimpse <- function(x) {
  out <- capture.output(str(get(x), give.attr = FALSE, list.len = 3))
  cat(x, out, "\n", sep = "\n")
}
```

All datasets.

``` r
show(allodb_datasets(), glimpse)
#> default_eqn
#> Classes 'default_eqn', 'tbl_df', 'tbl' and 'data.frame': 619 obs. of  6 variables:
#>  $ equation_id: chr  "2060ea" "2060ea" "a4d879" "a4d879" ...
#>  $ site       : chr  "lilly dicky" "tyson" "lilly dicky" "tyson" ...
#>  $ sp         : chr  "acer rubrum" "acer rubrum" "acer saccharum" "acer saccharum" ...
#>   [list output truncated]
#> 
#> 
#> equations
#> Classes 'tbl_df', 'tbl' and 'data.frame':    175 obs. of  22 variables:
#>  $ ref_id                              : chr  "jenkins_2004_cdod" "jenkins_2004_cdod" "jenkins_2004_cdod" "jenkins_2004_cdod" ...
#>  $ equation_allometry                  : chr  "10^(1.1891+1.419*(log10(dbh^2)))" "10^(1.2315+1.6376*(log10(dbh^2)))" "exp(7.217+1.514*log(dbh))" "10^(2.5368+1.3197*(log10(dbh)))" ...
#>  $ equation_id                         : chr  "2060ea" "a4d879" "c59e03" "96c0af" ...
#>   [list output truncated]
#> 
#> 
#> equations_metadata
#> Classes 'tbl_df', 'tbl' and 'data.frame':    22 obs. of  7 variables:
#>  $ Column     : chr  "1 / A" "2 / B" "3 / C" "4 / D" ...
#>  $ Field      : chr  "equation_id" "equation_form" "equation_allometry" "dependent_variable_biomass_component" ...
#>  $ Description: chr  "Unique equation identification number given arbitrarely. Links to Site_Species table." "Algebraic form of the biomass equation as function of DBH" "Equation to calculate biomass (includes coeficients given in original publication)" "Tree component characterized by the equation" ...
#>   [list output truncated]
#> 
#> 
#> missing_values_metadata
#> Classes 'tbl_df', 'tbl' and 'data.frame':    4 obs. of  3 variables:
#>  $ Code       : chr  NA "NAC" "NRA" "NI"
#>  $ Definition : chr  "Not Applicable" "Not Acquired" "Not Readily Available" "No Information"
#>  $ Description: chr  "Data does not apply to that particular case" "Information may be available but has not been acquired." "Information was not readily available to the authors (e.g., no ready access to the publication, language barrier)." "No information available in original publication"
#> 
#> 
#> references_metadata
#> Classes 'tbl_df', 'tbl' and 'data.frame':    7 obs. of  4 variables:
#>  $ Column     : chr  "1 / A" "2 / B" "3 / C" "4 / D" ...
#>  $ Field      : chr  "ref_id" "ref_doi" "ref_author" "ref_year" ...
#>  $ Description: chr  "Unique reference identification number to our data source. Links to multiple tables." "Publication DOI (Digital object identifier)" "Last name of first author of a cited publication" "Year of publication" ...
#>   [list output truncated]
#> 
#> 
#> scbi_species
#> Classes 'tbl_df', 'tbl' and 'data.frame':    73 obs. of  10 variables:
#>  $ sp       : chr  "acne" "acpl" "acru" "acsp" ...
#>  $ Latin    : chr  "Acer negundo" "Acer platanoides" "Acer rubrum" "Acer sp" ...
#>  $ Genus    : chr  "Acer" "Acer" "Acer" "Acer" ...
#>   [list output truncated]
#> 
#> 
#> scbi_stem1
#> Classes 'tbl_df', 'tbl' and 'data.frame':    55295 obs. of  20 variables:
#>  $ treeID   : int  1 1 2 2 3 3 3 4 4 5 ...
#>  $ stemID   : int  1 31194 2 31195 3 31196 40394 4 31197 5 ...
#>  $ tag      : chr  "10079" "10079" "10168" "10168" ...
#>   [list output truncated]
#> 
#> 
#> scbi_stem2
#> Classes 'tbl_df', 'tbl' and 'data.frame':    55295 obs. of  20 variables:
#>  $ treeID   : int  1 1 2 2 3 3 3 4 4 5 ...
#>  $ stemID   : int  1 31194 2 31195 3 31196 40394 4 31197 5 ...
#>  $ tag      : chr  "10079" "10079" "10168" "10168" ...
#>   [list output truncated]
#> 
#> 
#> scbi_tree1
#> Classes 'tbl_df', 'tbl' and 'data.frame':    40283 obs. of  20 variables:
#>  $ treeID   : int  1 2 3 4 5 6 7 8 9 10 ...
#>  $ stemID   : int  1 2 3 4 5 6 7 8 9 10 ...
#>  $ tag      : chr  "10079" "10168" "10567" "12165" ...
#>   [list output truncated]
#> 
#> 
#> scbi_tree2
#> Classes 'tbl_df', 'tbl' and 'data.frame':    40283 obs. of  20 variables:
#>  $ treeID   : int  1 2 3 4 5 6 7 8 9 10 ...
#>  $ stemID   : int  1 2 3 4 5 6 31200 31201 31202 10 ...
#>  $ tag      : chr  "10079" "10168" "10567" "12165" ...
#>   [list output truncated]
#> 
#> 
#> sites_info
#> Classes 'tbl_df', 'tbl' and 'data.frame':    63 obs. of  12 variables:
#>  $ id           : chr  "42" "51" "52" "45" ...
#>  $ Site         : chr  "Amacayacu" "Badagongshan" "Baotianman" "Barro Colorado Island" ...
#>  $ site         : chr  "amacayacu" "badagongshan" "baotianman" "barro colorado island" ...
#>   [list output truncated]
#> 
#> 
#> sitespecies
#> Classes 'tbl_df', 'tbl' and 'data.frame':    679 obs. of  34 variables:
#>  $ site                                : chr  "Lilly Dicky" "Lilly Dicky" "Lilly Dicky" "Lilly Dicky" ...
#>  $ family                              : chr  "Sapindaceae" "Sapindaceae" "Rosaceae" "Rosaceae" ...
#>  $ species                             : chr  "Acer rubrum" "Acer saccharum" "Amelanchier arborea" "Amelanchier arborea" ...
#>   [list output truncated]
#> 
#> 
#> sitespecies_metadata
#> Classes 'tbl_df', 'tbl' and 'data.frame':    15 obs. of  8 variables:
#>  $ Column                                   : chr  "1 / A" "2 / B" "3 / C" "4 / D" ...
#>  $ Field                                    : chr  "site" "family" "species" "species_code" ...
#>  $ Description                              : chr  "ForestGEO site name (corresponds to name in ForestGEO sites master table)" "Plant family name as Taxonomic Name Resolution Services, an online free tool for correcting and standardizing plant names." "Plant scientific name as Taxonomic Name Resolution Services, an online free tool for correcting and standardizing plant names." "Species code used at the ForestGEO site, variable per site, even if representing same species ." ...
#>   [list output truncated]
#> 
#> 
#> wsg
#> Classes 'tbl_df', 'tbl' and 'data.frame':    549 obs. of  8 variables:
#>  $ wsg_id         : chr  NA NA NA NA ...
#>  $ family         : chr  "Sapindaceae" "Sapindaceae" "Rosaceae" "Annonaceae" ...
#>  $ species        : chr  "Acer rubrum" "Acer saccharum" "Amelanchier arborea" "Asimina triloba" ...
#>   [list output truncated]
#> 
#> 
#> wsg_metadata
#> Classes 'tbl_df', 'tbl' and 'data.frame':    9 obs. of  8 variables:
#>  $ Column                                   : chr  "1 / A" "2 / B" "3 / C" "4 / D" ...
#>  $ Field                                    : chr  "wsg_id" "family" "genus" "species" ...
#>  $ Description                              : chr  "Wood specific gravity unique identification number" "Plant family name as Taxonomic Name Resolution Services an online free tool for correcting and standardizing plant names." "Plant genus name as Taxonomic Name Resolution Services an online free tool for correcting and standardizing plant names." "Plant species name as Taxonomic Name Resolution Services an online free tool for correcting and standardizing plant names." ...
#>   [list output truncated]
```

## Plan

  - TODO: Move to new package **fgeo.biomass**

  - TODO: Rename/refactor so the pipeline becomes:

<!-- end list -->

``` r
<census> %>% 
  # May be a new class of object defined in fgeo.tool, and reexported by allo
  add_species(<species>) %>%      # from census_species()
  
  # Could include an argument `default_eqn` to use different default equations,
  # e.g. different versions of allodb stored in allodb.
  allo_find() %>%         # from get_equations()
  <allo_customize()> %>%  # New: Inserts custom equations
  allo_prioritize()       # from pick_best_equations()
  allo_evaluate()         # biomass?
```

  - TODO: Rename column from sp to species.

  - TODO: Document when a function creates or uses an S3 class.

ENHANCEMENTS

  - TODO: add\_species may be a generic with methods for census and vft
    – which should be classified from reading with read\_censuses,
    as\_censuses.

  - Add class vft and taxa to read\_vft() and read\_taxa().

  - Add methods for filter() (and maybe the other 4 main verbes) so that
    new classes aren’t dropped.
