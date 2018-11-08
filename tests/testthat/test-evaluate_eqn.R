context("evaluate_eqn.R")

library(purrr)
library(dplyr)

test_that("bad equations haven't changed", {
  expect_known_output(
    .bad_eqn_id, "ref-bad_eqn_id",
    print = TRUE, overwrite = FALSE
  )
})

test_that("FIXME: Problems in equations (#54)", {
  error_msg <- some_error(master(), eval_eqn) %>%
    discard(is.null) %>%
    map_chr("message") %>%
    unique() %>%
    glue_collapse(sep = "\n")
  warn(glue("Problems to fix:\n {error_msg}"))
})
