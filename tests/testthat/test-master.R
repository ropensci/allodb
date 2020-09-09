context("master")

test_that("master_tidy() returns correct column types", {
  expect_false(
    identical(
      unique(purrr::map_chr(master_tidy(), typeof)),
      "character"
    )
  )
})

test_that(
  "master() sites match `sites_info$site` (#79),
  except 'any*' (fgeo.biomass#31)",
  {
    master_sites <- sort(unique(master()$site))
    all_sites <- sort(unique(allodb::sites_info$site))

    # Sites in master that don't match sites in `sites_info`
    missmatching_sites <- setdiff(master_sites, all_sites)
    expect_equal(
      missmatching_sites,
      sort(c("any-temperate-north america", "any-temperate-europe"))
    )
  }
)

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

test_that("master returns known output", {
  expect_known_output(
    tibble::as_tibble(master()), "ref-master",
    print = TRUE,
    update = FALSE
  )
})

context("master_tidy")

test_that("master_tidy returns no missing values in `dbh_*_cm`", {
  expect_false(any(is.na(master_tidy()$dbh_min_cm)))
  expect_false(any(is.na(master_tidy()$dbh_max_cm)))
})

test_that("master_tidy returns in `dbh_min_cm` some 0", {
  expect_true(any(master_tidy()$dbh_min_cm == 0))
})

test_that("master_tidy returns in `dbh_max_cm` some Inf", {
  expect_true(any(master_tidy()$dbh_max_cm == Inf))
})
