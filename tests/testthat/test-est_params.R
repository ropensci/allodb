context("Test the est_params() function")
library(allodb)

test_that("est_params() returns a dataframe with all combinations of species x locations",
          {
            test_tab <- allodb::scbi_stem1[1:50, ]
            test_tab$site <- sample(2, 50, TRUE)
            sites <-
              data.frame(site = 1:2,
                         long = c(-78,-85),
                         lat = c(40, 45))
            test_tab <- merge(test_tab, sites, by = "site")
            ncombi <- nrow(unique(test_tab[, c("genus", "species", "site")]))
            testall <- est_params(
              genus = test_tab$genus,
              species = test_tab$species,
              coords = test_tab[, c("long", "lat")]
            )
            expect_is(testall, "data.frame")
            expect_equal(nrow(testall), ncombi)
            expect_equal(ncol(testall), 7)
          })

test_that("est_params can be used with a new equation table", {
  expect_is(est_params(
    genus = c("Quercus", "Fagus"),
    coords = c(-78, 40),
    new_eqtable = new_equations(subset_taxa = "Quercus")
  ),
  "data.frame")
})
