context("master")

test_that("All master() sites match sites in `sites_info` (#79)", {
  master_sites <- sort(unique(master()$site))
  all_sites <- sort(unique(allodb::sites_info$site))
  # Sites in master that don't match sites in `sites_info`
  expect_length(setdiff(master_sites, similar_sites), 0L)
})

test_that("master outputs lowercase values of site (#79)", {
  out <- unique(master()$site)
  expect_equal(out, tolower(out))
})

test_that("master doesn't duplicate names", {
  names_dot_y <- any(grepl(".*\\.y", names(master())))
  expect_false(names_dot_y)

  names_dot_x <- any(grepl(".*\\.x", names(master())))
  expect_false(names_dot_x)
})

test_that("master outputs the expected object (allodb#78)", {
  expect_is(master(), "tbl")
  expect_length(master(), 43)
})

test_that("`equations` and `sitespecies` have no redundant columns (#78)", {
  expect_equal(
    intersect(names(equations), names(sitespecies)),
    "equation_id"
  )
})

test_that("master outputs no missing `equation_id`", {
  expect_false(any(is.na(allodb::master()$equation_id)))
})
