library(allodb)

test_that("illustrate_allodb() returns a ggplot object", {
  expect_s3_class(illustrate_allodb(genus = "Quercus",
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
                new_min_dbh = 5,
                new_max_dbh = 40,
                new_sample_size = 500
              )
            )
            expect_s3_class(g, "ggplot")
            expect_s3_class(g2, "ggplot")
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
                new_min_dbh = 5,
                new_max_dbh = 40,
                new_sample_size = 500
              )
            )
            expect_s3_class(g, "ggplot")
            expect_s3_class(g2, "ggplot")
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

  expect_s3_class(g, "ggplot")
  expect_true(all(topfreq %in% legeq))
})

test_that("The option logxy = TRUE displays graphs with log scale", {
  g <- illustrate_allodb(genus = "Quercus",
                    coords = c(-78, 40),
                    logxy = TRUE)
  expect_s3_class(g, "ggplot")
})
