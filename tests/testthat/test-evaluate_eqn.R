context("evaluate_eqn.R")

library(purrr)
library(dplyr)
library(tidyr)
library(glue)

eval_eqn <- function(text, envir) {
  eval(parse(text = text), envir = list(dbh = 10))
}

eqn <- allodb::equations$equation_allometry
contents <- eqn %>%
  map(safely(eval_eqn)) %>%
  transpose()

ok <- map_lgl(contents$error, is.null)

invalid <- tibble(
  equation_allometry = eqn[!ok],
  messages = map_chr(contents$error[!ok], "message")
)

test_that("all equations depend on dbh (i.e. evaluation errors = 0)", {
  expect_equal(nrow(invalid), 0)
  problems <- glue_collapse(unique(invalid$messages), sep = '\n')
  warning(glue("Problems to fix:\n {problems}"))
})
