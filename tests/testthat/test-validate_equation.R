test_that("with valid equations returns `equations` argument invisibly", {
  valid <- c("dbh + 1", "h + 1")
  no_error <- NA
  out <- expect_error(validate_equations(valid), no_error)
  expect_equal(out, valid)
})

test_that("with invalid equations throwns an error", {
  invalid <- c("dbh + 1", "h + bad")
  expect_error(validate_equations(invalid), "bad.*not found")
})
