context("test-data.R")

test_that("Exported datasets match known output", {
  expect_known_output(
    as.data.frame(allodb::equations, stringsAsFactors = FALSE),
    "ref-equations",
    print = TRUE,
    update = FALSE
  )
  expect_known_output(
    as.data.frame(allodb::equations_metadata, stringsAsFactors = FALSE),
    "ref-equations_metadata",
    print = TRUE,
    update = FALSE
  )

  expect_known_output(
    as.data.frame(allodb::missing_values_metadata, stringsAsFactors = FALSE),
    "ref-missing_values_metadata",
    print = TRUE,
    update = FALSE
  )

  expect_known_output(
    as.data.frame(allodb::references_metadata, stringsAsFactors = FALSE),
    "ref-references_metadata",
    print = TRUE,
    update = FALSE
  )

  expect_known_output(
    as.data.frame(allodb::sitespecies, stringsAsFactors = FALSE),
    "ref-sitespecies",
    print = TRUE,
    update = FALSE
  )
  expect_known_output(
    as.data.frame(allodb::sitespecies_metadata, stringsAsFactors = FALSE),
    "ref-sitespecies_metadata",
    print = TRUE,
    update = FALSE
  )

  expect_known_output(
    as.data.frame(allodb::sites_info, stringsAsFactors = FALSE),
    "ref-sites_info",
    print = TRUE,
    update = FALSE
  )

  expect_known_output(
    as.data.frame(allodb::wsg, stringsAsFactors = FALSE),
    "ref-wsg",
    print = TRUE,
    update = FALSE
  )
  expect_known_output(
    as.data.frame(allodb::wsg_metadata, stringsAsFactors = FALSE),
    "ref-wsg_metadata",
    print = TRUE,
    update = FALSE
  )
})
