context("evaluate_eqn.R")

library(allodb)
library(purrr)
library(dplyr)

evaluate_eqn <- function() {
  eqn <- allodb::equations$equation_allometry
  eval_eqn <- purrr::safely(
    function(text, envir) eval(parse(text = text), envir = envir)
  )
  out <- purrr::map(eqn, ~eval_eqn(.x, list(dbh = 10)))

  results <- purrr::map(out, "result") %>% modify_if(is.null, ~NA_real_)
  messages <- out %>%
    purrr::map("error") %>%
    purrr::map("message") %>%
    purrr::modify_if(is.null, ~NA_character_)
  res <- tidyr::unnest(tibble::tibble(equation_allometry = eqn, results, messages))
  res
}

test_that("the dataframe used to test for valid code is as expected.", {
  expect_is(evaluate_eqn(), "data.frame")
  expect_named(evaluate_eqn(), c("equation_allometry", "results", "messages"))
})

test_that("all equations can be evaluated (i.e. evaluation errors = 0)", {
  n_errors <- sum(is.na(evaluate_eqn()$messages))
  expect_equal(n_errors, 0)
})

test_that("all equations independent of `dba` can be evaluated)", {
  not_dba <- filter(evaluate_eqn(), !grepl("object 'dba' not found", messages))
  n_errors <- sum(is.na(not_dba))
  expect_equal(n_errors, 0)
})
