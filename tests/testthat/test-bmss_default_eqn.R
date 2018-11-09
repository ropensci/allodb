context("bmss_default_eqn")

test_that("outputs the expected data structure", {
  out <- bmss_default_eqn(allodb::master())
  expect_named(out, names(bmss::toy_default_eqn))
})



context("bmss_cns")

test_that("outputs the expected data structure", {
  out <- bmss_cns(allodb::scbi_tree1, allodb::scbi_species, "scbi")
  expect_named(out, c("rowid", names(bmss::user_data)))
})
