library(allodb)

test_that("resample_agb returns a dataframe of size 1e6 x 3", {
  res_test <-
    resample_agb(genus = "Quercus",
                 species = "alba",
                 coords = c(-78, 40))
  expect_s3_class(res_test, "data.frame")
  expect_equal(nrow(res_test), 1e6, tolerance = 1e2)
  expect_equal(ncol(res_test), 3)
  expect_type(res_test$equation_id, "character")
  expect_type(res_test$dbh, "double")
  expect_type(res_test$agb, "double")
})

test_that(
  "resample_agb returns an error message when more than one taxon/location are used at once",
  {
    expect_error(resample_agb(
      genus = c("Fagus", "Quercus"),
      coords = c(-78, 40)
    ))
    expect_error(resample_agb(genus = c("Fagus"), coords = rbind(c(-78, 40), c(-85, 45))))
  }
)

test_that("resample_agb can be used with a new equation table", {
  expect_s3_class(
    resample_agb(
      genus = "Quercus",
      coords = c(-78, 40),
      new_eqtable = new_equations(subset_taxa = "Quercus")
    ),
    "data.frame"
  )
})
