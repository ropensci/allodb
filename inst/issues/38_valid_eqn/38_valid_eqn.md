Check if equations contain valid R code
================

``` r
library(allodb)
library(tidyverse)
```

    ## -- Attaching packages ------------------------------------------------ tidyverse 1.2.1 --

    ## v ggplot2 2.2.1     v purrr   0.2.4
    ## v tibble  1.4.2     v dplyr   0.7.4
    ## v tidyr   0.8.0     v stringr 1.3.0
    ## v readr   1.1.1     v forcats 0.3.0

    ## -- Conflicts --------------------------------------------------- tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

Data.

``` r
data("equations", package = "allodb")
eqn <- equations$equation_allometry
```

Try to evaluate each equation and catch errors.

``` r
eval_eqn <- purrr::safely(
  function(text, envir) eval(parse(text = text), envir = envir)
)
out <- map(eqn, ~eval_eqn(.x, list(dbh = 10)))

results <- out %>% map("result") %>% modify_if(is.null, ~NA_real_)
messages <- out %>%
  map("error") %>%
  map("message") %>%
  modify_if(is.null, ~NA_character_)

res <- unnest(tibble(equation_allometry = eqn, results, messages))
```

``` r
valid <- filter(res, !is.na(results))
valid
```

    ## # A tibble: 265 x 3
    ##    equation_allometry                results messages
    ##    <chr>                               <dbl> <chr>   
    ##  1 exp(7.217+1.514*log(dbh))        44494.   <NA>    
    ##  2 exp(-2.48+2.4835*log(dbh))          25.5  <NA>    
    ##  3 exp(-2.48+2.4835*log(dbh))          25.5  <NA>    
    ##  4 2.034*(dbh^2.6349)                 878.   <NA>    
    ##  5 exp(-2.48+2.4835*log(dbh))          25.5  <NA>    
    ##  6 exp(-2.5095+2.5437*log(dbh))        28.4  <NA>    
    ##  7 exp(-2.2118+2.4133*log(dbh))        28.4  <NA>    
    ##  8 2.0394*(dbh^2.5715)                760.   <NA>    
    ##  9 3.203+(-0.234*dbh)+0.006*(dbh^2)     1.46 <NA>    
    ## 10 3.203+(-0.234*dbh)+0.006*(dbh^2)     1.46 <NA>    
    ## # ... with 255 more rows

``` r
invalid <- filter(res, is.na(results))
invalid
```

    ## # A tibble: 154 x 3
    ##    equation_allometry               results messages                      
    ##    <chr>                              <dbl> <chr>                         
    ##  1 10^(1.1891+1.419(log10(dbh^2)))       NA attempt to apply non-function 
    ##  2 10^(1.2315+1.6376(log10(dbh^2)))      NA attempt to apply non-function 
    ##  3 10^(2.5368+1.3197(log10(dbh)))        NA attempt to apply non-function 
    ##  4 10^(2.0865+2.555(log10(dbh)))         NA attempt to apply non-function 
    ##  5 10^(-1.326+2.762(log10(dbh)))         NA attempt to apply non-function 
    ##  6 10^(-1.326+2.762(log10(dbh)))         NA attempt to apply non-function 
    ##  7 10^(-1.326+2.762(log10(dbh)))         NA attempt to apply non-function 
    ##  8 exp(5.67+1.97*dbh+1*log(dbh)))        NA "<text>:1:30: unexpected ')'\~
    ##  9 10^(1.2784+1.4248(log10(dbh^2)))      NA attempt to apply non-function 
    ## 10 38.111*(dba^2.9)                      NA object 'dba' not found        
    ## # ... with 144 more rows

Examine details about each equation.

    View(invalid)

### General problems and soultions

``` r
# For reuse
filter_pattern <- function(pattern) filter(invalid, grepl(pattern, messages))
vars <- c("equation_allometry", "valid", "result")

fix_problem <- function(pattern1, pattern2, replacement) {
  filter_pattern(pattern1) %>% 
    mutate(
      valid = str_replace(equation_allometry, pattern2, replacement),
      result = map_dbl(.data$valid, ~eval(parse(text = .x), list(dbh = 10)))
    ) %>% 
    select(equation_allometry, valid, result)
}
```

The expression {`number(`} is invalid: For example `10^(1.1891 +`
{`1.419(`} `log10(dbh^2)))`. Adding a star (`*`) fixes the problem.

``` r
fix_problem("attempt", "([0-9])(\\(log10)", "\\1 * \\2")
```

    ## # A tibble: 66 x 3
    ##    equation_allometry               valid                           result
    ##    <chr>                            <chr>                            <dbl>
    ##  1 10^(1.1891+1.419(log10(dbh^2)))  10^(1.1891+1.419 * (log10(db~   1.06e4
    ##  2 10^(1.2315+1.6376(log10(dbh^2))) 10^(1.2315+1.6376 * (log10(d~   3.21e4
    ##  3 10^(2.5368+1.3197(log10(dbh)))   10^(2.5368+1.3197 * (log10(d~   7.19e3
    ##  4 10^(2.0865+2.555(log10(dbh)))    10^(2.0865+2.555 * (log10(db~   4.38e4
    ##  5 10^(-1.326+2.762(log10(dbh)))    10^(-1.326+2.762 * (log10(db~   2.73e1
    ##  6 10^(-1.326+2.762(log10(dbh)))    10^(-1.326+2.762 * (log10(db~   2.73e1
    ##  7 10^(-1.326+2.762(log10(dbh)))    10^(-1.326+2.762 * (log10(db~   2.73e1
    ##  8 10^(1.2784+1.4248(log10(dbh^2))) 10^(1.2784+1.4248 * (log10(d~   1.34e4
    ##  9 10^(0.8306+2.7308(log10(dbh^2))) 10^(0.8306+2.7308 * (log10(d~   1.96e6
    ## 10 10^(1.1468+2.363(log10(dbh^2)))  10^(1.1468+2.363 * (log10(db~   7.46e5
    ## # ... with 56 more rows

`dba` is missing. This has no immediate solution. We need to find a way
to calculate `dba` from ForestGEO census data.

``` r
filter_pattern("object")
```

    ## # A tibble: 40 x 3
    ##    equation_allometry results messages              
    ##    <chr>                <dbl> <chr>                 
    ##  1 38.111*(dba^2.9)        NA object 'dba' not found
    ##  2 38.111*(dba^2.9)        NA object 'dba' not found
    ##  3 51.996*(dba^2.77)       NA object 'dba' not found
    ##  4 37.637*(dba^2.779)      NA object 'dba' not found
    ##  5 43.992*(dba^2.86)       NA object 'dba' not found
    ##  6 43.992*(dba^2.86)       NA object 'dba' not found
    ##  7 43.992*(dba^2.86)       NA object 'dba' not found
    ##  8 29.615*(dba^3.243)      NA object 'dba' not found
    ##  9 29.615*(dba^3.243)      NA object 'dba' not found
    ## 10 29.615*(dba^3.243)      NA object 'dba' not found
    ## # ... with 30 more rows

There are a few trailing `)` and removing them fixes the problem.

``` r
fix_problem("unexpected ')'", "\\)$", "")
```

    ## # A tibble: 24 x 3
    ##    equation_allometry                  valid                        result
    ##    <chr>                               <chr>                         <dbl>
    ##  1 exp(5.67+1.97*dbh+1*log(dbh)))      exp(5.67+1.97*dbh+1*log(db~ 1.04e12
    ##  2 exp(4.97+2.34*dbh+1*log(dbh)))      exp(4.97+2.34*dbh+1*log(db~ 2.09e13
    ##  3 exp(1.92+1.86*dbh+1*log(dbh)))      exp(1.92+1.86*dbh+1*log(db~ 8.16e 9
    ##  4 exp(5.67+1.97*dbh+1*log(dbh)))      exp(5.67+1.97*dbh+1*log(db~ 1.04e12
    ##  5 exp(5.67+1.97*dbh+1*log(dbh)))      exp(5.67+1.97*dbh+1*log(db~ 1.04e12
    ##  6 exp(4.97+2.34*dbh+1*log(dbh)))      exp(4.97+2.34*dbh+1*log(db~ 2.09e13
    ##  7 exp(1.92+1.86*dbh+1*log(dbh)))      exp(1.92+1.86*dbh+1*log(db~ 8.16e 9
    ##  8 exp(-10.755+2.7308*dbh+1*log(dbh))) exp(-10.755+2.7308*dbh+1*l~ 1.54e 8
    ##  9 exp(-10.755+2.7308*dbh+1*log(dbh))) exp(-10.755+2.7308*dbh+1*l~ 1.54e 8
    ## 10 exp(-2.037+2.363*dbh+1*log(dbh)))   exp(-2.037+2.363*dbh+1*log~ 2.39e10
    ## # ... with 14 more rows

The `*` in \`pi(\*dbh) is missplaced. Removing it fixes the problem.

``` r
filter_pattern("unexpected '\\*'")
```

    ## # A tibble: 24 x 3
    ##    equation_allometry                      results messages               
    ##    <chr>                                     <dbl> <chr>                  
    ##  1 exp(-5.41227+(2.491767*(log(pi(*dbh))))      NA "<text>:1:32: unexpect~
    ##  2 exp(-5.644074+(2.5189*(log(pi(*dbh))))       NA "<text>:1:31: unexpect~
    ##  3 exp(-5.41227+(2.491767*(log(pi(*dbh))))      NA "<text>:1:32: unexpect~
    ##  4 exp(-5.41227+(2.491767*(log(pi(*dbh))))      NA "<text>:1:32: unexpect~
    ##  5 exp(-5.41227+(2.491767*(log(pi(*dbh))))      NA "<text>:1:32: unexpect~
    ##  6 exp(-5.41227+(2.491767*(log(pi(*dbh))))      NA "<text>:1:32: unexpect~
    ##  7 exp(-5.41227+(2.491767*(log(pi(*dbh))))      NA "<text>:1:32: unexpect~
    ##  8 exp(-5.41227+(2.491767*(log(pi(*dbh))))      NA "<text>:1:32: unexpect~
    ##  9 exp(-5.41227+(2.491767*(log(pi(*dbh))))      NA "<text>:1:32: unexpect~
    ## 10 exp(-5.41227+(2.491767*(log(pi(*dbh))))      NA "<text>:1:32: unexpect~
    ## # ... with 14 more rows

``` r
fix_problem("unexpected '\\*'", "pi\\(\\*dbh", "pi * dbh")
```

    ## # A tibble: 24 x 3
    ##    equation_allometry                      valid                    result
    ##    <chr>                                   <chr>                     <dbl>
    ##  1 exp(-5.41227+(2.491767*(log(pi(*dbh)))) exp(-5.41227+(2.491767*~   24.0
    ##  2 exp(-5.644074+(2.5189*(log(pi(*dbh))))  exp(-5.644074+(2.5189*(~   20.9
    ##  3 exp(-5.41227+(2.491767*(log(pi(*dbh)))) exp(-5.41227+(2.491767*~   24.0
    ##  4 exp(-5.41227+(2.491767*(log(pi(*dbh)))) exp(-5.41227+(2.491767*~   24.0
    ##  5 exp(-5.41227+(2.491767*(log(pi(*dbh)))) exp(-5.41227+(2.491767*~   24.0
    ##  6 exp(-5.41227+(2.491767*(log(pi(*dbh)))) exp(-5.41227+(2.491767*~   24.0
    ##  7 exp(-5.41227+(2.491767*(log(pi(*dbh)))) exp(-5.41227+(2.491767*~   24.0
    ##  8 exp(-5.41227+(2.491767*(log(pi(*dbh)))) exp(-5.41227+(2.491767*~   24.0
    ##  9 exp(-5.41227+(2.491767*(log(pi(*dbh)))) exp(-5.41227+(2.491767*~   24.0
    ## 10 exp(-5.41227+(2.491767*(log(pi(*dbh)))) exp(-5.41227+(2.491767*~   24.0
    ## # ... with 14 more rows

Erika, althought I pointed to some problems and suggested solutiouns, I
didn’t fix the problems permanently. I assume you want to check my
approach and fix the issues yourself. Let me know if you have questions
or need help.
