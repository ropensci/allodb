Eploring Data By Ervan Rutishauser
================
Mauro Lepore, Ervan Rutishauser, ...
2017-11-06

-   [Overview](#overview)
    -   [Source](#source)
    -   [Setup](#setup)
    -   [Explore data](#explore-data)
    -   [Explore code](#explore-code)

Overview
========

Source
------

On Sat, Oct 28, 2017 at 4:05 AM, Ervan Rutishauser <er.rutishauser@gmail.com> wrote:

> For now, you can use the R functions that I have developed to compute biomass at all tropical CTFS sites. It is based on Chave et al 2014 allometric models and some modified functions of the BIOMASS package. It computes biomass after having allocated wood density. The wood density database arise from CTFS and, I guess, isn't aimed to be shared publicly.

Setup
-----

Make data manipulation and visualization easier

``` r
library(tidyverse)
# Print only few rows of dataframes to save space and time
options(dplyr.print_min = 3, dplyr.print_max = 3)
```

Load data objects and functions in **allodb** (from Ervan)

``` r
library(allodb)
```

![](https://i.imgur.com/O9rt33U.png)

Explore data
------------

``` r
glimpse(ficus)
#> Observations: 67
#> Variables: 8
#> $ Mnemonic   <fctr> FICUAB, FICUAL, Ficuamaz, FICUAN, ficutr, FICUBJ, ...
#> $ Genus      <fctr> Ficus, Ficus, Ficus, Ficus, Ficus, Ficus, Ficus, F...
#> $ Species    <fctr> albipila, altissima, amazonica, annulata, aurea, b...
#> $ Subgenus   <fctr> Pharmacosycea, Urostigma, Urostigma, Urostigma, Ur...
#> $ Section    <fctr> Oreosycea, Urostigma, Americana, Urostigma, Americ...
#> $ Subsection <fctr> Pedunculatae, Conosycea, , Conosycea, , Conosycea,...
#> $ Strangler  <fctr> No, Yes, Yes, Yes, Yes, Yes, Yes, Yes, Yes, No, Ye...
#> $ name       <chr> "Ficus albipila", "Ficus altissima", "Ficus amazoni...
```

``` r
glimpse(site.info)
#> Observations: 63
#> Variables: 12
#> $ id            <dbl> 42.0, 51.0, 52.0, 45.0, 18.0, 53.0, 46.0, 14.0, ...
#> $ Site          <fctr> Amacayacu, Badagongshan, Baotianman, Barro Colo...
#> $ site          <fctr> amacayacu, badagongshan, baotianman, barro colo...
#> $ lat           <dbl> -3.81, 29.46, 33.50, 9.15, 1.35, 42.38, 8.99, 5....
#> $ long          <dbl> -70.3, 110.5, 111.9, -79.8, 103.8, 128.1, -79.6,...
#> $ UTM_Zone      <int> 19, 49, 49, 17, 48, 52, 17, 50, 49, 47, 50, 51, ...
#> $ UTM_X         <fctr> 359223.7022, 453456.2453, 587323.8348, 626783.7...
#> $ UTM_Y         <fctr> 9578870.297, 3259047.312, 3706005.813, 1012114....
#> $ intertropical <fctr> Tropical, Other, Other, Tropical, Tropical, Oth...
#> $ size.ha       <dbl> 25.0, 25.0, 25.0, 50.0, 4.0, 25.0, 4.0, 50.0, 20...
#> $ E             <dbl> -0.07929, 1.01162, 1.19960, 0.04945, -0.08480, 1...
#> $ wsg.site.name <fctr> amacayacu, , , bci, bukittimah, changbai, , , ,...
```

``` r
glimpse(WSG)
#> Observations: 16,558
#> Variables: 9
#> $ wsg     <dbl> 0.567, 0.585, 0.450, 0.300, 0.657, 0.657, 0.818, 0.819...
#> $ idlevel <chr> "genus", "species", "genus", "genus", "genus", "genus"...
#> $ site    <chr> "amacayacu", "amacayacu", "amacayacu", "amacayacu", "a...
#> $ sp      <chr> "abarbarb", "abarjupu", "abutgran", "acalcune", "aegic...
#> $ genus   <chr> "Abarema", "Abarema", "Abuta", "Acalypha", "Aegiphila"...
#> $ species <chr> "barbouriana", "jupunba", "grandifolia", "cuneata", "c...
#> $ genwood <dbl> 0.567, 0.567, 0.450, 0.300, 0.657, 0.657, 0.819, 0.819...
#> $ famwood <dbl> 0.678, 0.678, 0.545, 0.509, 0.539, 0.539, 0.742, 0.742...
#> $ spwood  <dbl> NA, 0.585, NA, NA, NA, NA, 0.818, NA, 0.427, NA, NA, N...
```

I'm particularly interested in these data. Can we add a variable `equation` -- relating dbh with biomass based on `wsg` and `E`?

``` r
left_join(site.info, WSG) %>% 
  select(site, genus, species, wsg, E)
#> Joining, by = "site"
#> Warning: Column `site` joining factor and character vector, coercing into
#> character vector
#> # A tibble: 8,600 x 5
#>        site   genus     species   wsg       E
#>       <chr>   <chr>       <chr> <dbl>   <dbl>
#> 1 amacayacu Abarema barbouriana 0.567 -0.0793
#> 2 amacayacu Abarema     jupunba 0.585 -0.0793
#> 3 amacayacu   Abuta grandifolia 0.450 -0.0793
#> # ... with 8,597 more rows
```

Explore code
------------

Ervan, could you show some examples of how your funcitons work?

The help files live here <https://forestgeo.github.io/allodb/reference/index.html>
