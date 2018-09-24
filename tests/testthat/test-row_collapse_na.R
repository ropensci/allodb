context("testrow_collapse_na")

library(tibble)

test_that("collapses values of x that match y", {
  x <- c(1, "b", NA, "a", "b")
  y <- c("a", "b")
  collapse = "; "
  out <- collapse_match(x, y, collapse)
  expect_equal(out, "a; b")

  dfm1 <- tibble::tibble(A = 1, B = "b", C = NA, D = "a", E = "b")
  dfm2 <- tibble::tibble(A = "a", B = 1, C = 1, D = 1, E = "a")
  dfm3 <- tibble::tibble(A = "b", B = 1, C = 1, D = 1, E = "a")
  dfm <- rbind(dfm1, dfm2, dfm3)
  collapsed <- row_collapse_match(dfm, c("a", "b"), "; ")
  expect_equal(unname(collapsed), c("a; b", "a", "a; b"))

  # TODO: What's missing now is to add column name to output.
  # So that output is, for exampe for df1: "B: b; D: a" instead of "a; b"
})








# test_that("collapses values of a row if values match a string passed to `na`", {
#   dfm <- tibble(D = TRUE, C = 1, B = "b", A = NA)
#   nas <- c(NA, "b")
#   expect <- "A: NA; B: b"
#   expect_equal(row_collapse_na(dfm, na), expect)
# })
