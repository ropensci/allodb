context("Test all functionalities of the get_biomass function")
library(allodb)

test_that("get_biomass works with genus and species information and provides reasonable outputs",
          {
            expect_equal(get_biomass(
              dbh = 20,
              genus = "Quercus",
              species = "alba",
              coords = c(-78, 40)
            ),
            240,
            tolerance = 50)
            expect_equal(get_biomass(
              dbh = 20,
              genus = "Quercus",
              coords = c(-78, 40)
            ),
            240,
            tolerance = 50)
          })

test_that("weighting parameters can be easily changed without changing results dramatically",
          {
            expect_equal(
              get_biomass(
                dbh = 20,
                genus = "Quercus",
                coords = c(-78, 40),
                wna = 0.01,
                w95 = 1000
              ),
              240,
              tolerance = 50
            )
          })

test_that("get_biomass returns zero when dbh = 0 and NA when dbh = NA or dbh < 0", {
  expect_equal(get_biomass(
    dbh = 0,
    genus = "Quercus",
    coords = c(-78, 40)
  ), 0)
  expect_equal(get_biomass(
    dbh = NA,
    genus = "Quercus",
    coords = c(-78, 40)
  ),
  NA_integer_)
  expect_equal(get_biomass(
    dbh = -10,
    genus = "Quercus",
    coords = c(-78, 40)
  ),
  NA_integer_)
})

test_that("get_biomass accepts new equation table", {
  expect_equal(
    get_biomass(
      dbh = 20,
      genus = "Quercus",
      coords = c(-78, 40),
      new_eqtable = new_equations(subset_taxa = "Quercus")
    ),
    240,
    tolerance = 50
  )
})

test_that("get_biomass can be used for several individuals and sites", {
  inds_1site <- get_biomass(
    dbh = c(20, 40, 10),
    genus = c("Quercus", "Acer", "Fagus"),
    coords = c(-78, 40)
  )
  inds_2site <- get_biomass(
    dbh = c(20, 40, 10),
    genus = c("Quercus", "Acer", "Fagus"),
    coords = rbind(c(-78, 40),
                   c(-78, 40),
                   c(-85, 45))
  )
  expect_equal(inds_1site, c(240, 1500, 50), tolerance = 50)
  expect_equal(inds_2site, c(240, 1500, 50), tolerance = 50)
})

test_that("get_biomass gives stable results when run several times with the same inputs",
          {
            run_1 <-
              get_biomass(dbh = 20,
                          genus = "Quercus",
                          coords = c(-78, 40))
            run_2 <-
              get_biomass(dbh = 20,
                          genus = "Quercus",
                          coords = c(-78, 40))
            expect_equal(run_1, run_2)
          })

test_that("biomass estimates for one individual do not depend on other measurements",
          {
            agb_alone <-
              get_biomass(dbh = 20,
                          genus = "Quercus",
                          coords = c(-78, 40))
            agb_withfagus <-
              get_biomass(
                dbh = c(20, 10),
                genus = c("Quercus", "Fagus"),
                coords = c(-78, 40)
              )[1]
            expect_equal(agb_alone, agb_withfagus)
          })

test_that("get_biomass gives error message when inputs are not the same length",
          {
            expect_error(get_biomass(
              dbh = c(20, 10, 30),
              genus = c("Quercus", "Fagus"),
              coords = c(-78, 40)
            ))
          })
