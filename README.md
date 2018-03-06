
<!-- README.md is generated from README.Rmd. Please edit that file -->

# allodb: Database of allometric equations <img src="https://i.imgur.com/39pvr4n.png" align="right" height=44 />

[![Travis build
status](https://travis-ci.org/forestgeo/allodb.svg?branch=master)](https://travis-ci.org/forestgeo/allodb)

The goal of allodb is to develop, host and give access to tables of
allometric equations for ForestGEO’s network.

## Installation

To install **allodb** run the following code in R (and the notes below):

    # install.packages("remotes")
    remotes::install_github("forestgeo/allodb", auth_token = "abc")

NOTES:

  - For details on how to install from private repositories see [this
    article](https://maurolepore.netlify.com/2017/12/06/2017-12-06-best-prectice-for-installing-packages-from-private-repos/).
  - For general advice on installing packages from GitHub see [this
    article](https://fgeo.netlify.com/2018/02/05/2018-02-05-installing-packages-from-github/).

# Example

``` r
library(allodb)
library(tibble)

equations
#> # A tibble: 419 x 14
#>    equation_id model_parameters biomass_units_original regression_model
#>    <chr>       <chr>            <chr>                  <chr>           
#>  1 <NA>        <NA>             lb                     linear_multiple 
#>  2 <NA>        <NA>             lb                     linear_multiple 
#>  3 <NA>        <NA>             kg                     <NA>            
#>  4 <NA>        <NA>             kg                     <NA>            
#>  5 <NA>        <NA>             kg                     <NA>            
#>  6 <NA>        <NA>             kg                     <NA>            
#>  7 <NA>        <NA>             g                      <NA>            
#>  8 <NA>        <NA>             kg                     <NA>            
#>  9 <NA>        <NA>             lb                     <NA>            
#> 10 <NA>        <NA>             lb                     <NA>            
#> # ... with 409 more rows, and 10 more variables:
#> #   other_equations_tested <chr>, `log (biomass)` <chr>, d <dbl>,
#> #   dbh_min_cm <chr>, dbh_max_cm <chr>, n_trees <int>,
#> #   dbh_units_original <chr>, equation <chr>, equation_grouping <chr>,
#> #   `bias correction _CF` <chr>
equations_metadata
#> # A tibble: 22 x 8
#>    Column Field  Description `Alphanumeric a~ `Variable codes` Units Range
#>    <chr>  <chr>  <chr>       <chr>            <chr>            <chr> <chr>
#>  1 1 / A  equat~ Unique equ~ -                -                -     -    
#>  2 2 / B  varia~ Tree compo~ character (stri~ -                -     -    
#>  3 3 / C  equat~ Model equa~ -                -                -     -    
#>  4 4 / D  allom~ Refers to ~ character (stri~ -                -     -    
#>  5 5 / E  devel~ Species fo~ <NA>             <NA>             <NA>  <NA> 
#>  6 6 / F  geogr~ Geographic~ character (stri~ -                -     -    
#>  7 7 / G  dbh_m~ Minimun DB~ numeric          -                <NA>  -    
#>  8 8 / H  dbh_m~ Maximun DB~ numeric          -                <NA>  -    
#>  9 9 / I  n_tre~ Number of ~ numeric          -                -     -    
#> 10 10 / J dbh_u~ DBH unit u~ <NA>             <NA>             <NA>  <NA> 
#> # ... with 12 more rows, and 1 more variable: `Erikas notes to delete
#> #   before publication` <chr>

missing_values_metadata
#> # A tibble: 12 x 7
#>    Code  Definition            Description         X4    X5    X6    X7   
#>    <chr> <chr>                 <chr>               <chr> <chr> <chr> <chr>
#>  1 <NA>  Not Applicable        Data does not appl~ <NA>  <NA>  <NA>  <NA> 
#>  2 NAC   Not Acquired          Information may be~ <NA>  <NA>  <NA>  <NA> 
#>  3 NRA   Not Readily Available Information was no~ <NA>  <NA>  <NA>  <NA> 
#>  4 NI    No Information        No information ava~ <NA>  <NA>  <NA>  <NA> 
#>  5 <NA>  <NA>                  <NA>                <NA>  <NA>  <NA>  <NA> 
#>  6 <NA>  <NA>                  <NA>                <NA>  <NA>  <NA>  <NA> 
#>  7 <NA>  <NA>                  <NA>                <NA>  <NA>  <NA>  <NA> 
#>  8 <NA>  <NA>                  <NA>                <NA>  <NA>  <NA>  <NA> 
#>  9 <NA>  <NA>                  <NA>                <NA>  <NA>  <NA>  <NA> 
#> 10 <NA>  <NA>                  <NA>                <NA>  <NA>  <NA>  <NA> 
#> 11 <NA>  <NA>                  <NA>                <NA>  <NA>  <NA>  <NA> 
#> 12 <NA>  <NA>                  <NA>                <NA>  <NA>  <NA>  <NA>

references_metadata
#> # A tibble: 6 x 8
#>   Column Field  Description  `Alphanumeric a~ `Variable codes` Units Range
#>   <chr>  <chr>  <chr>        <chr>            <chr>            <chr> <chr>
#> 1 1 / A  ref_id Unique refe~ numeric          -                -     -    
#> 2 2 / B  ref_a~ Last name o~ character (stri~ -                -     -    
#> 3 3 / C  ref_y~ Year of pub~ numeric          -                -     -    
#> 4 4 / D  ref_t~ Title of pu~ character (stri~ -                -     -    
#> 5 5 / E  ref_j~ Journal, bo~ character (stri~ -                -     -    
#> 6 6 / F  ref_d~ Publication~ character (stri~ -                -     -    
#> # ... with 1 more variable: `Notes to be deleted later` <chr>

sitespecies
#> # A tibble: 419 x 11
#>    site     family    species      species_code life_form model_parameters
#>    <chr>    <chr>     <chr>        <chr>        <chr>     <chr>           
#>  1 Lilly D~ Fabaceae  Robinia pse~ 901          Tree      <NA>            
#>  2 Lilly D~ Fabaceae  Robinia pse~ 901          Tree      <NA>            
#>  3 Lilly D~ Ulmaceae  Ulmus ameri~ 972          Tree      <NA>            
#>  4 Lilly D~ Ulmaceae  Ulmus rubra  975          Tree      <NA>            
#>  5 Lilly D~ Oleaceae  Fraxinus am~ 541          Tree      <NA>            
#>  6 Lilly D~ Oleaceae  Fraxinus pe~ 544          Tree      <NA>            
#>  7 Lilly D~ Hamameli~ Hamamelis v~ 498          Shrub     <NA>            
#>  8 Lilly D~ Cupressa~ Juniperus v~ 68           Tree      <NA>            
#>  9 Lilly D~ Fagaceae  Fagus grand~ 531          Tree      <NA>            
#> 10 Lilly D~ Fagaceae  Quercus alba 802          Tree      <NA>            
#> # ... with 409 more rows, and 5 more variables:
#> #   allometry_development_method <chr>, equation_id <chr>,
#> #   regression_model <chr>, wsg <chr>, wsg_id <chr>
sitespecies_metadata
#> # A tibble: 13 x 8
#>    Column Field  Description `Alphanumeric a~ `Variable codes` Units Range
#>    <chr>  <chr>  <chr>       <chr>            <chr>            <chr> <chr>
#>  1 1 / A  site   ForestGEO ~ character (stri~ -                -     -    
#>  2 2 / B  family Plant fami~ character (stri~ <NA>             <NA>  <NA> 
#>  3 3 / C  speci~ Plant spec~ character (stri~ -                -     -    
#>  4 4 / D  speci~ Species co~ <NA>             <NA>             <NA>  <NA> 
#>  5 5 / E  life_~ Common gro~ character (stri~ <NA>             <NA>  <NA> 
#>  6 6 / F  varia~ The biomas~ character (stri~ -                -     -    
#>  7 7 / G  equat~ "Allometri~ character (stri~ G- generic; E- ~ -     -    
#>  8 8 / H  equat~ Equation i~ numeric          -                <NA>  <NA> 
#>  9 9 / I  allom~ Refers to ~ character (stri~ -                <NA>  <NA> 
#> 10 10 / J dbh_m~ Min DBH at~ numeric          -                -     <NA> 
#> 11 11 / K dbh_m~ Max DBH at~ numeric          -                -     <NA> 
#> 12 12 / L wsg_id Wood densi~ numeric          <NA>             <NA>  <NA> 
#> 13 13 / L wsg_s~ Refers to ~ numeric          <NA>             <NA>  <NA> 
#> # ... with 1 more variable: `Erikas notes to delete before
#> #   publication` <chr>

wsg
#> # A tibble: 419 x 7
#>    wsg_id family         species    wsg   wsg_specificity variable   site 
#>    <chr>  <chr>          <chr>      <chr> <chr>           <chr>      <chr>
#>  1 <NA>   Fabaceae       Robinia p~ 0.6   species         Stem and ~ Lill~
#>  2 <NA>   Fabaceae       Robinia p~ 0.66  species         Stem and ~ Lill~
#>  3 <NA>   Ulmaceae       Ulmus ame~ 0.46  <NA>            Whole tre~ Lill~
#>  4 <NA>   Ulmaceae       Ulmus rub~ 0.48  <NA>            Whole tre~ Lill~
#>  5 <NA>   Oleaceae       Fraxinus ~ 0.51  <NA>            Whole tre~ Lill~
#>  6 <NA>   Oleaceae       Fraxinus ~ 0.53  <NA>            Whole tre~ Lill~
#>  7 <NA>   Hamamelidaceae Hamamelis~ 0.71  <NA>            Above gro~ Lill~
#>  8 <NA>   Cupressaceae   Juniperus~ 0.44  <NA>            Above gro~ Lill~
#>  9 <NA>   Fagaceae       Fagus gra~ 0.56  <NA>            Stem and ~ Lill~
#> 10 <NA>   Fagaceae       Quercus a~ 0.6   <NA>            Stem and ~ Lill~
#> # ... with 409 more rows
wsg_metadata
#> # A tibble: 9 x 8
#>   Column Field  Description  `Alphanumeric a~ `Variable codes` Units Range
#>   <chr>  <chr>  <chr>        <chr>            <chr>            <chr> <chr>
#> 1 1 / A  wsg_id Wood specif~ numeric          -                -     <NA> 
#> 2 2 / B  family Plant famil~ character (stri~ <NA>             <NA>  <NA> 
#> 3 3 / C  genus  Plant genus~ character (stri~ <NA>             <NA>  <NA> 
#> 4 4 / D  speci~ Plant speci~ character (stri~ <NA>             <NA>  <NA> 
#> 5 5 / E  wsg    Wood specif~ numeric          <NA>             g/cm3 -    
#> 6 6 / F  wsg_s~ Specific ta~ character (stri~ -                -     -    
#> 7 7 / G  n_sam~ Number of t~ numeric          <NA>             <NA>  <NA> 
#> 8 8 / H  site   ForestGEO s~ character (stri~ <NA>             <NA>  <NA> 
#> 9 9 / I  ref_id Unique refe~ numeric          <NA>             <NA>  <NA> 
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
