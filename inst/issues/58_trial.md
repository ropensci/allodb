**allodb**, **bmss** and data from SCBI: A trial
================
Mauro Lepore
2018-11-06

``` r
library(tidyverse)
library(bmss)
library(allodb)
```

Maybe add some of these helpers to **allodb**, **bmss**, or elsewhere.

``` r
# List all datasets of a package.
datasets <- function(package) {
  sort(utils::data(package = package)$results[ , "Item"])
}

compare_names <- function(x, y) {
  list(x, y) %>% 
    purrr::map(names) %>% 
    purrr::reduce(setdiff)
}

add_species <- function(.census, .species) {
  suppressMessages({
    .species %>% 
      tidyr::unite("species", Genus, Species, sep = " ") %>% 
      dplyr::select(species, sp) %>% 
      dplyr::right_join(.census)
  })
}

add_site <- function(.census, site) {
  found_site <- grep(site, allodb::sites_info$site, ignore.case = TRUE, value = TRUE)
  if (identical(length(found_site), 0)) {
    rlang::abort( glue::glue("Can't find any site mathing {site}."))
  }
  
  rlang::inform(glue::glue("Using site {rlang::expr_label(found_site)}."))
  tibble::add_column(.census, site = found_site)
}
```

### Database data

All datasets.

``` r
datasets("allodb")
#>  [1] "equations"               "equations_metadata"     
#>  [3] "missing_values_metadata" "references_metadata"    
#>  [5] "scbi_species"            "scbi_stem1"             
#>  [7] "scbi_stem2"              "scbi_tree1"             
#>  [9] "scbi_tree2"              "sites_info"             
#> [11] "sitespecies"             "sitespecies_metadata"   
#> [13] "wsg"                     "wsg_metadata"
```

The core table of **allodb** is `equations`.

``` r
glimpse(equations)
#> Observations: 175
#> Variables: 22
#> $ ref_id                               <chr> "jenkins_2004_cdod", "jen...
#> $ equation_allometry                   <chr> "10^(1.1891+1.419*(log10(...
#> $ equation_id                          <chr> "2060ea", "a4d879", "c59e...
#> $ equation_form                        <chr> "10^(a+b*(log10(DBH^c)))"...
#> $ dependent_variable_biomass_component <chr> "Total aboveground biomas...
#> $ independent_variable                 <chr> "DBH", "DBH", "DBH", "DBH...
#> $ allometry_specificity                <chr> "Species", "Species", "Ge...
#> $ geographic_area                      <chr> "Ohio, USA", "Ohio, USA",...
#> $ dbh_min_cm                           <chr> "0.21", "0.19", "8.9", "5...
#> $ dbh_max_cm                           <chr> "5.73", "3.86", "25.4", "...
#> $ sample_size                          <chr> NA, NA, NA, NA, NA, NA, "...
#> $ dbh_units_original                   <chr> "cm", "cm", "cm", "in", "...
#> $ biomass_units_original               <chr> "g", "g", "g", "g", "g", ...
#> $ allometry_development_method         <chr> "harvest", "harvest", "ha...
#> $ regression_model                     <chr> NA, NA, NA, NA, NA, NA, "...
#> $ other_equations_tested               <chr> NA, NA, NA, NA, NA, NA, N...
#> $ log_biomass                          <chr> NA, NA, NA, NA, NA, NA, "...
#> $ bias_corrected                       <chr> "1", "1", "1", "0", "0", ...
#> $ bias_correction_factor               <chr> "1.056", "1.016", "includ...
#> $ notes_fitting_model                  <chr> NA, NA, NA, NA, NA, NA, N...
#> $ original_data_availability           <chr> NA, NA, NA, NA, NA, NA, N...
#> $ warning                              <chr> NA, NA, NA, NA, NA, NA, N...
```

Some equations need to be fixed. Here we’ll use the good ones.

``` r
drop_bad_equations(equations)
#> # A tibble: 151 x 22
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
#> # ... with 141 more rows, and 17 more variables:
#> #   independent_variable <chr>, allometry_specificity <chr>,
#> #   geographic_area <chr>, dbh_min_cm <chr>, dbh_max_cm <chr>,
#> #   sample_size <chr>, dbh_units_original <chr>,
#> #   biomass_units_original <chr>, allometry_development_method <chr>,
#> #   regression_model <chr>, other_equations_tested <chr>,
#> #   log_biomass <chr>, bias_corrected <chr>, bias_correction_factor <chr>,
#> #   notes_fitting_model <chr>, original_data_availability <chr>,
#> #   warning <chr>
```

`master()` combines multiple database tables. Glimpse excluding
problematic equations.

``` r
drop_bad_equations(master())
#> # A tibble: 685 x 62
#>    ref_id equation_allome~ equation_id equation_form dependent_varia~
#>    <chr>  <chr>            <chr>       <chr>         <chr>           
#>  1 jenki~ 10^(1.1891+1.41~ 2060ea      10^(a+b*(log~ Total abovegrou~
#>  2 jenki~ 10^(1.1891+1.41~ 2060ea      10^(a+b*(log~ Total abovegrou~
#>  3 jenki~ 10^(1.2315+1.63~ a4d879      10^(a+b*(log~ Total abovegrou~
#>  4 jenki~ 10^(1.2315+1.63~ a4d879      10^(a+b*(log~ Total abovegrou~
#>  5 jenki~ exp(7.217+1.514~ c59e03      exp(a+b*ln(D~ Stem biomass (w~
#>  6 jenki~ exp(7.217+1.514~ c59e03      exp(a+b*ln(D~ Stem biomass (w~
#>  7 jenki~ exp(7.217+1.514~ c59e03      exp(a+b*ln(D~ Stem biomass (w~
#>  8 jenki~ exp(7.217+1.514~ c59e03      exp(a+b*ln(D~ Stem biomass (w~
#>  9 jenki~ exp(7.217+1.514~ c59e03      exp(a+b*ln(D~ Stem biomass (w~
#> 10 jenki~ exp(7.217+1.514~ c59e03      exp(a+b*ln(D~ Stem biomass (w~
#> # ... with 675 more rows, and 57 more variables:
#> #   independent_variable <chr>, allometry_specificity <chr>,
#> #   geographic_area <chr>, dbh_min_cm <chr>, dbh_max_cm <chr>,
#> #   sample_size <chr>, dbh_units_original <chr>,
#> #   biomass_units_original <chr>, allometry_development_method <chr>,
#> #   regression_model <chr>, other_equations_tested <chr>,
#> #   log_biomass <chr>, bias_corrected <chr>, bias_correction_factor <chr>,
#> #   notes_fitting_model <chr>, original_data_availability <chr>,
#> #   warning <chr>, site <chr>, family <chr>, species <chr>,
#> #   species_code <chr>, life_form <chr>, equation_group <chr>,
#> #   equation_taxa <chr>, notes_on_species <chr>, wsg_id <chr>,
#> #   wsg_specificity <chr>, X16 <chr>, X17 <chr>, X18 <chr>, X19 <chr>,
#> #   X20 <chr>, X21 <chr>, X22 <chr>, X23 <chr>, X24 <chr>, X25 <chr>,
#> #   X26 <chr>, X27 <chr>, X28 <chr>, X29 <chr>, X30 <chr>, X31 <chr>,
#> #   X32 <chr>, X33 <chr>, X34 <chr>, id <chr>, Site <chr>, lat <chr>,
#> #   long <chr>, UTM_Zone <chr>, UTM_X <chr>, UTM_Y <chr>,
#> #   intertropical <chr>, size.ha <chr>, E <chr>, wsg.site.name <chr>
```

### Census data

``` r
scbi_tree1
#> # A tibble: 40,283 x 20
#>    treeID stemID tag   StemTag sp    quadrat    gx    gy DBHID CensusID
#>  *  <int>  <int> <chr> <chr>   <chr> <chr>   <dbl> <dbl> <int>    <int>
#>  1      1      1 10079 1       libe  0104     3.70  73       1        1
#>  2      2      2 10168 1       libe  0103    17.3   58.9     3        1
#>  3      3      3 10567 1       libe  0110     9    197.      5        1
#>  4      4      4 12165 1       nysy  0122    14.2  428.      7        1
#>  5      5      5 12190 1       havi  0122     9.40 436.      9        1
#>  6      6      6 12192 1       havi  0122     1.30 434      13        1
#>  7      7      7 12212 1       unk   0123    17.8  447.     15        1
#>  8      8      8 12261 1       libe  0125    18    484.     17        1
#>  9      9      9 12456 1       vipr  0130    18    598.     19        1
#> 10     10     10 12551 1       astr  0132     5.60 628.     22        1
#> # ... with 40,273 more rows, and 10 more variables: dbh <dbl>, pom <chr>,
#> #   hom <dbl>, ExactDate <chr>, DFstatus <chr>, codes <chr>,
#> #   nostems <dbl>, date <dbl>, status <chr>, agb <dbl>
```

This dataset is not structured exactly as a reference dataset from
Luquillo but the difference is irrelevant to calculating biomass. The
column `agb` is not useful and `DBHID` is equivalent to `MeasureID`.

``` r
reference_tree <- fgeo.data::luquillo_tree5_random

# In scbi but not luquillo
compare_names(scbi_tree1, reference_tree)
#> [1] "DBHID" "agb"
# In luquillo but not scbi
compare_names(reference_tree, scbi_tree1)
#> [1] "MeasureID"
```

Let’s add columns `site` and `species`.

  - FIXME: Wrap into a single `add_site_sp()` function, or
    `prepare_census()`, or `as_allodb_census()` (with corresponding
    `new_allodb_census()`, and `validate_allodb_census()` – which is
    responsible to check stuff that then no longer needs to be checked
    downstream in **bmss**)?

<!-- end list -->

``` r
scbi <- scbi_tree1 %>% 
  add_species(scbi_species) %>% 
  add_site(site = "SCBI")
#> Using site "scbi".

scbi %>% select(site, species, everything())
#> # A tibble: 40,283 x 22
#>    site  species sp    treeID stemID tag   StemTag quadrat    gx    gy
#>    <chr> <chr>   <chr>  <int>  <int> <chr> <chr>   <chr>   <dbl> <dbl>
#>  1 scbi  Linder~ libe       1      1 10079 1       0104     3.70  73  
#>  2 scbi  Linder~ libe       2      2 10168 1       0103    17.3   58.9
#>  3 scbi  Linder~ libe       3      3 10567 1       0110     9    197. 
#>  4 scbi  Nyssa ~ nysy       4      4 12165 1       0122    14.2  428. 
#>  5 scbi  Hamame~ havi       5      5 12190 1       0122     9.40 436. 
#>  6 scbi  Hamame~ havi       6      6 12192 1       0122     1.30 434  
#>  7 scbi  Uniden~ unk        7      7 12212 1       0123    17.8  447. 
#>  8 scbi  Linder~ libe       8      8 12261 1       0125    18    484. 
#>  9 scbi  Viburn~ vipr       9      9 12456 1       0130    18    598. 
#> 10 scbi  Asimin~ astr      10     10 12551 1       0132     5.60 628. 
#> # ... with 40,273 more rows, and 12 more variables: DBHID <int>,
#> #   CensusID <int>, dbh <dbl>, pom <chr>, hom <dbl>, ExactDate <chr>,
#> #   DFstatus <chr>, codes <chr>, nostems <dbl>, date <dbl>, status <chr>,
#> #   agb <dbl>
```

  - FIXME: Update `bmss::get_allometry()` to no longer default to use
    the dummy dataset build in **bmss** but `allodb::equation` (or
    `allodb::master()` or similar).

  - FIXME: Rename as needed internals to work with new names (`old` =
    `new`):
    
      - `eqn` = `equation_allometry`.
      - `eqn_source` = `eqn_source`.
      - `eqn_type` = `allometry_specificity`.

<!-- end list -->

``` r
# FIXME
get_allometry(scbi, "site", "species", "dbh")
#> You gave no custom equations.
#>   * Using default equations.
#> # A tibble: 40,283 x 6
#>    site  sp                     dbh eqn   eqn_source eqn_type
#>    <chr> <chr>                <dbl> <chr> <chr>      <chr>   
#>  1 scbi  Lindera benzoin       27.9 <NA>  <NA>       <NA>    
#>  2 scbi  Lindera benzoin       23.7 <NA>  <NA>       <NA>    
#>  3 scbi  Lindera benzoin       22.2 <NA>  <NA>       <NA>    
#>  4 scbi  Nyssa sylvatica      135   <NA>  <NA>       <NA>    
#>  5 scbi  Hamamelis virginiana  87   <NA>  <NA>       <NA>    
#>  6 scbi  Hamamelis virginiana  22.5 <NA>  <NA>       <NA>    
#>  7 scbi  Unidentified unk      42.6 <NA>  <NA>       <NA>    
#>  8 scbi  Lindera benzoin       51.4 <NA>  <NA>       <NA>    
#>  9 scbi  Viburnum prunifolium  38.3 <NA>  <NA>       <NA>    
#> 10 scbi  Asimina triloba       14.5 <NA>  <NA>       <NA>    
#> # ... with 40,273 more rows
```

  - FIXME: Update **bmss** to work with one category, say, “Family”, or
    “Species”. Then further update to deal with all other categories.

<!-- end list -->

``` r
master()$allometry_specificity %>% unique()
#> [1] "Species"        "Genus"          "Mixed hardwood" "Family"        
#> [5] "Woody species"  NA
```
