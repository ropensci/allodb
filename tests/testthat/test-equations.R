test_that("all equations are lowercase", {
  expect_equal(
    allodb::equations$equation_allometry,
    tolower(allodb::equations$equation_allometry)
  )
})
