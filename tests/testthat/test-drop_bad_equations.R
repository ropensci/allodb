context("drop_bad_equations")

test_that("drops bad equaitons", {
  id <- drop_bad_equations(master())$equation_id
  expect_false(any(id %in% bad_eqn_id))
})
