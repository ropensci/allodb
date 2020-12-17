
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://i.imgur.com/39pvr4n.png" align="left" height=44 /> allodb: An R database for biomass estimation at globally distributed extratropical forest plots

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/forestgeo/allodb.svg?branch=master)](https://travis-ci.org/forestgeo/allodb)
[![Coverage
status](https://coveralls.io/repos/github/forestgeo/allodb/badge.svg)](https://coveralls.io/r/forestgeo/allodb?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/allodb)](https://cran.r-project.org/pkg=allodb)

## Introduction

*allo-db* was conceived as a framework to standardize and simplify the
biomass estimation process across globally distributed extratropical
forests. We were inspired by the lack of standards tree biomass
calculation resources available for temperate sites within the Forest
Global Earth Observatory (ForestGEO). With *allo-db* we aimed to: a)
compile relevant published and unpublished allometries, focusing on AGB
but structured to handle other variables (e.g., height and biomass
components); b) objectively select and integrate appropriate available
equations across the full range of tree sizes; and c) serve as a
platform for future updates and expansion to other research sites
globally.

## Installation

Install the development version of *allo-db* from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("forestgeo/allodb")
```

## Examples

Prior to calculating tree biomass using *allo-db*, users need to provide
a table (i.e. dataframe) with DBH (cm), parsed species Latin names, and
site(s) coordinates. In the following examples we use data from the
Smithsonian Conservation Biology Institute, USA (SCBI) ForestGEO
dynamics plot (1st census in 2008, trees from 1 hectare). Data can be
requested through the ForestGEO portal (<https://forestgeo.si.edu/>)

``` r
library(allodb)
data(scbi_stem1)
```

The biomass of all trees in one (or several) censuses can be estimated
using the `get_biomass` function.

``` r
scbi_stem1$agb <-
  get_biomass(
    dbh = scbi_stem1$dbh,
    genus = scbi_stem1$genus,
    species = scbi_stem1$species,
    coords = c(-78.2, 38.9)
  )
```

You can also estimate biomass for a single tree given dbh and species
Id.

``` r
get_biomass(
  dbh=50, 
  genus="liriodendron", 
  species="tulipifera", 
  coords=c(-78.2, 38.9)
)
#> [1] 2829.44
```

Users can modify the set of equations that will be used to estimate the
biomass using the `new_equations` function. The default option is the
entire *allodb* equation table. Users can also work on a subset of those
equations, or add new equations to the table (see
`?allodb::new_equations`). This new equation table should be provided as
an argument in the `get_biomass` function.

``` r
show_cols <- c("equation_id", "equation_taxa", "equation_allometry")
eq_tab_acer <- new_equations(subset_taxa = "Acer")
head(eq_tab_acer[, show_cols])
#>     equation_id       equation_taxa                    equation_allometry
#> 63       dfc2c7         Acer rubrum               2.02338*(dbh^2)^1.27612
#> 64       eac63e         Acer rubrum                5.2879*(dbh^2)^1.07581
#> 86       f49bcb Acer pseudoplatanus exp(-5.644074+(2.5189*(log(pi*dbh))))
#> 107      138258         Acer rubrum            exp(-1.721+2.334*log(dbh))
#> 124      2060ea         Acer rubrum      10^(1.1891+1.419*(log10(dbh^2)))
#> 133      5084bd         Acer rubrum            exp(-2.037+2.363*log(dbh))
```

Within the `get_biomass` function, this equation table is then used to
calibrate a new allometric equation for all species/site combinations in
the user-provided dataframe. This is done by attributing a weight to
each equation based on its sampling size, and taxonomic and climatic
similarity with the species/site combination considered.

``` r
allom_weights <-
  weight_allom(genus = "Acer",
               species = "rubrum",
               coords = c(-78, 38))

## visualize weights
equ_tab_acer <- new_equations()
equ_tab_acer$weights <- allom_weights
keep_cols <-
  c("equation_id",
    "equation_taxa",
    "sample_size",
    "weights")
order_weights <- order(equ_tab_acer$weights, decreasing = TRUE)
equ_tab_acer <- equ_tab_acer[order_weights, keep_cols]
head(equ_tab_acer)
#>     equation_id       equation_taxa sample_size   weights
#> 107      138258         Acer rubrum         150 0.4150366
#> 49       d6be5c         Sapindaceae         243 0.3834078
#> 50       a2fbbb         Sapindaceae         200 0.3491456
#> 151      2630d5 Trees (Angiosperms)         886 0.2985151
#> 165      d4c590 Trees (Angiosperms)         549 0.2888162
#> 170      ae65ed Trees (Angiosperms)         289 0.2468962
```

Equations are then resampled within their original DBH range: the number
of resampled values for each equation is proportional to its weight (as
attributed by the `weight_allom` function).

``` r
df_resample <-
  resample_agb(genus = "Acer",
               species = "rubrum",
               coords = c(-78, 38)
  )

plot(
  df_resample$dbh,
  df_resample$agb,
  log = "xy",
  xlab = "DBH (cm)",
  ylab = "Resampled AGB values (kg)"
)
```

![](README_files/figure-gfm/resample-acer-1.png)<!-- -->

The resampled values are then used to fit the following linear model:
log(AGB) \~ log(DBH). The parameters (*a* intercept, *b* slope, and
*sigma* standard deviation of residuals) are returned by the
`est_params` function.

``` r
pars_acer <- est_params(
  genus = "Acer",
  species = "rubrum",
  coords = c(-78, 38)
)
plot(
  df_resample$dbh,
  df_resample$agb,
  log = "xy",
  xlab = "DBH (cm)",
  ylab = "Resampled AGB values (kg)"
)
curve(exp(pars_acer$a) * x ^ pars_acer$b * exp(0.5 * pars_acer$sigma^2),
      add = TRUE, col = 2, lwd = 2)
```

![](README_files/figure-gfm/est-params-acer-1.png)<!-- -->

The `est_params` function can be used for all species/site combinations
in the dataset at once.

``` r
params <- est_params(
  genus = scbi_stem1$genus,
  species = scbi_stem1$species,
  coords = c(-78.2, 38.9)
)
head(params)
#>          genus     species  long  lat         a        b     sigma
#> 1:        Acer     negundo -78.2 38.9 -2.852838 2.623543 0.9963243
#> 2:        Acer      rubrum -78.2 38.9 -2.894545 2.635795 0.9795674
#> 3:   Ailanthus   altissima -78.2 38.9 -2.527428 2.496863 1.2979538
#> 4: Amelanchier     arborea -78.2 38.9 -2.558368 2.501976 1.1633499
#> 5:     Asimina     triloba -78.2 38.9 -2.704000 2.552392 1.2966349
#> 6:    Carpinus caroliniana -78.2 38.9 -2.248437 2.428657 1.0973741
```

AGB is then recalculated as `agb = exp(a) * dbh^b * exp(0.5 * sigma^2)`
within the `get_biomass` function.

The general workflow of the package is summarized in the following
figure. (xx change this figure to match new *allodb* version)

<br>

<p align="center">

<img width="100%" src="not-package-stuff/graphs/Fig1workflow.png">

</p>

<p align="center">

<sub>Figure 1. Diagram of allo-db workflow, including user input data
and an example of weighting of available equations across the DBH size
spectrum to produce a single, continuous function of AGB in relation to
DBH. The top ten allometries (indicating equation ID and taxa/taxonomic
group), after applying the weighting process, can be seen as a side
panel</sub>

</p>

<br>
