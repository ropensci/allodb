
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://i.imgur.com/39pvr4n.png" align="right" height=44 /> allodb: Database of allometric equations

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/forestgeo/allodb.svg?branch=master)](https://travis-ci.org/forestgeo/allodb)
[![Coverage
status](https://coveralls.io/repos/github/forestgeo/allodb/badge.svg)](https://coveralls.io/r/forestgeo/allodb?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/allodb)](https://cran.r-project.org/pkg=allodb)

**allodb** is a database of allometric equations focusing on ForestGEO
sites. To manipulate these equations and calculate biomass see
[fgeo.biomass](https://forestgeo.github.io/fgeo.biomass/).

## Warning

These features are not ready for research. Resulting biomass values are
still incorrect. Contact <gonzalezeb@si.edu> or <teixeirak@si.edu> for
updates.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("forestgeo/allodb")
```

For details in how to install packages from GitHub see [this
article](https://fgeo.netlify.com/2018/02/05/2018-02-05-installing-pkgs-from-github/).

## Example

``` r
library(allodb)

# Just for these examples
library(tibble)
library(purrr)
library(glue)
```

Combined data-base tables.

``` r
master()
#> Joining `equations` and `sitespecies` by 'equation_id'; then `sites_info` by 'site'.
#> # A tibble: 1,334 x 68
#>    ref_id equation_id equation_allome~ equation_form dependent_varia~
#>    <chr>  <chr>       <chr>            <chr>         <chr>           
#>  1 baske~ e2c7c7      exp(0.15+2.48*l~ exp(a+b*(log~ Total abovegrou~
#>  2 baske~ e2c7c7      exp(0.15+2.48*l~ exp(a+b*(log~ Total abovegrou~
#>  3 baske~ e2c7c7      exp(0.15+2.48*l~ exp(a+b*(log~ Total abovegrou~
#>  4 baske~ e2c7c7      exp(0.15+2.48*l~ exp(a+b*(log~ Total abovegrou~
#>  5 bohn_~ 307ec5      exp((1.185*(log~ exp((a*(dbh-~ Total abovegrou~
#>  6 bohn_~ 307ec5      exp((1.185*(log~ exp((a*(dbh-~ Total abovegrou~
#>  7 bohn_~ 307ec5      exp((1.185*(log~ exp((a*(dbh-~ Total abovegrou~
#>  8 bohn_~ 307ec5      exp((1.185*(log~ exp((a*(dbh-~ Total abovegrou~
#>  9 bohn_~ 307ec5      exp((1.185*(log~ exp((a*(dbh-~ Total abovegrou~
#> 10 bohn_~ 307ec5      exp((1.185*(log~ exp((a*(dbh-~ Total abovegrou~
#> # ... with 1,324 more rows, and 63 more variables:
#> #   independent_variable <chr>, equation_taxa <chr>,
#> #   allometry_specificity <chr>, equation_categ <chr>,
#> #   geographic_area <chr>, original_coord <chr>, lat.x <chr>,
#> #   long.x <chr>, coord_precision <chr>, elev_min <chr>, elev_max <chr>,
#> #   mat_C <chr>, map_mm <chr>, frost_free_period_days <chr>,
#> #   stand_age_range_yr <chr>, stand_age_history <chr>,
#> #   stand_basal_area_m2_ha <chr>, stand_trees_ha <chr>,
#> #   forest_description <chr>, ecosystem_type <chr>, vegetation_type <chr>,
#> #   dbh_min_cm <chr>, dbh_max_cm <chr>, sample_size <chr>,
#> #   collection_year <chr>, dbh_units_original <chr>, dbh_unit_CF <chr>,
#> #   output_units_original <chr>, output_units_CF <chr>,
#> #   allometry_development_method <chr>, regression_model <chr>,
#> #   r_squared <chr>, other_equations_tested <chr>, log_biomass <chr>,
#> #   bias_corrected <chr>, bias_correction_factor <chr>,
#> #   notes_fitting_model <chr>, original_equation_id <chr>,
#> #   original_data_availability <chr>, notes <chr>, site <chr>,
#> #   family <chr>, genus <chr>, latin_name <chr>, species_code <chr>,
#> #   life_form <chr>, equation_group <chr>, preceding_equation_id <chr>,
#> #   `TO DELETE` <chr>, warning <chr>, input_variable <chr>,
#> #   output_variable <chr>, id <chr>, Site <chr>, lat.y <chr>,
#> #   long.y <chr>, UTM_Zone <chr>, UTM_X <chr>, UTM_Y <chr>,
#> #   intertropical <chr>, size.ha <chr>, E <chr>, wsg.site.name <chr>
```

Conservatively, all columns of `master()` are character vectors.

``` r
all(map_lgl(master(), is.character))
#> Joining `equations` and `sitespecies` by 'equation_id'; then `sites_info` by 'site'.
#> [1] TRUE
```

This is to preserve different representations of missing values.

``` r
na_type <- glue("^{missing_values_metadata$Code}$") %>% glue_collapse("|")
na_type
#> ^NA$|^NAC$|^NRA$|^NI$

found <- map(master(), ~unique(grep(na_type, .x, value = TRUE)))
#> Joining `equations` and `sitespecies` by 'equation_id'; then `sites_info` by 'site'.
keep(found, ~length(.x) > 0)
#> $original_coord
#> [1] "NI"  "NRA"
#> 
#> $lat.x
#> [1] "NRA"
#> 
#> $long.x
#> [1] "NRA" "NI" 
#> 
#> $elev_min
#> [1] "NRA" "NI" 
#> 
#> $elev_max
#> [1] "NRA" "NI" 
#> 
#> $mat_C
#> [1] "NRA"
#> 
#> $map_mm
#> [1] "NRA"
#> 
#> $frost_free_period_days
#> [1] "NRA" "NI" 
#> 
#> $stand_age_range_yr
#> [1] "NRA" "NI" 
#> 
#> $stand_age_history
#> [1] "NRA" "NI" 
#> 
#> $stand_basal_area_m2_ha
#> [1] "NRA" "NI" 
#> 
#> $stand_trees_ha
#> [1] "NRA" "NI" 
#> 
#> $forest_description
#> [1] "NRA" "NI" 
#> 
#> $vegetation_type
#> [1] "NRA" "NI" 
#> 
#> $dbh_min_cm
#> [1] "NRA"
#> 
#> $dbh_max_cm
#> [1] "NRA"
#> 
#> $sample_size
#> [1] "NRA" "NI" 
#> 
#> $collection_year
#> [1] "NRA"
#> 
#> $r_squared
#> [1] "NI"
#> 
#> $other_equations_tested
#> [1] "NRA" "NI" 
#> 
#> $bias_correction_factor
#> [1] "NRA"
#> 
#> $notes_fitting_model
#> [1] "NI"
#> 
#> $original_equation_id
#> [1] "NI"
#> 
#> $original_data_availability
#> [1] "NRA" "NI"
```

For analysis, set the correct type of each column with `set_type()`.
Then not all columns will be character vectors.

``` r
converted <- set_type(master())
#> Joining `equations` and `sitespecies` by 'equation_id'; then `sites_info` by 'site'.
all(map_lgl(converted, is.character))
#> [1] FALSE
```

Notice that all types to missing values will be coerced to `NA`.

``` r
found <- map(converted, ~unique(grep(na_type, .x, value = TRUE)))
result <- keep(found, ~length(.x) > 0)

if (length(result) == 0)
  message(glue("No values match {na_type}"))
#> No values match ^NA$|^NAC$|^NRA$|^NI$
```

All datasets.

``` r
# Helper
datasets <- function(pkg) {
  dts <- sort(utils::data(package = pkg)$results[ , "Item"])
  set_names(map(dts, get), dts)
}

datasets("allodb")
#> $equations
#> # A tibble: 266 x 45
#>    ref_id equation_id equation_allome~ equation_form dependent_varia~
#>    <chr>  <chr>       <chr>            <chr>         <chr>           
#>  1 baske~ e2c7c7      exp(0.15+2.48*l~ exp(a+b*(log~ Total abovegrou~
#>  2 bohn_~ 307ec5      exp((1.185*(log~ exp((a*(dbh-~ Total abovegrou~
#>  3 bohn_~ 6a7382      exp((1.151*(log~ exp((a*(dbh-~ Total abovegrou~
#>  4 bohn_~ 786b7c      exp((1.266*(log~ exp((a*(dbh-~ Total abovegrou~
#>  5 bohn_~ 9e3b6a      exp((1.192*(log~ exp((a*(dbh-~ Total abovegrou~
#>  6 bohn_~ 9f138f      exp((1.202*(log~ exp((a*(dbh-~ Total abovegrou~
#>  7 bohn_~ e42e41      exp((1.091*(log~ exp((a*(dbh-~ Total abovegrou~
#>  8 bohn_~ e57b77      exp((1.029*(log~ exp((a*(dbh-~ Total abovegrou~
#>  9 bohn_~ f96447      dbh/((1/1.879)+~ dbh((1/a)+(d~ Height          
#> 10 bohn_~ 7a3dce      dbh/((1/1.919)+~ dbh((1/a)+(d~ Height          
#> # ... with 256 more rows, and 40 more variables:
#> #   independent_variable <chr>, equation_taxa <chr>,
#> #   allometry_specificity <chr>, equation_categ <chr>,
#> #   geographic_area <chr>, original_coord <chr>, lat <chr>, long <chr>,
#> #   coord_precision <chr>, elev_min <chr>, elev_max <chr>, mat_C <chr>,
#> #   map_mm <chr>, frost_free_period_days <chr>, stand_age_range_yr <chr>,
#> #   stand_age_history <chr>, stand_basal_area_m2_ha <chr>,
#> #   stand_trees_ha <chr>, forest_description <chr>, ecosystem_type <chr>,
#> #   vegetation_type <chr>, dbh_min_cm <chr>, dbh_max_cm <chr>,
#> #   sample_size <chr>, collection_year <chr>, dbh_units_original <chr>,
#> #   dbh_unit_CF <chr>, output_units_original <chr>, output_units_CF <chr>,
#> #   allometry_development_method <chr>, regression_model <chr>,
#> #   r_squared <chr>, other_equations_tested <chr>, log_biomass <chr>,
#> #   bias_corrected <chr>, bias_correction_factor <chr>,
#> #   notes_fitting_model <chr>, original_equation_id <chr>,
#> #   original_data_availability <chr>, notes <chr>
#> 
#> $equations_metadata
#> # A tibble: 45 x 8
#>    Column Field  Description    Column_type Field_codes   Units Range X8   
#>    <chr>  <chr>  <chr>          <chr>       <chr>         <chr> <chr> <chr>
#>  1 1 / A  ref_id Unique refere~ character   <NA>          <NA>  <NA>  <NA> 
#>  2 2 / B  equat~ Unique equati~ character   <NA>          <NA>  <NA>  <NA> 
#>  3 3 / C  equat~ Equation to c~ character   <NA>          <NA>  <NA>  <NA> 
#>  4 4 / D  equat~ Algebraic for~ character   <NA>          <NA>  <NA>  <NA> 
#>  5 5 / E  depen~ Tree componen~ character   <NA>          <NA>  <NA>  <NA> 
#>  6 6 / F  indep~ Parameters in~ character   <NA>          mm, ~ <NA>  <NA> 
#>  7 7 / G  equat~ Species, genu~ character ~ <NA>          <NA>  <NA>  <NA> 
#>  8 8 / H  allom~ Specific taxo~ character   <NA>          <NA>  <NA>  <NA> 
#>  9 9 / I  equat~ "Allometric e~ character   fa_spec; gen~ <NA>  <NA>  <NA> 
#> 10 10 / J geogr~ Broad geograp~ character   <NA>          <NA>  <NA>  <NA> 
#> # ... with 35 more rows
#> 
#> $missing_values_metadata
#> # A tibble: 4 x 3
#>   Code  Definition        Description                                      
#>   <chr> <chr>             <chr>                                            
#> 1 <NA>  Not Applicable    Data does not apply to that particular case      
#> 2 NAC   Not Acquired      Information may be available but has not been ac~
#> 3 NRA   Not Readily Avai~ Information was not readily available to the aut~
#> 4 NI    No Information    No information available in original publication 
#> 
#> $references_metadata
#> # A tibble: 7 x 4
#>   Column Field          Description                           Colum_type   
#>   <chr>  <chr>          <chr>                                 <chr>        
#> 1 1 / A  ref_id         Unique reference identification numb~ numeric      
#> 2 2 / B  ref_doi        Publication DOI (Digital object iden~ character (s~
#> 3 3 / C  ref_author     Last name of first author of a cited~ character (s~
#> 4 4 / D  ref_year       Year of publication                   numeric      
#> 5 5 / E  ref_title      Title of publication                  character (s~
#> 6 6 / F  ref_journal    Journal, book, report where published character (s~
#> 7 7 / G  References fu~ Full citation (kept for easy use)     character (s~
#> 
#> $sites_info
#> # A tibble: 68 x 12
#>    id    Site  site  lat   long  UTM_Zone UTM_X UTM_Y intertropical size.ha
#>    <chr> <chr> <chr> <chr> <chr> <chr>    <chr> <chr> <chr>         <chr>  
#>  1 42    Amac~ amac~ -3.81 -70.~ 19       3592~ 9578~ Tropical      25     
#>  2 51    Bada~ bada~ 29.46 110.~ 49       4534~ 3259~ Other         25     
#>  3 52    Baot~ baot~ 33.5  111.~ 49       5873~ 3706~ Other         25     
#>  4 45    Barr~ bci   9.15  -79.~ 17       6267~ 1012~ Tropical      50     
#>  5 18    Buki~ buki~ 1.35  103.~ 48       3642~ 1492~ Tropical      4      
#>  6 53    Chan~ chan~ 42.38 128.~ 52       4245~ 4692~ Other         25     
#>  7 46    Coco~ coco~ 8.99  -79.~ 17       6520~ 9937~ Tropical      4      
#>  8 14    Danu~ danu~ 5.1   117.~ 50       5762~ 5639~ Tropical      50     
#>  9 7     Ding~ ding~ 23.17 112.~ 49       6546~ 2563~ Tropical      20     
#> 10 25    Doi ~ doi ~ 18.58 98.43 47       4402~ 2054~ Tropical      15     
#> # ... with 58 more rows, and 2 more variables: E <chr>,
#> #   wsg.site.name <chr>
#> 
#> $sitespecies
#> # A tibble: 1,045 x 13
#>    site  family genus latin_name species_code life_form equation_group
#>    <chr> <chr>  <chr> <chr>      <chr>        <chr>     <chr>         
#>  1 lill~ Sapin~ Acer  Acer rubr~ 316          Tree      Expert        
#>  2 lill~ Sapin~ Acer  Acer rubr~ 316          Tree      Expert        
#>  3 lill~ Sapin~ Acer  Acer sacc~ 318          Tree      Expert        
#>  4 lill~ Rosac~ Amel~ Amelanchi~ 356          Tree      Expert        
#>  5 lill~ Rosac~ Amel~ Amelanchi~ 356          Tree      Expert        
#>  6 lill~ Rosac~ Amel~ Amelanchi~ 356          Tree      Expert        
#>  7 lill~ Annon~ Asim~ Asimina t~ 367          Tree      Generic       
#>  8 lill~ Betul~ Carp~ Carpinus ~ 391          Tree      Generic       
#>  9 lill~ Jugla~ Carya Carya alba 409          Tree      Expert        
#> 10 lill~ Jugla~ Carya Carya cor~ 402          Tree      Expert        
#> # ... with 1,035 more rows, and 6 more variables:
#> #   preceding_equation_id <chr>, equation_id <chr>, `TO DELETE` <chr>,
#> #   warning <chr>, input_variable <chr>, output_variable <chr>
#> 
#> $sitespecies_metadata
#> # A tibble: 15 x 8
#>    Column Field  Description    Column_type Field_codes Units Range X8     
#>    <chr>  <chr>  <chr>          <chr>       <chr>       <chr> <chr> <chr>  
#>  1 1 / A  site   ForestGEO sit~ character   <NA>        <NA>  <NA>  <NA>   
#>  2 2 / B  family Plant family ~ character   <NA>        <NA>  <NA>  <NA>   
#>  3 3 / C  genus  Genus name re~ <NA>        <NA>        <NA>  <NA>  <NA>   
#>  4 4 / D  speci~ Plant scienti~ character   <NA>        <NA>  <NA>  <NA>   
#>  5 5 / E  speci~ Species code ~ character   <NA>        <NA>  <NA>  <NA>   
#>  6 6 / F  life_~ Common growth~ character   <NA>        <NA>  <NA>  <NA>   
#>  7 7 / G  equat~ "Allometric e~ character   Generic; E~ <NA>  <NA>  <NA>   
#>  8 9 / I  prece~ Preceding equ~ character   <NA>        <NA>  <NA>  <NA>   
#>  9 10 / J equat~ Unique equati~ character   <NA>        <NA>  <NA>  <NA>   
#> 10 11 / K equat~ Taxa for whic~ character   <NA>        <NA>  <NA>  Revise~
#> 11 12 / L warni~ Informative n~ character   <NA>        <NA>  <NA>  <NA>   
#> 12 13 / M input~ Variable and ~ character   <NA>        <NA>  <NA>  Revise~
#> 13 14 / N outpu~ Final variabl~ character   <NA>        <NA>  <NA>  Revise~
#> 14 15 / O min_i~ Recommended m~ numeric     <NA>        <NA>  <NA>  Revise~
#> 15 16 / P max_i~ Recommended m~ numeric     <NA>        <NA>  <NA>  Revise~
#> 
#> $wsg
#> # A tibble: 549 x 8
#>    wsg_id family  species    wsg   wsg_specificity sample_size site  ref_id
#>    <chr>  <chr>   <chr>      <chr> <chr>           <chr>       <chr> <chr> 
#>  1 <NA>   Sapind~ Acer rubr~ 0.49  <NA>            <NA>        Lill~ <NA>  
#>  2 <NA>   Sapind~ Acer sacc~ 0.56  <NA>            <NA>        Lill~ <NA>  
#>  3 <NA>   Rosace~ Amelanchi~ 0.66  <NA>            <NA>        Lill~ <NA>  
#>  4 <NA>   Annona~ Asimina t~ 0.47  <NA>            <NA>        Lill~ <NA>  
#>  5 <NA>   Betula~ Carpinus ~ 0.58  <NA>            <NA>        Lill~ <NA>  
#>  6 <NA>   Juglan~ Carya alba 0.62  <NA>            10          Lill~ <NA>  
#>  7 <NA>   Juglan~ Carya cor~ 0.6   <NA>            10          Lill~ <NA>  
#>  8 <NA>   Juglan~ Carya gla~ 0.66  <NA>            10          Lill~ <NA>  
#>  9 <NA>   Juglan~ Carya ova~ 0.62  <NA>            <NA>        Lill~ <NA>  
#> 10 <NA>   Cannab~ Celtis oc~ 0.49  <NA>            <NA>        Lill~ <NA>  
#> # ... with 539 more rows
#> 
#> $wsg_metadata
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
```

## Information

  - [Getting help](SUPPORT.md).
  - [Contributing](CONTRIBUTING.md).
  - [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
