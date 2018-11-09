context("find_duplicated_rowid")

test_that("errs with informative message", {
  renamed_eqn <- dplyr::rename(default_eqn, spp = sp)
  expect_error(find_duplicated_rowid(renamed_eqn), "Ensure your data")
})
