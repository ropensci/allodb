The package fails to load. The problem seems to be in line 17 of DESCRIPTION.

``` r
devtools::load_all()
#> Loading allodb
#> Invalid DESCRIPTION:
#> Malformed Authors@R field:
#>   <text>:18:0: unexpected end of input
#> 16:              role = "aut",
#> 17:              email = "TeixeiraK@si.edu"))
#>    ^
#> 
#> See section 'The DESCRIPTION file' in the 'Writing R Extensions'
#> manual.
#> Warning in (function (dep_name, dep_ver = "*") : Dependency package 'kgc' not
#> available.
#> Error: Dependency package(s) 'kgc' not available.
```
