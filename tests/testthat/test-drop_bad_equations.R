context("drop_bad_equations")

equations <- drop_bad_equations(master())

test_that("drops bad equations", {
  id <- equations$equation_id
  expect_false(any(id %in% bad_eqn_id))
})

test_that("errs with informative message", {
  eqn <- dplyr::rename(equations, bad_id = equation_id)
  expect_error(drop_bad_equations(eqn), "must have.*equation_id")
})

context("pick_specificity")

test_that("errs with informative message", {
  bad_name_eqn <- dplyr::rename(equations, bad = allometry_specificity)
  expect_error(
    pick_specificity(bad_name_eqn, "species"),
    "Ensure.*allometry_specificity"
  )

  expect_error(
    pick_specificity(equations, "bad"),
    "`specificity` must be one of"
  )

  expect_error(
    pick_specificity(equations),
    "is missing"
  )
})

test_that("picks correct specificity with vectors of lengh 1 and 2", {
  out <- pick_specificity(equations, "species")
  expect_equal(unique(out$allometry_specificity), "species")

  out <- pick_specificity(equations, "Species")
  expect_equal(unique(out$allometry_specificity), "species")

  out <- pick_specificity(equations, c("Species", "Genus"))
  expect_equal(unique(out$allometry_specificity), c("species", "genus"))
})



context("add_sp")

test_that("adds column sp", {
  out <- add_sp(equations)
  expect_named(out, c(names(equations), "sp"))
})



context("add_equation")

test_that("with census table adds dbh", {
  eqn_sp <- add_sp(equations)
  out <- add_equation(scbi_tree1, eqn_sp)
  expect_named(out, c(names(scbi_tree1), "equation_allometry"))
})


context("pick_equations")

eqn <- pick_equations(allodb::scbi_species, "species")

