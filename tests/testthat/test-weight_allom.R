context("Test the weigth_allom() function")
library(allodb)

test_that("weight_allom returns a vector of the same length as the equation table.", {
  newtab <- new_equations(subset_taxa = "Quercus")
  weight_test <- weight_allom(genus = "Quercus",
                              species = "alba",
                              coords = c(-78, 40),
                              new_eqtable = newtab)
  expect_is(weight_test, "numeric")
  expect_equal(length(weight_test), nrow(newtab))
  expect_true(all(names(weight_test) %in% newtab$equation_id))
})