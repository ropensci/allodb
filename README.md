
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
library(purrr)
library(bmss)
library(allodb)
```

### Workflow reusing code from the **bmss** package

This workflow is ad-hoc and incomplete.

  - For `allometry_specificity == "Species"`

<!-- end list -->

``` r
# Restructure equations table and pick species-specific equations
default_eqn <- master() %>% 
  filter(allometry_specificity == "Species") %>% 
  bmss_default_eqn()

# Restructure census to translate species codes to latin names
dbh_sp <- bmss_cns(scbi_tree1, scbi_species, site = "scbi")

# Evauate each equation with its corresponding dbh value
bmss(dbh_sp, default_eqn)
#> You gave no custom equations.
#>   * Using default equations.
#> # A tibble: 8,930 x 7
#>    site  sp               dbh eqn              eqn_source eqn_type biomass
#>    <chr> <chr>          <dbl> <chr>            <chr>      <chr>      <dbl>
#>  1 scbi  nyssa sylvati~ 135   1.5416 * (dbh^2~ default    species  1.10e12
#>  2 scbi  liriodendron ~ 232.  1.0259 * (dbh^2~ default    species  2.99e 6
#>  3 scbi  acer rubrum    326.  exp(4.5893 + 2.~ default    species  1.26e 8
#>  4 scbi  fraxinus nigra  42.8 0.1634 * (dbh^2~ default    species  1.11e 3
#>  5 scbi  acer rubrum    289.  exp(4.5893 + 2.~ default    species  9.38e 7
#>  6 scbi  quercus alba   636.  1.5647 * (dbh^2~ default    species  5.41e 7
#>  7 scbi  tilia america~ 475   1.4416 * (dbh^2~ default    species  2.97e 7
#>  8 scbi  tilia america~ 475   0.004884 * (dbh~ default    species  1.97e 3
#>  9 scbi  fraxinus nigra 170.  0.1634 * (dbh^2~ default    species  2.81e 4
#> 10 scbi  fagus grandif~  27.2 2.0394 * (dbh^2~ default    species  9.97e 3
#> # ... with 8,920 more rows
```

  - For each category of `allometry_specificity` (`bmss()` could be
    vectorized to do this automatically – given a vector of values to
    match in `allometry_specificity`).

<!-- end list -->

``` r
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
#> $Species
#> # A tibble: 8,930 x 7
#>    site  sp               dbh eqn              eqn_source eqn_type biomass
#>    <chr> <chr>          <dbl> <chr>            <chr>      <chr>      <dbl>
#>  1 scbi  nyssa sylvati~ 135   1.5416 * (dbh^2~ default    species  1.10e12
#>  2 scbi  liriodendron ~ 232.  1.0259 * (dbh^2~ default    species  2.99e 6
#>  3 scbi  acer rubrum    326.  exp(4.5893 + 2.~ default    species  1.26e 8
#>  4 scbi  fraxinus nigra  42.8 0.1634 * (dbh^2~ default    species  1.11e 3
#>  5 scbi  acer rubrum    289.  exp(4.5893 + 2.~ default    species  9.38e 7
#>  6 scbi  quercus alba   636.  1.5647 * (dbh^2~ default    species  5.41e 7
#>  7 scbi  tilia america~ 475   1.4416 * (dbh^2~ default    species  2.97e 7
#>  8 scbi  tilia america~ 475   0.004884 * (dbh~ default    species  1.97e 3
#>  9 scbi  fraxinus nigra 170.  0.1634 * (dbh^2~ default    species  2.81e 4
#> 10 scbi  fagus grandif~  27.2 2.0394 * (dbh^2~ default    species  9.97e 3
#> # ... with 8,920 more rows
#> 
#> $Genus
#> # A tibble: 5,642 x 7
#>    site  sp             dbh eqn                eqn_source eqn_type biomass
#>    <chr> <chr>        <dbl> <chr>              <chr>      <chr>      <dbl>
#>  1 scbi  amelanchier~  13.8 exp(7.217 + 1.514~ default    genus     7.25e4
#>  2 scbi  amelanchier~  13.8 10^(2.5368 + 1.31~ default    genus     1.10e4
#>  3 scbi  amelanchier~  13.8 10^(2.0865 + 0.94~ default    genus     1.46e3
#>  4 scbi  carya glabra  25.8 10^(-1.326 + 2.76~ default    genus     3.74e2
#>  5 scbi  carya cordi~ 453.  10^(-1.326 + 2.76~ default    genus     1.02e6
#>  6 scbi  ulmus rubra   21   2.04282 * (dbh^2)~ default    genus     4.25e3
#>  7 scbi  amelanchier~  36.1 exp(7.217 + 1.514~ default    genus     3.11e5
#>  8 scbi  amelanchier~  36.1 10^(2.5368 + 1.31~ default    genus     3.91e4
#>  9 scbi  amelanchier~  36.1 10^(2.0865 + 0.94~ default    genus     3.62e3
#> 10 scbi  carya tomen~ 368.  10^(-1.326 + 2.76~ default    genus     5.79e5
#> # ... with 5,632 more rows
#> 
#> $`Mixed hardwood`
#> # A tibble: 5,516 x 7
#>    site  sp             dbh eqn              eqn_source eqn_type   biomass
#>    <chr> <chr>        <dbl> <chr>            <chr>      <chr>        <dbl>
#>  1 scbi  asimina tri~  14.5 exp(-2.48 + 2.4~ default    mixed har~    64.2
#>  2 scbi  asimina tri~  11.8 exp(-2.48 + 2.4~ default    mixed har~    38.5
#>  3 scbi  asimina tri~  17.7 exp(-2.48 + 2.4~ default    mixed har~   105. 
#>  4 scbi  sambucus ca~  18   exp(-2.48 + 2.4~ default    mixed har~   110. 
#>  5 scbi  sambucus ca~  15.4 exp(-2.48 + 2.4~ default    mixed har~    74.5
#>  6 scbi  carpinus ca~ 110.  exp(-2.48 + 2.4~ default    mixed har~  9768. 
#>  7 scbi  berberis th~  13.1 exp(-2.48 + 2.4~ default    mixed har~    49.9
#>  8 scbi  carpinus ca~  45.6 exp(-2.48 + 2.4~ default    mixed har~  1104. 
#>  9 scbi  carpinus ca~ 102.  exp(-2.48 + 2.4~ default    mixed har~  8074. 
#> 10 scbi  sambucus ca~  10.7 exp(-2.48 + 2.4~ default    mixed har~    30.2
#> # ... with 5,506 more rows
#> 
#> $Family
#> # A tibble: 10,141 x 7
#>    site  sp            dbh eqn                 eqn_source eqn_type biomass
#>    <chr> <chr>       <dbl> <chr>               <chr>      <chr>      <dbl>
#>  1 scbi  lindera be~  27.9 exp(-2.2118 + 2.41~ default    family     337. 
#>  2 scbi  lindera be~  23.7 exp(-2.2118 + 2.41~ default    family     228. 
#>  3 scbi  lindera be~  22.2 exp(-2.2118 + 2.41~ default    family     194. 
#>  4 scbi  lindera be~  51.4 exp(-2.2118 + 2.41~ default    family    1474. 
#>  5 scbi  lindera be~  15.4 exp(-2.2118 + 2.41~ default    family      80.4
#>  6 scbi  lindera be~  14.8 exp(-2.2118 + 2.41~ default    family      73.0
#>  7 scbi  lindera be~  15.5 exp(-2.2118 + 2.41~ default    family      81.7
#>  8 scbi  lindera be~  17.4 exp(-2.2118 + 2.41~ default    family     108. 
#>  9 scbi  lindera be~  68.2 exp(-2.2118 + 2.41~ default    family    2917. 
#> 10 scbi  lindera be~  19.3 exp(-2.2118 + 2.41~ default    family     139. 
#> # ... with 10,131 more rows
#> 
#> $`Woody species`
#> # A tibble: 0 x 7
#> # ... with 7 variables: site <chr>, sp <chr>, dbh <dbl>, eqn <chr>,
#> #   eqn_source <chr>, eqn_type <chr>, biomass <dbl>
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
