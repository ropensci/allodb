context("evaluate_eqn.R")

library(purrr)
library(dplyr)

eval_eqn <- function(text, envir) {
  eval(parse(text = text), envir = list(dbh = 10))
}

eqn <- allodb::equations$equation_allometry
contents <- suppressWarnings({
  eqn %>%
    map(safely(eval_eqn)) %>%
    transpose()
})

bad_eqn <- !map_lgl(contents$error, is.null)
bad_eqn_id <- allodb::equations %>%
  filter(bad_eqn) %>%
  pull(equation_id)

test_that("bad equations haven't changed", {
  expect_known_output(
    bad_eqn_id, "ref-bad_eqn_id", print = TRUE, overwrite = FALSE
  )
  # Save bad equations to filter them out from trial data
  saveRDS(bad_eqn_id, test_path("bad_eqn_id.rds"))
})

test_that("all except known bad equations can be evaluated", {
  good_equations <- eqn[!bad_eqn]
  suppressWarnings(
    expect_error(out <- map_dbl(good_equations, eval_eqn), NA)
  )
  expect_is(out, "numeric")
})

invalid <- tibble::tibble(
  equation_allometry = eqn[bad_eqn],
  messages = map_chr(contents$error[bad_eqn], "message")
)

test_that("all equations depend on dbh (i.e. evaluation errors = 0) (#54)", {
  skip("FIXME: Problematic equations remain (#54)")
  expect_equal(nrow(invalid), 0)
})

test_that("FIXME: Problems in equations (#54)", {
  problems <- glue::glue_collapse(unique(invalid$messages), sep = '\n')
  rlang::warn(glue::glue("Problems to fix:\n {problems}"))
})
