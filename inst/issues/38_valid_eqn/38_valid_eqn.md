Check if equations contain valid R code
================

``` r
library(allodb)
library(tidyverse)
```

    ## -- Attaching packages ------------------------------------------------- tidyverse 1.2.1 --

    ## v ggplot2 3.0.0     v purrr   0.2.5
    ## v tibble  1.4.2     v dplyr   0.7.6
    ## v tidyr   0.8.1     v stringr 1.3.1
    ## v readr   1.1.1     v forcats 0.3.0

    ## -- Conflicts ---------------------------------------------------- tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

Data.

``` r
data("equations", package = "allodb")
eqn <- equations$equation_allometry
```

Try to evaluate each equation and catch errors.

``` r
eval_toy <- function(text) {
  toy_value <- 10
  eval(parse(text = text), envir = list(dbh = toy_value))
}

contents <- eqn %>% 
  map(safely(eval_toy)) %>% 
  transpose()

ok <- map_lgl(contents$error, is.null) 

invalid <- tibble(
  equation_allometry = eqn[!ok], 
  messages = map_chr(contents$error[!ok], "message")
)

unique(invalid$messages)
```

    ## [1] "object 'dba' not found" "object 'BA' not found"

Issue with ‘dba’.

``` r
filter(invalid, grepl("dba", messages))
```

    ## # A tibble: 39 x 2
    ##    equation_allometry messages              
    ##    <chr>              <chr>                 
    ##  1 38.111*(dba^2.9)   object 'dba' not found
    ##  2 38.111*(dba^2.9)   object 'dba' not found
    ##  3 51.996*(dba^2.77)  object 'dba' not found
    ##  4 37.637*(dba^2.779) object 'dba' not found
    ##  5 43.992*(dba^2.86)  object 'dba' not found
    ##  6 43.992*(dba^2.86)  object 'dba' not found
    ##  7 43.992*(dba^2.86)  object 'dba' not found
    ##  8 29.615*(dba^3.243) object 'dba' not found
    ##  9 29.615*(dba^3.243) object 'dba' not found
    ## 10 29.615*(dba^3.243) object 'dba' not found
    ## # ... with 29 more rows

Proposed solution: [\#38](https://github.com/forestgeo/allodb/issues/38)
and [\#41](https://github.com/forestgeo/allodb/issues/38).

Issue with ‘BA’.

``` r
filter(invalid, grepl("BA", messages))
```

    ## # A tibble: 1 x 2
    ##   equation_allometry messages             
    ##   <chr>              <chr>                
    ## 1 51.68+0.02*BA      object 'BA' not found

How should we deal with this?
