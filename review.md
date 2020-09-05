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

The version number 1.0 suggests the package is released. To more clearly reflect it's in development (at least not released on CRAN), I incremented the version to 1.0.0.9000, as the the suffix .9*** by convension indicatse "in development" (see <https://usethis.r-lib.org/reference/use_version.html>).


