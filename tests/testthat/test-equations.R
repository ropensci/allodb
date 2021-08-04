test_that("all equations are lowercase", {
  expect_equal(
    allodb::equations$equation_allometry,
    tolower(allodb::equations$equation_allometry)
  )
})

test_that("all equations are valid", {
  no_error <- NA
  expect_error(validate_equations(equations$equation_allometry), no_error)
})
