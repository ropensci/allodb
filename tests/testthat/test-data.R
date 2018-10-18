context("test-data.R")

# # UPDATING EXPORTED DATA AND REGRESSION TESTS:
# use_updated_data()

# * Update test references: Temporarily change default `update = T`
expect_output <- function(object, file, update = FALSE) {
  expect_known_output(object, file, update = update, print = TRUE)
}



test_that("Exported datasets match known output", {
  expect_output(
    as.data.frame(allodb::equations, stringsAsFactors = FALSE),
    "ref-equations"
  )
  expect_output(
    as.data.frame(allodb::equations_metadata, stringsAsFactors = FALSE),
    "ref-equations_metadata"
  )

  expect_output(
    as.data.frame(allodb::missing_values_metadata, stringsAsFactors = FALSE),
    "ref-missing_values_metadata"
  )

  expect_output(
    as.data.frame(allodb::references_metadata, stringsAsFactors = FALSE),
    "ref-references_metadata"
  )

  expect_output(
    as.data.frame(allodb::sitespecies, stringsAsFactors = FALSE),
    "ref-sitespecies"
  )
  expect_output(
    as.data.frame(allodb::sitespecies_metadata, stringsAsFactors = FALSE),
    "ref-sitespecies_metadata"
  )

  expect_output(
    as.data.frame(allodb::sites_info, stringsAsFactors = FALSE),
    "ref-sites_info"
  )

  expect_output(
    as.data.frame(allodb::wsg, stringsAsFactors = FALSE),
    "ref-wsg"
  )
  expect_output(
    as.data.frame(allodb::wsg_metadata, stringsAsFactors = FALSE),
    "ref-wsg_metadata"
  )
})
