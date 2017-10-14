
<!-- README.md is generated from README.Rmd. Please edit that file -->
allodb: A database of allometric equations for ForestGEO
========================================================

The goal of allodb is to develop, host and give access to tables of allometric equations for ForestGEO's network.

Installation
------------

You can install allodb from github with:

``` r
# install.packages("devtools")
devtools::install_github("forestgeo/allodb")
```

Example
-------

``` r
library(allodb)
library(tibble)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union



# Table of FAKE allometric equations by site.
allodb::site_eqn
#> # A tibble: 2 x 2
#>       site site_eqn
#>      <chr>   <list>
#> 1      bci    <fun>
#> 2 yosemite    <fun>

# Pull the FAKE allometric equation of bci.
allodb::site_eqn[[1, 2]]
#> function(dbh) {1 * dbh}

# Table of FAKE allometric equations by species.
spp_eqn
#> # A tibble: 8 x 2
#>      spp spp_eqn
#>    <chr>  <list>
#> 1 swars1   <fun>
#> 2 hybapr   <fun>
#> 3 aegipa   <fun>
#> 4 beilpe   <fun>
#> 5 faraoc   <fun>
#> 6 tet2pa   <fun>
#> 7   pila   <fun>
#> 8   abco   <fun>

# Combine FAKE allometric equations by site and species.
(with_site_eqn <- full_join(site_spp, site_eqn))
#> Joining, by = "site"
#> # A tibble: 337 x 3
#>     site    spp site_eqn
#>    <chr>  <chr>   <list>
#>  1   bci acacme    <fun>
#>  2   bci acaldi    <fun>
#>  3   bci acalma    <fun>
#>  4   bci ade1tr    <fun>
#>  5   bci aegipa    <fun>
#>  6   bci alchco    <fun>
#>  7   bci alchla    <fun>
#>  8   bci alibed    <fun>
#>  9   bci allops    <fun>
#> 10   bci alsebl    <fun>
#> # ... with 327 more rows
with_site_eqn
#> # A tibble: 337 x 3
#>     site    spp site_eqn
#>    <chr>  <chr>   <list>
#>  1   bci acacme    <fun>
#>  2   bci acaldi    <fun>
#>  3   bci acalma    <fun>
#>  4   bci ade1tr    <fun>
#>  5   bci aegipa    <fun>
#>  6   bci alchco    <fun>
#>  7   bci alchla    <fun>
#>  8   bci alibed    <fun>
#>  9   bci allops    <fun>
#> 10   bci alsebl    <fun>
#> # ... with 327 more rows
with_site_and_spp_eqn <- full_join(with_site_eqn, spp_eqn)
#> Joining, by = "spp"
with_site_and_spp_eqn
#> # A tibble: 337 x 4
#>     site    spp site_eqn spp_eqn
#>    <chr>  <chr>   <list>  <list>
#>  1   bci acacme    <fun>  <NULL>
#>  2   bci acaldi    <fun>  <NULL>
#>  3   bci acalma    <fun>  <NULL>
#>  4   bci ade1tr    <fun>  <NULL>
#>  5   bci aegipa    <fun>   <fun>
#>  6   bci alchco    <fun>  <NULL>
#>  7   bci alchla    <fun>  <NULL>
#>  8   bci alibed    <fun>  <NULL>
#>  9   bci allops    <fun>  <NULL>
#> 10   bci alsebl    <fun>  <NULL>
#> # ... with 327 more rows

# Pull the FAKE allometric equation of species "abco".
only_abco <- filter(with_site_and_spp_eqn, spp == "abco")
pull(only_abco, spp_eqn)[[1]]
#> function(dbh) {10 * dbh}
```
