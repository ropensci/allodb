context("test-data.R")

test_that("Exported datasets match known output", {
  expect_known_output(
    allodb::equations, "ref-equations",
    print = TRUE, update = FALSE
  )
  expect_known_output(
    allodb::equations_metadata, "ref-equations_metadata",
    print = TRUE, update = FALSE
  )

  expect_known_output(
    allodb::missing_values_metadata, "ref-missing_values_metadata",
    print = TRUE, update = FALSE
  )

  expect_known_output(
    allodb::references_metadata, "ref-references_metadata",
    print = TRUE, update = FALSE
  )

  expect_known_output(
    allodb::sitespecies, "ref-sitespecies",
    print = TRUE, update = FALSE
  )
  expect_known_output(
    allodb::sitespecies_metadata, "ref-sitespecies_metadata",
    print = TRUE, update = FALSE
  )

  expect_known_output(
    allodb::sites_info, "ref-sites_info",
    print = TRUE, update = FALSE
  )

  expect_known_output(
    allodb::wsg, "ref-wsg",
    print = TRUE, update = FALSE
  )
  expect_known_output(
    allodb::wsg_metadata, "ref-wsg_metadata",
    print = TRUE, update = FALSE
  )
})
