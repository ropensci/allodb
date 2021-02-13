library(allodb)

test_that("weight_allom returns a vector of the same length as the equation table.",
          {
            newtab <- new_equations(subset_taxa = "Quercus")
            weight_test <- weight_allom(
              genus = "Quercus",
              species = "alba",
              coords = c(-78, 40),
              new_eqtable = newtab
            )
            expect_type(weight_test, "double")
            expect_equal(length(weight_test), nrow(newtab))
            expect_true(all(names(weight_test) %in% newtab$equation_id))
          })
