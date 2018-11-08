context("bmss_default_eqn")

test_that("outputs the expected data structure", {
  allodb_eqn <- master() %>%
    drop_bad_equations() %>%
    pick_equations("species")

  out <- bmss_default_eqn(allodb_eqn)
  expect_named(out, names(bmss::toy_default_eqn))
})
