### Load in development mode

The package failed to load. The `persons()` had syntax errors. I fixed it.

``` r
devtools::load_all()
#> Loading allodb
#> Invalid DESCRIPTION:
#> Malformed Authors@R field:
#>   <text>:18:0: unexpected end of input
#> 16:              role = "aut",
#> 17:              email = "TeixeiraK@si.edu"))
#>    ^
```



### Install from GitHub

The package installs but throws a WARNING. Maybe google the warning to see what it means and how to adress its ultimate cause. For now I just do what the warning says, i.e. add R (>= 3.5.0) under the field `Depends:` of DESCRIPTION. 

```r
remotes::install_github("maurolepore/allodb@review")
#> Using github PAT from envvar GITHUB_PAT
#> Downloading GitHub repo maurolepore/allodb@review
#> 

...

#>   ─  checking for empty or unneeded directories
#>        NB: this package now depends on R (>= 3.5.0)
#>        WARNING: Added dependency on R >= 3.5.0 because serialized objects in  serialize/load version 3 cannot be read in older versions of R.  File(s) containing such objects: ‘allodb/data/genus_family.rda’  ‘allodb/data/gymno_genus.rda’

...  

#> Installing package into '/home/mauro/R/x86_64-pc-linux-gnu-library/4.0'
#> (as 'lib' is unspecified)
#> Adding 'allodb_1.0_R_x86_64-pc-linux-gnu.tar.gz' to the cache
```

### Tidy DESCRIPTION

* Use developmen version. The version number 1.0 suggests the package is released. To more clearly reflect it's in development (at least not released on CRAN), I incremented the version to 1.0.0.9000, as the the suffix .9*** by convension indicatse "in development" (`usethis::use_dev_version()`).

* Tidy DESCRIPTION. (see `?usethis::use_tidy_description()`).


### Update documentation (`devtools::document()`)

* `devtools::document()`.

### R CMD check (`devtools::check()`)

* R CMD check returns 2 errors, 5 warnings, and 5 notes:

WARNINGS

* You can avoid this warning by avoiding spaces in paths, e.g. use 
"a-folder/a-file.txt" not "a folder/a file.txt". I leave this to you.

```
W  checking for portable file names ...
   Found the following files with non-portable file names:
     tests/evaluation_of_equations/1-About validation data.txt
     tests/evaluation_of_equations/...
     ...
     koppen climates
     tests/graphs/harvard forest
     tests/graphs/...
     ...
   These are not fully portable file names.
```

* I think you can ignore this.

```
N  checking for future file timestamps (2.1s)
   unable to verify current time
```

* The title field should use "Title Case" and not end in a period. I fixed it.

```
N  checking DESCRIPTION meta-information ...
   Malformed Title field: should not end in a period.
```

 
* These directories are not standard in an R package. Add them to .Rbuildignore (see `?usethis::use_build_ignore()`). I fixed it.

```
N  checking top-level files ...
   Non-standard files/directories found at top level:
     ‘_config.yml’ ‘koppen climates’ ‘phyloDist’
```


* It seems that the package 'raster' is used in `koppenObs = climates[raster::extract(koppenRaster, coordsSite)]` but it wasn't listed under the field `Imorts:` of the file DESCRIPTION. Add it with `usethis::use_package("raster")`. I fixed it.

```
W  checking dependencies in R code (450ms)
   '::' or ':::' import not declared from: ‘raster’
```

* Fix this and similar problems with `#' @importFrom utils data` (see R/imports.R). I added one case as an example, but I leave this to you.

```
N  checking R code for possible problems (1.8s)
   add_equation: no visible global function definition for ‘data’
```

* Define global variables in as `globalVariables(c("equation_id", "obs_id"))`. If used in tidyverse functions you may instead refer to them using the pronoun `.data`, e.g. `.data$equation_id` or `.data$obs_id`. I leave this to you.

* Define global functions using the syntax `dplyr::filter()` instead of just `filter()` or use something like `#' @importFrom dplyr filter` (see R/imports.R). I leave this to you.

```
   Undefined global functions or variables:
     RoundCoordinates data dependent_variable equation_id equations
     gymno_genus independent_variable koppenMatrix koppenRaster obs_id
     ref_id shrub_species
```

* See section ‘Good practice’ in ‘?data’. I leave this fix to you.

> It would almost always be better to put the object in the current evaluation environment by data(..., envir = environment()). However, two alternatives are usually preferable ...

```
   Found the following calls to data() loading into the global environment:
   File ‘allodb/R/add_equations.R’:
     data("equations")
     ...
   See section ‘Good practice’ in ‘?data’.
```

* All user-level objects in a package should have documentation entries. Document datasets in R/data.R. For example I added a template for "genus_family". I leave the rest to you.

```
W  checking for missing documentation entries ...
   Undocumented data sets:
     ‘genus_family’ ‘gymno_genus’ ‘koppenMatrix’ ‘koppenRaster’
     ‘references’ ‘scbi_stem1’ ‘shrub_species’
   All user-level objects in a package should have documentation entries.
```

* The example of `add_equation()` throws an error. I leave this to you.

```
E  checking examples (453ms)
   Running examples in ‘allodb-Ex.R’ failed
...
   > ### Name: add_equation
...
   > ### ** Examples
   > 
   > new_equations = add_equation(taxa = "Faga", level = "genus",
   + allometry = "exp(-2+log(dbh)*2.5)", coords = c(-0.07, 46.11),
   + minDBH = 5, maxDBH = 50, sampleSize = 50)
   Error in add_equation(taxa = "Faga", level = "genus", allometry = "exp(-2+log(dbh)*2.5)",  : 
     unitDBH must be either `Species`, `Genus`, `Family`, or `Woody species`, `Mixed conifers`.
   Execution halted
```

* Check spelling with `spelling::spell_check_package()`, then update "inst/WORDSLIST" with `spelling::update_wordlist()`. I leave this to you.

```
X  Comparing ‘spelling.Rout’ to ‘spelling.Rout.save’ ...
   < Potential spelling errors:
   <   WORD            FOUND IN
   < Bohn            get_biomass.Rd:64
   < DBH             add_equation.Rd:30,32,36
...
```

* Many tests fail. I leave this to you.

```
E  Running ‘testthat.R’ (1.1s)
...

══ testthat results  ════════════════════════════════════════
Warning: Exported datasets match known output (test-data.R:15:3)
Failure: Exported datasets match known output (test-data.R:15:3)
Warning: Exported datasets match known output (test-data.R:19:3)
Failure: Exported datasets match known output (test-data.R:19:3)
Warning: Exported datasets match known output (test-data.R:34:3)
Error: Exported datasets match known output (test-data.R:35:3)
Error: master_tidy() returns correct column types (test-master.R:4:3)
Error: master() sites match `sites_info$site` (#79),
  except 'any*' (fgeo.biomass#31) (test-master.R:15:3)
Error: master outputs lowercase values of site (#79) (test-master.R:27:3)
Error: master doesn't duplicate names (test-master.R:32:3)
Error: master outputs the expected object (allodb#78) (test-master.R:40:3)
Failure: `equations` and `sitespecies` have no redundant columns (#78) (test-master.R:45:3)
Error: master outputs no missing `equation_id` (test-master.R:52:3)
Error: master returns known output (test-master.R:56:3)
Error: master_tidy returns no missing values in `dbh_*_cm` (test-master.R:66:3)
Error: master_tidy returns in `dbh_min_cm` some 0 (test-master.R:71:3)
Error: master_tidy returns in `dbh_max_cm` some Inf (test-master.R:75:3)
Error: (code run outside of `test_that()`) (test-type_allodb_master.R:3:1)

[ PASS x2 FAIL x15 WARN x3 SKIP x0 ]
```

