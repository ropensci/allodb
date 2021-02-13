library(allodb)

test_that("illustrate_allodb() returns a ggplot object", {
  expect_is(illustrate_allodb(genus = "Quercus",
                              coords = c(-78, 40)),
            "ggplot")
})

test_that("illustrate_allodb() accepts changes in the equation table used",
          {
            g <- illustrate_allodb(genus = "Quercus",
                                   coords = c(-78, 40))
            g2 <- illustrate_allodb(
              genus = "Quercus",
              coords = c(-78, 40),
              new_eqtable = new_equations(
                new_allometry = "0.12 * dbh ^ 2.5",
                new_taxa = "Quercus",
                new_coords = c(-80, 40),
                new_minDBH = 5,
                new_maxDBH = 40,
                new_sampleSize = 500
              )
            )
            expect_is(g, "ggplot")
            expect_is(g2, "ggplot")
            expect_true(any(grepl("new", g2$data$equation_id)))
          })

test_that("illustrate_allodb() accepts changes in the equation table used",
          {
            g <- illustrate_allodb(
              genus = "Quercus",
              coords = c(-78, 40),
              new_eqtable = new_equations(subset_taxa = "Quercus")
            )
            g2 <- illustrate_allodb(
              genus = "Quercus",
              coords = c(-78, 40),
              new_eqtable = new_equations(
                new_allometry = "0.12 * dbh ^ 2.5",
                new_taxa = "Quercus",
                new_coords = c(-80, 40),
                new_minDBH = 5,
                new_maxDBH = 40,
                new_sampleSize = 500
              )
            )
            expect_is(g, "ggplot")
            expect_is(g2, "ggplot")
            expect_true(any(grepl("new", g2$data$equation_id)))
          })

test_that("The top neq equations are displayed", {
  g <-
    illustrate_allodb(genus = "Quercus",
                      coords = c(-78, 40),
                      neq = 15)
  tab <- data.frame(table(equation_id = g$data$equation_id))
  tab <- tab[order(tab$Freq, decreasing = TRUE), ]
  topfreq <- tab$equation_id[1:15]
  legeq <-
    vapply(strsplit(levels(g$data$equation), " - "), function(x)
      x[1], FUN.VALUE = "x")

  expect_is(g, "ggplot")
  expect_true(all(topfreq %in% legeq))
})
