
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
library(dplyr)
library(allodb)
```

### Workflow

This workflow is had-hoc and incomplete. For now it is tested only for
equaitons at the species-level.

``` r
census <- scbi_tree1
# Some equaitons are dropped via allodb:::drop_bad_equations()
eqn <- pick_equations(scbi_species, "species")
census_eqn <- add_equation(census, eqn)
#> Joining, by = "sp"

# Using head() to compute only on a few rows -- for speed
result <- add_biomass(head(census_eqn))

# Relevant columns
select(
  result, 
  equation_allometry, dbh, biomass
)
#> # A tibble: 6 x 3
#>   equation_allometry                  dbh biomass
#>   <chr>                             <dbl>   <dbl>
#> 1 10^(1.1468+2.363*(log10(dbh^2)))   135  1.64e11
#> 2 10^(1.1468+2.363*(log10(dbh^2)))   135  1.64e11
#> 3 1.5416*(dbh^2)^2.7818              135  1.10e12
#> 4 2.56795*(dbh^2)^1.18685            135  2.93e 5
#> 5 2.56795*(dbh^2)^1.18685            135  2.93e 5
#> 6 10^(0.8306+2.7308*(log10(dbh^2)))  232. 5.65e13
```

Same

``` r
census %>% 
  add_equation(eqn) %>% 
  head() %>% 
  add_biomass() %>% 
  select(equation_allometry, dbh, biomass)
#> Joining, by = "sp"
#> # A tibble: 6 x 3
#>   equation_allometry                  dbh biomass
#>   <chr>                             <dbl>   <dbl>
#> 1 10^(1.1468+2.363*(log10(dbh^2)))   135  1.64e11
#> 2 10^(1.1468+2.363*(log10(dbh^2)))   135  1.64e11
#> 3 1.5416*(dbh^2)^2.7818              135  1.10e12
#> 4 2.56795*(dbh^2)^1.18685            135  2.93e 5
#> 5 2.56795*(dbh^2)^1.18685            135  2.93e 5
#> 6 10^(0.8306+2.7308*(log10(dbh^2)))  232. 5.65e13
```

### Tables

``` r
equations
#> # A tibble: 175 x 22
#>    ref_id equation_allome~ equation_id equation_form dependent_varia~
#>    <chr>  <chr>            <chr>       <chr>         <chr>           
#>  1 jenki~ 10^(1.1891+1.41~ 2060ea      10^(a+b*(log~ Total abovegrou~
#>  2 jenki~ 10^(1.2315+1.63~ a4d879      10^(a+b*(log~ Total abovegrou~
#>  3 jenki~ exp(7.217+1.514~ c59e03      exp(a+b*ln(D~ Stem biomass (w~
#>  4 jenki~ 10^(2.5368+1.31~ 96c0af      10^(a+b*(log~ Branches (live,~
#>  5 jenki~ 10^(2.0865+0.94~ 529234      10^(a+b*(log~ Foliage total   
#>  6 jenki~ exp(-2.48+2.483~ ae65ed      exp(a+b*ln(D~ Total abovegrou~
#>  7 marti~ 10^(-1.326+2.76~ 9c4cc9      10^(a+b*(log~ Total abovegrou~
#>  8 jenki~ 2.034*(dbh^2.63~ 7913b8      a*(DBH^b)     Stem and branch~
#>  9 chojn~ exp(-2.5095+2.5~ 7f7777      exp(a+b*ln(D~ Total abovegrou~
#> 10 jenki~ exp(5.67+1.97*d~ cf733d      exp(a+b*DBH+~ Total abovegrou~
#> # ... with 165 more rows, and 17 more variables:
#> #   independent_variable <chr>, allometry_specificity <chr>,
#> #   geographic_area <chr>, dbh_min_cm <chr>, dbh_max_cm <chr>,
#> #   sample_size <chr>, dbh_units_original <chr>,
#> #   biomass_units_original <chr>, allometry_development_method <chr>,
#> #   regression_model <chr>, other_equations_tested <chr>,
#> #   log_biomass <chr>, bias_corrected <chr>, bias_correction_factor <chr>,
#> #   notes_fitting_model <chr>, original_data_availability <chr>,
#> #   warning <chr>
equations_metadata
#> # A tibble: 22 x 7
#>    Column Field     Description        Column_type Field_codes Units Range
#>    <chr>  <chr>     <chr>              <chr>       <chr>       <chr> <chr>
#>  1 1 / A  equation~ Unique equation i~ <NA>        <NA>        <NA>  <NA> 
#>  2 2 / B  equation~ Algebraic form of~ character   <NA>        <NA>  <NA> 
#>  3 3 / C  equation~ Equation to calcu~ character   <NA>        <NA>  <NA> 
#>  4 4 / D  dependen~ Tree component ch~ character   <NA>        <NA>  <NA> 
#>  5 5 / E  independ~ Parameters includ~ character   <NA>        <NA>  <NA> 
#>  6 6 / F  allometr~ Specific taxonomi~ character   <NA>        <NA>  <NA> 
#>  7 7 / G  geograph~ Geographic locati~ character   <NA>        <NA>  <NA> 
#>  8 8 / H  dbh_min_~ Minimun DBH in cm~ numeric     <NA>        <NA>  <NA> 
#>  9 9 / I  dbh_max_~ Maximun DBH in cm~ numeric     <NA>        <NA>  <NA> 
#> 10 10 / J sample_s~ Number of trees s~ integer     <NA>        <NA>  <NA> 
#> # ... with 12 more rows

missing_values_metadata
#> # A tibble: 4 x 3
#>   Code  Definition        Description                                     
#>   <chr> <chr>             <chr>                                           
#> 1 <NA>  Not Applicable    Data does not apply to that particular case     
#> 2 NAC   Not Acquired      Information may be available but has not been a~
#> 3 NRA   Not Readily Avai~ Information was not readily available to the au~
#> 4 NI    No Information    No information available in original publication

references_metadata
#> # A tibble: 7 x 4
#>   Column Field         Description                           Colum_type   
#>   <chr>  <chr>         <chr>                                 <chr>        
#> 1 1 / A  ref_id        Unique reference identification numb~ numeric      
#> 2 2 / B  ref_doi       Publication DOI (Digital object iden~ character (s~
#> 3 3 / C  ref_author    Last name of first author of a cited~ character (s~
#> 4 4 / D  ref_year      Year of publication                   numeric      
#> 5 5 / E  ref_title     Title of publication                  character (s~
#> 6 6 / F  ref_journal   Journal, book, report where published character (s~
#> 7 7 / G  References f~ Full citation (kept for easy use)     character (s~

sitespecies
#> # A tibble: 679 x 34
#>    site  family species species_code life_form dependent_varia~
#>    <chr> <chr>  <chr>   <chr>        <chr>     <chr>           
#>  1 Lill~ Sapin~ Acer r~ 316          Tree      Total abovegrou~
#>  2 Lill~ Sapin~ Acer s~ 318          Tree      Total abovegrou~
#>  3 Lill~ Rosac~ Amelan~ 356          Tree      Stem biomass (w~
#>  4 Lill~ Rosac~ Amelan~ 356          Tree      Branches (live,~
#>  5 Lill~ Rosac~ Amelan~ 356          Tree      Foliage total   
#>  6 Lill~ Annon~ Asimin~ 367          Tree      Total abovegrou~
#>  7 Lill~ Betul~ Carpin~ 391          Tree      Total abovegrou~
#>  8 Lill~ Jugla~ Carya ~ 409          Tree      Total abovegrou~
#>  9 Lill~ Jugla~ Carya ~ 402          Tree      Total abovegrou~
#> 10 Lill~ Jugla~ Carya ~ 403          Tree      Total abovegrou~
#> # ... with 669 more rows, and 28 more variables: equation_group <chr>,
#> #   equation_id <chr>, equation_taxa <chr>, allometry_specificity <chr>,
#> #   dbh_min_cm <chr>, dbh_max_cm <chr>, notes_on_species <chr>,
#> #   wsg_id <chr>, wsg_specificity <chr>, X16 <chr>, X17 <chr>, X18 <chr>,
#> #   X19 <chr>, X20 <chr>, X21 <chr>, X22 <chr>, X23 <chr>, X24 <chr>,
#> #   X25 <chr>, X26 <chr>, X27 <chr>, X28 <chr>, X29 <chr>, X30 <chr>,
#> #   X31 <chr>, X32 <chr>, X33 <chr>, X34 <chr>
sitespecies_metadata
#> # A tibble: 15 x 8
#>    Column Field Description Column_type Field_codes Units Range
#>    <chr>  <chr> <chr>       <chr>       <chr>       <chr> <chr>
#>  1 1 / A  site  ForestGEO ~ character   -           -     -    
#>  2 2 / B  fami~ Plant fami~ character   <NA>        <NA>  <NA> 
#>  3 3 / C  spec~ Plant scie~ character   -           -     -    
#>  4 4 / D  spec~ Species co~ character   <NA>        <NA>  <NA> 
#>  5 5 / E  life~ Common gro~ character   <NA>        <NA>  <NA> 
#>  6 6 / F  depe~ Tree compo~ character   -           -     -    
#>  7 7 / G  equa~ "Allometri~ character   G- generic~ -     -    
#>  8 8 / H  equa~ Unique equ~ numeric     -           <NA>  <NA> 
#>  9 9 / I  equa~ Species, g~ character ~ <NA>        <NA>  <NA> 
#> 10 10 / J allo~ Refers to ~ character ~ -           <NA>  <NA> 
#> 11 11 / K dbh_~ Min DBH at~ numeric     -           -     <NA> 
#> 12 12 / L dbh_~ Max DBH at~ numeric     -           -     <NA> 
#> 13 13 / M note~ Informativ~ character   <NA>        <NA>  <NA> 
#> 14 14 / N wsg_~ Wood densi~ numeric     <NA>        <NA>  <NA> 
#> 15 15 / O wsg_~ Refers to ~ character   <NA>        <NA>  <NA> 
#> # ... with 1 more variable: `Erikas notes to delete before
#> #   publication` <chr>

wsg
#> # A tibble: 549 x 8
#>    wsg_id family  species   wsg   wsg_specificity sample_size site  ref_id
#>    <chr>  <chr>   <chr>     <chr> <chr>           <chr>       <chr> <chr> 
#>  1 <NA>   Sapind~ Acer rub~ 0.49  <NA>            <NA>        Lill~ <NA>  
#>  2 <NA>   Sapind~ Acer sac~ 0.56  <NA>            <NA>        Lill~ <NA>  
#>  3 <NA>   Rosace~ Amelanch~ 0.66  <NA>            <NA>        Lill~ <NA>  
#>  4 <NA>   Annona~ Asimina ~ 0.47  <NA>            <NA>        Lill~ <NA>  
#>  5 <NA>   Betula~ Carpinus~ 0.58  <NA>            <NA>        Lill~ <NA>  
#>  6 <NA>   Juglan~ Carya al~ 0.62  <NA>            10          Lill~ <NA>  
#>  7 <NA>   Juglan~ Carya co~ 0.6   <NA>            10          Lill~ <NA>  
#>  8 <NA>   Juglan~ Carya gl~ 0.66  <NA>            10          Lill~ <NA>  
#>  9 <NA>   Juglan~ Carya ov~ 0.62  <NA>            <NA>        Lill~ <NA>  
#> 10 <NA>   Cannab~ Celtis o~ 0.49  <NA>            <NA>        Lill~ <NA>  
#> # ... with 539 more rows
wsg_metadata
#> # A tibble: 9 x 8
#>   Column Field Description Column_type Field_codes Units Range
#>   <chr>  <chr> <chr>       <chr>       <chr>       <chr> <chr>
#> 1 1 / A  wsg_~ Wood speci~ numeric     -           -     <NA> 
#> 2 2 / B  fami~ Plant fami~ character   <NA>        <NA>  <NA> 
#> 3 3 / C  genus Plant genu~ character   <NA>        <NA>  <NA> 
#> 4 4 / D  spec~ Plant spec~ character   <NA>        <NA>  <NA> 
#> 5 5 / E  wsg   Wood speci~ numeric     <NA>        g/cm3 -    
#> 6 6 / F  wsg_~ Specific t~ character   -           -     -    
#> 7 7 / G  samp~ Number of ~ numeric     <NA>        <NA>  <NA> 
#> 8 8 / H  site  ForestGEO ~ character   <NA>        <NA>  <NA> 
#> 9 9 / I  ref_~ Unique ref~ numeric     <NA>        <NA>  <NA> 
#> # ... with 1 more variable: `Erikas notes to delete before
#> #   publication` <chr>

sites_info
#> # A tibble: 63 x 12
#>    id    Site  site  lat   long  UTM_Zone UTM_X UTM_Y intertropical size.ha
#>    <chr> <chr> <chr> <chr> <chr> <chr>    <chr> <chr> <chr>         <chr>  
#>  1 42    Amac~ amac~ -3.81 -70.~ 19       3592~ 9578~ Tropical      25     
#>  2 51    Bada~ bada~ 29.46 110.~ 49       4534~ 3259~ Other         25     
#>  3 52    Baot~ baot~ 33.5  111.~ 49       5873~ 3706~ Other         25     
#>  4 45    Barr~ barr~ 9.15  -79.~ 17       6267~ 1012~ Tropical      50     
#>  5 18    Buki~ buki~ 1.35  103.~ 48       3642~ 1492~ Tropical      4      
#>  6 53    Chan~ chan~ 42.38 128.~ 52       4245~ 4692~ Other         25     
#>  7 46    Coco~ coco~ 8.99  -79.~ 17       6520~ 9937~ Tropical      4      
#>  8 14    Danu~ danu~ 5.1   117.~ 50       5762~ 5639~ Tropical      50     
#>  9 7     Ding~ ding~ 23.17 112.~ 49       6546~ 2563~ Tropical      20     
#> 10 25    Doi ~ doi ~ 18.58 98.43 47       4402~ 2054~ Tropical      15     
#> # ... with 53 more rows, and 2 more variables: E <chr>,
#> #   wsg.site.name <chr>
```

## Code of conduct

Please note that this project is released with a [Contributor Code of
Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project
you agree to abide by its terms.
