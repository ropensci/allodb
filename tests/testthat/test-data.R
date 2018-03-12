context("test-data.R")

test_that("Exported datasets match known output", {
  expect_known_output(allodb::equations, "ref-equations")
  expect_known_output(allodb::equations_metadata, "ref-equations_metadata")

  expect_known_output(
    allodb::missing_values_metadata, "ref-missing_values_metadata"
  )

  expect_known_output(allodb::references_metadata, "ref-references_metadata")

  expect_known_output(allodb::sitespecies_metadata, "ref-sitespecies_metadata")
  expect_known_output(allodb::sitespecies, "ref-sitespecies")

  expect_known_output(allodb::sites_info, "ref-sites_info")

  expect_known_output(allodb::wsg, "ref-wsg")
  expect_known_output(allodb::wsg_metadata, "ref-wsg_metadata")
})
