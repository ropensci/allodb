
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

## Plan

  - TODO: Move to new package **allo**

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

## Example

This example shows how to to calculate biomass using ForestGEO-like
census data and allometric equations from the **allodb** package.

``` r
library(allodb)
# General purpose tools
library(dplyr)
```

Create a dataset with information on the dbh and latin species
name.

``` r
dbh_species <- census_species(allodb::scbi_tree1, allodb::scbi_species, "scbi")
dbh_species
#> # A tibble: 40,283 x 4
#>    rowid site  sp                     dbh
#>  * <int> <chr> <chr>                <dbl>
#>  1     1 scbi  lindera benzoin       27.9
#>  2     2 scbi  lindera benzoin       23.7
#>  3     3 scbi  lindera benzoin       22.2
#>  4     4 scbi  nyssa sylvatica      135  
#>  5     5 scbi  hamamelis virginiana  87  
#>  6     6 scbi  hamamelis virginiana  22.5
#>  7     7 scbi  unidentified unk      42.6
#>  8     8 scbi  lindera benzoin       51.4
#>  9     9 scbi  viburnum prunifolium  38.3
#> 10    10 scbi  asimina triloba       14.5
#> # ... with 40,273 more rows
```

``` r
eqn <- get_equations(dbh_species)
eqn
#> # A tibble: 5 x 2
#>   eqn_type       data                 
#>   <chr>          <list>               
#> 1 species        <tibble [8,930 x 8]> 
#> 2 genus          <tibble [5,642 x 8]> 
#> 3 mixed_hardwood <tibble [5,516 x 8]> 
#> 4 family         <tibble [10,141 x 8]>
#> 5 woody_species  <tibble [0 x 8]>
```

``` r
best <- pick_best_equations(eqn)
best
#> # A tibble: 30,229 x 8
#>    rowid site  sp           dbh equation_id eqn        eqn_source eqn_type
#>    <int> <chr> <chr>      <dbl> <chr>       <chr>      <chr>      <chr>   
#>  1     4 scbi  nyssa syl~ 135   8da09d      1.5416 * ~ default    species 
#>  2    21 scbi  liriodend~ 232.  34fe5a      1.0259 * ~ default    species 
#>  3    29 scbi  acer rubr~ 326.  7c72ed      exp(4.589~ default    species 
#>  4    38 scbi  fraxinus ~  42.8 0edaff      0.1634 * ~ default    species 
#>  5    72 scbi  acer rubr~ 289.  7c72ed      exp(4.589~ default    species 
#>  6    77 scbi  quercus a~ 636.  07dba7      1.5647 * ~ default    species 
#>  7    79 scbi  tilia ame~ 475   3f99ba      1.4416 * ~ default    species 
#>  8    79 scbi  tilia ame~ 475   76d19b      0.004884 ~ default    species 
#>  9    84 scbi  fraxinus ~ 170.  0edaff      0.1634 * ~ default    species 
#> 10    89 scbi  fagus gra~  27.2 74186d      2.0394 * ~ default    species 
#> # ... with 30,219 more rows
```

Deal with duplicated equations

``` r
find_duplicated_rowid(best)
#> # A tibble: 1,809 x 9
#>    rowid site  sp        dbh equation_id eqn     eqn_source eqn_type     n
#>    <int> <chr> <chr>   <dbl> <chr>       <chr>   <chr>      <chr>    <int>
#>  1   106 scbi  amelan~  13.8 c59e03      exp(7.~ default    genus        3
#>  2   106 scbi  amelan~  13.8 96c0af      10^(2.~ default    genus        3
#>  3   106 scbi  amelan~  13.8 529234      10^(2.~ default    genus        3
#>  4   125 scbi  amelan~  36.1 c59e03      exp(7.~ default    genus        3
#>  5   125 scbi  amelan~  36.1 96c0af      10^(2.~ default    genus        3
#>  6   125 scbi  amelan~  36.1 529234      10^(2.~ default    genus        3
#>  7   131 scbi  amelan~  79.1 c59e03      exp(7.~ default    genus        3
#>  8   131 scbi  amelan~  79.1 96c0af      10^(2.~ default    genus        3
#>  9   131 scbi  amelan~  79.1 529234      10^(2.~ default    genus        3
#> 10   132 scbi  amelan~  24   c59e03      exp(7.~ default    genus        3
#> # ... with 1,799 more rows
```

``` r
# NO duplicated rowid
eqn_1rowid <- pick_one_row_by_rowid(best)
eqn_1rowid
#> # A tibble: 29,203 x 8
#>    rowid site  sp           dbh equation_id eqn        eqn_source eqn_type
#>    <int> <chr> <chr>      <dbl> <chr>       <chr>      <chr>      <chr>   
#>  1     4 scbi  nyssa syl~ 135   8da09d      1.5416 * ~ default    species 
#>  2    21 scbi  liriodend~ 232.  34fe5a      1.0259 * ~ default    species 
#>  3    29 scbi  acer rubr~ 326.  7c72ed      exp(4.589~ default    species 
#>  4    38 scbi  fraxinus ~  42.8 0edaff      0.1634 * ~ default    species 
#>  5    72 scbi  acer rubr~ 289.  7c72ed      exp(4.589~ default    species 
#>  6    77 scbi  quercus a~ 636.  07dba7      1.5647 * ~ default    species 
#>  7    79 scbi  tilia ame~ 475   3f99ba      1.4416 * ~ default    species 
#>  8    84 scbi  fraxinus ~ 170.  0edaff      0.1634 * ~ default    species 
#>  9    89 scbi  fagus gra~  27.2 74186d      2.0394 * ~ default    species 
#> 10    95 scbi  quercus r~ 520.  839012      2.4601 * ~ default    species 
#> # ... with 29,193 more rows

find_duplicated_rowid(eqn_1rowid)
#> # A tibble: 0 x 9
#> # ... with 9 variables: rowid <int>, site <chr>, sp <chr>, dbh <dbl>,
#> #   equation_id <chr>, eqn <chr>, eqn_source <chr>, eqn_type <chr>,
#> #   n <int>
```

Now you may add the equations to the census data.

``` r
census_equations <- left_join(dbh_species, eqn_1rowid)
#> Joining, by = c("rowid", "site", "sp", "dbh")
census_equations
#> # A tibble: 40,283 x 8
#>    rowid site  sp          dbh equation_id eqn        eqn_source eqn_type 
#>    <int> <chr> <chr>     <dbl> <chr>       <chr>      <chr>      <chr>    
#>  1     1 scbi  lindera ~  27.9 f08fff      exp(-2.21~ default    family   
#>  2     2 scbi  lindera ~  23.7 f08fff      exp(-2.21~ default    family   
#>  3     3 scbi  lindera ~  22.2 f08fff      exp(-2.21~ default    family   
#>  4     4 scbi  nyssa sy~ 135   8da09d      1.5416 * ~ default    species  
#>  5     5 scbi  hamameli~  87   <NA>        <NA>       <NA>       <NA>     
#>  6     6 scbi  hamameli~  22.5 <NA>        <NA>       <NA>       <NA>     
#>  7     7 scbi  unidenti~  42.6 <NA>        <NA>       <NA>       <NA>     
#>  8     8 scbi  lindera ~  51.4 f08fff      exp(-2.21~ default    family   
#>  9     9 scbi  viburnum~  38.3 <NA>        <NA>       <NA>       <NA>     
#> 10    10 scbi  asimina ~  14.5 ae65ed      exp(-2.48~ default    mixed_ha~
#> # ... with 40,273 more rows
```

``` r
nrow(census_equations)
#> [1] 40283
# Same 
nrow(allodb::scbi_tree1)
#> [1] 40283
# Not the same 
nrow(eqn_1rowid)
#> [1] 29203
```

Finally you can evaluate the equations in the context of `dbh`.

``` r
biomass <- evaluate_equations(census_equations)
biomass
#> # A tibble: 40,283 x 9
#>    rowid site  sp       dbh equation_id eqn   eqn_source eqn_type  biomass
#>    <int> <chr> <chr>  <dbl> <chr>       <chr> <chr>      <chr>       <dbl>
#>  1     1 scbi  linde~  27.9 f08fff      exp(~ default    family    3.37e 2
#>  2     2 scbi  linde~  23.7 f08fff      exp(~ default    family    2.28e 2
#>  3     3 scbi  linde~  22.2 f08fff      exp(~ default    family    1.94e 2
#>  4     4 scbi  nyssa~ 135   8da09d      1.54~ default    species   1.10e12
#>  5     5 scbi  hamam~  87   <NA>        <NA>  <NA>       <NA>     NA      
#>  6     6 scbi  hamam~  22.5 <NA>        <NA>  <NA>       <NA>     NA      
#>  7     7 scbi  unide~  42.6 <NA>        <NA>  <NA>       <NA>     NA      
#>  8     8 scbi  linde~  51.4 f08fff      exp(~ default    family    1.47e 3
#>  9     9 scbi  vibur~  38.3 <NA>        <NA>  <NA>       <NA>     NA      
#> 10    10 scbi  asimi~  14.5 ae65ed      exp(~ default    mixed_h~  6.42e 1
#> # ... with 40,273 more rows
```

And you can summarize the result with **dplyr** or any other tool.

``` r
biomass %>% 
  group_by(sp) %>% 
  summarize(biomass = sum(biomass, na.rm = TRUE))
#> # A tibble: 73 x 2
#>    sp                         biomass
#>    <chr>                        <dbl>
#>  1 acer negundo              163405. 
#>  2 acer platanoides          300436. 
#>  3 acer rubrum          13080438140. 
#>  4 acer sp                        0  
#>  5 ailanthus altissima       299405. 
#>  6 amelanchier arborea    155633434. 
#>  7 asimina triloba          1151658. 
#>  8 berberis thunbergii           49.9
#>  9 carpinus caroliniana     6658184. 
#> 10 carya cordiformis       79257258. 
#> # ... with 63 more rows
```
