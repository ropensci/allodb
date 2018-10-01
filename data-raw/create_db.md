Gather raw data,clean it and export it to data/
================

Take each dataset in data/ and write an editable version of it.

``` r
dirs <- dir_ls(here("./data"))
datasets_chr <- path_ext_remove(path_file(dirs))
datasets_chr %>% 
  map(~get(.x, pos = "package:allodb")) %>% 
  set_names(datasets_chr) %>% 
  fgeo.tool::dfs_to_csv(here("data-raw/db"))
```

The result is a collection of .csv files that could be used to enter
data from now on.

``` r
path_file(dir_ls(here("data-raw/db")))
#> equations.csv               equations_metadata.csv      
#> missing_values_metadata.csv references_metadata.csv     
#> sitespecies.csv             sitespecies_metadata.csv    
#> sites_info.csv              wsg.csv                     
#> wsg_metadata.csv
```

If all the resulting .csv files had a `key` column (e.g. `equation_id`)
and had no duplicated rows, then they would constitute a normalized
database. The different talbes can then be joined with e.g.
`dplyr::left_join()` (or `LEFT JOIN` in SQL).

``` r
sitespecies <- read_csv(here("data-raw/db/sitespecies.csv"))
dim(sitespecies)
#> [1] 602  15

sites_info <- read_csv(here("data-raw/db/sites_info.csv"))
dim(sites_info)
#> [1] 63 12

dim(left_join(sites_info, sitespecies))
#> [1] 63 26
```
