
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://i.imgur.com/VcNaTWW.png" align="right" height=44 /> allodb: Database of allometric equations

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

# Example

``` r
library(allodb)
library(tibble)

equations
#> # A tibble: 421 x 23
#>    equation_id dependent_varia~ equation allometry_speci~ development_spe~
#>    <chr>       <chr>            <chr>    <chr>            <chr>           
#>  1 <NA>        Stem and branch~ a*(DBH^~ Species          <NA>            
#>  2 <NA>        Stem and branch~ a*(DBH^~ Species          <NA>            
#>  3 <NA>        Whole tree (abo~ a+b*DBH~ Species          <NA>            
#>  4 <NA>        Whole tree (abo~ a+b*DBH~ Species          Ulmus americana 
#>  5 <NA>        Whole tree (abo~ a+b*DBH~ Species          <NA>            
#>  6 <NA>        Whole tree (abo~ a+b*DBH~ Species          Fraxinus americ~
#>  7 <NA>        Total abovegrou~ a*(DBA^~ Species          <NA>            
#>  8 <NA>        Total abovegrou~ a*(DBH^~ Species          <NA>            
#>  9 <NA>        Stem and branch~ a*(DBH^~ Species          <NA>            
#> 10 <NA>        Stem and branch~ a*(DBH^~ Species          <NA>            
#> # ... with 411 more rows, and 18 more variables: geographic_area <chr>,
#> #   dbh_min_cm <chr>, dbh_max_cm <chr>, n_trees <int>,
#> #   dbh_units_original <chr>, biomass_units_original <chr>,
#> #   allometry_development_method <chr>, independent_variable <chr>,
#> #   regression_model <chr>, other_equations_tested <chr>,
#> #   log_biomass <chr>, bias_corrected <chr>, bias_correction_factor <chr>,
#> #   notes_fitting_model <chr>, original_data_availability <chr>,
#> #   notes_to_consider <chr>, warning <chr>, ref_id <chr>
equations_metadata
#> # A tibble: 23 x 8
#>    Column Field    Description         Column_type Field_codes Units Range
#>    <chr>  <chr>    <chr>               <chr>       <chr>       <chr> <chr>
#>  1 1 / A  equatio~ Unique equation id~ -           -           -     -    
#>  2 2 / B  depende~ Tree component cha~ character   -           -     -    
#>  3 3 / C  equation Model equation as ~ character   -           -     -    
#>  4 4 / D  allomet~ Refers to the spec~ character   -           -     -    
#>  5 5 / E  develop~ Species for which ~ character   <NA>        <NA>  <NA> 
#>  6 6 / F  geograp~ Geographic locatio~ character   -           -     -    
#>  7 7 / G  dbh_min~ Minimun DBH in cm ~ numeric     -           <NA>  -    
#>  8 8 / H  dbh_max~ Maximun DBH in cm ~ numeric     -           <NA>  -    
#>  9 9 / I  n_trees  Number of trees sa~ integer     -           -     -    
#> 10 10 / J dbh_uni~ DBH unit used in o~ character   <NA>        <NA>  <NA> 
#> # ... with 13 more rows, and 1 more variable: `Erikas notes to delete
#> #   before publication` <chr>

missing_values_metadata
#> # A tibble: 4 x 3
#>   Code  Definition            Description                                 
#>   <chr> <chr>                 <chr>                                       
#> 1 <NA>  Not Applicable        Data does not apply to that particular case 
#> 2 NAC   Not Acquired          Information may be available but has not be~
#> 3 NRA   Not Readily Available Information was not readily available to th~
#> 4 NI    No Information        No information available in original public~

references_metadata
#> # A tibble: 6 x 5
#>   Column Field       Description            Colum_type  `Notes to be dele~
#>   <chr>  <chr>       <chr>                  <chr>       <chr>             
#> 1 1 / A  ref_id      Unique reference iden~ numeric     <NA>              
#> 2 2 / B  ref_author  Last name of first au~ character ~ <NA>              
#> 3 3 / C  ref_year    Year of publication    numeric     <NA>              
#> 4 4 / D  ref_title   Title of publication   character ~ <NA>              
#> 5 5 / E  ref_journal Journal, book, report~ character ~ EG: Keep this for~
#> 6 6 / F  ref_doi     Publication DOI (Digi~ character ~ <NA>

sitespecies
#> # A tibble: 421 x 13
#>    site    family   species    species_code life_form dependent_variable_~
#>    <chr>   <chr>    <chr>      <chr>        <chr>     <chr>               
#>  1 Lilly ~ Fabaceae Robinia p~ 901          Tree      Stem and branches (~
#>  2 Lilly ~ Fabaceae Robinia p~ 901          Tree      Stem and branches (~
#>  3 Lilly ~ Ulmaceae Ulmus ame~ 972          Tree      Whole tree (above s~
#>  4 Lilly ~ Ulmaceae Ulmus rub~ 975          Tree      Whole tree (above s~
#>  5 Lilly ~ Oleaceae Fraxinus ~ 541          Tree      Whole tree (above s~
#>  6 Lilly ~ Oleaceae Fraxinus ~ 544          Tree      Whole tree (above s~
#>  7 Lilly ~ Hamamel~ Hamamelis~ 498          Shrub     Total aboveground b~
#>  8 Lilly ~ Cupress~ Juniperus~ 68           Tree      Total aboveground b~
#>  9 Lilly ~ Fagaceae Fagus gra~ 531          Tree      Stem and branches (~
#> 10 Lilly ~ Fagaceae Quercus a~ 802          Tree      Stem and branches (~
#> # ... with 411 more rows, and 7 more variables: equation_grouping <chr>,
#> #   equation_id <chr>, allometry_specificity <chr>, dbh_min_cm <chr>,
#> #   dbh_max_cm <chr>, wsg_id <chr>, wsg_specificity <chr>
sitespecies_metadata
#> # A tibble: 13 x 8
#>    Column Field  Description           Column_type Field_codes Units Range
#>    <chr>  <chr>  <chr>                 <chr>       <chr>       <chr> <chr>
#>  1 1 / A  site   ForestGEO site name ~ character   -           -     -    
#>  2 2 / B  family Plant family name as~ character   <NA>        <NA>  <NA> 
#>  3 3 / C  speci~ Plant species name a~ character   -           -     -    
#>  4 4 / D  speci~ Species code used at~ character   <NA>        <NA>  <NA> 
#>  5 5 / E  life_~ Common growth form f~ character   <NA>        <NA>  <NA> 
#>  6 6 / F  bioma~ The biomass variable~ character   -           -     -    
#>  7 7 / G  equat~ "Allometric equation~ character   G- generic~ -     -    
#>  8 8 / H  equat~ Equation identificat~ numeric     -           <NA>  <NA> 
#>  9 9 / I  allom~ Refers to the specif~ character ~ -           <NA>  <NA> 
#> 10 10 / J dbh_m~ Min DBH at which the~ numeric     -           -     <NA> 
#> 11 11 / K dbh_m~ Max DBH at which the~ numeric     -           -     <NA> 
#> 12 12 / L wsg_id Wood density identif~ numeric     <NA>        <NA>  <NA> 
#> 13 13 / L wsg_s~ Refers to the specif~ character   <NA>        <NA>  <NA> 
#> # ... with 1 more variable: `Erikas notes to delete before
#> #   publication` <chr>

wsg
#> # A tibble: 421 x 8
#>    wsg_id family   species     wsg   wsg_specificity n_trees site   ref_id
#>    <chr>  <chr>    <chr>       <chr> <chr>             <int> <chr>  <chr> 
#>  1 <NA>   Fabaceae Robinia ps~ 0.6   species               9 Lilly~ <NA>  
#>  2 <NA>   Fabaceae Robinia ps~ 0.66  species               9 Lilly~ <NA>  
#>  3 <NA>   Ulmaceae Ulmus amer~ 0.46  <NA>                 NA Lilly~ <NA>  
#>  4 <NA>   Ulmaceae Ulmus rubra 0.48  <NA>                 NA Lilly~ <NA>  
#>  5 <NA>   Oleaceae Fraxinus a~ 0.51  <NA>                 NA Lilly~ <NA>  
#>  6 <NA>   Oleaceae Fraxinus p~ 0.53  <NA>                 NA Lilly~ <NA>  
#>  7 <NA>   Hamamel~ Hamamelis ~ 0.71  <NA>                 NA Lilly~ <NA>  
#>  8 <NA>   Cupress~ Juniperus ~ 0.44  <NA>                 NA Lilly~ <NA>  
#>  9 <NA>   Fagaceae Fagus gran~ 0.56  <NA>                 NA Lilly~ <NA>  
#> 10 <NA>   Fagaceae Quercus al~ 0.6   <NA>                 NA Lilly~ <NA>  
#> # ... with 411 more rows
wsg_metadata
#> # A tibble: 9 x 8
#>   Column Field  Description            Column_type Field_codes Units Range
#>   <chr>  <chr>  <chr>                  <chr>       <chr>       <chr> <chr>
#> 1 1 / A  wsg_id Wood specific gravity~ numeric     -           -     <NA> 
#> 2 2 / B  family Plant family name as ~ character   <NA>        <NA>  <NA> 
#> 3 3 / C  genus  Plant genus name as T~ character   <NA>        <NA>  <NA> 
#> 4 4 / D  speci~ Plant species name as~ character   <NA>        <NA>  <NA> 
#> 5 5 / E  wsg    Wood specific gravity  numeric     <NA>        g/cm3 -    
#> 6 6 / F  wsg_s~ Specific taxonomic le~ character   -           -     -    
#> 7 7 / G  n_tre~ Number of trees sampl~ numeric     <NA>        <NA>  <NA> 
#> 8 8 / H  site   ForestGEO site name    character   <NA>        <NA>  <NA> 
#> 9 9 / I  ref_id Unique reference iden~ numeric     <NA>        <NA>  <NA> 
#> # ... with 1 more variable: `Erikas notes to delete before
#> #   publication` <chr>

sites_info
#> # A tibble: 63 x 12
#>       id Site    site       lat   long UTM_Zone UTM_X  UTM_Y intertropical
#>    <dbl> <chr>   <chr>    <dbl>  <dbl>    <int> <chr>  <chr> <chr>        
#>  1   42. Amacay~ amacay~  -3.81  -70.3       19 35922~ 9578~ Tropical     
#>  2   51. Badago~ badago~  29.5   111.        49 45345~ 3259~ Other        
#>  3   52. Baotia~ baotia~  33.5   112.        49 58732~ 3706~ Other        
#>  4   45. Barro ~ barro ~   9.15  -79.8       17 62678~ 1012~ Tropical     
#>  5   18. Bukit ~ bukit ~   1.35  104.        48 36427~ 1492~ Tropical     
#>  6   53. Changb~ changb~  42.4   128.        52 42451~ 4692~ Other        
#>  7   46. Cocoli  cocoli    8.99  -79.6       17 65207~ 9937~ Tropical     
#>  8   14. Danum ~ danum ~   5.10  118.        50 57625~ 5639~ Tropical     
#>  9    7. Dinghu~ dinghu~  23.2   113.        49 65466~ 2563~ Tropical     
#> 10   25. Doi In~ doi in~  18.6    98.4       47 440211 2054~ Tropical     
#> # ... with 53 more rows, and 3 more variables: size.ha <dbl>, E <dbl>,
#> #   wsg.site.name <chr>
```

-----

Please note that this project is released with a [Contributor Code of
Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project
you agree to abide by its terms.
