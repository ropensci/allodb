context("as_default_eqn")

test_that("outputs the expected data structure", {
  out <- as_default_eqn(allodb::master())
  expect_named(out, c("equation_id", names(bmss::toy_default_eqn)))
})



context("census_species")

test_that("outputs the expected data structure", {
  out <- census_species(allodb::scbi_tree1, allodb::scbi_species, "scbi")
  expect_named(out, c("rowid", names(bmss::user_data)))
})



context("find_duplicated_eqn")

test_that("errs with informative message", {
  new_eqn <- dplyr::rename(default_eqn, spp = sp)
  expect_error(find_duplicated_eqn(new_eqn), "Ensure your data")
})
