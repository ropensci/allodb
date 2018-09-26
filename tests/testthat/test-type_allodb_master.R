context("type_allodb_master")

master <- read_csv_as_chr(here::here("data-raw/allodb_master.csv"))

test_that("has same names as `master`", {
  expect_length(setdiff(names(master), names(type_allodb_master())), 0)
  expect_length(setdiff(names(type_allodb_master()), names(master)), 0)
})




context("type_allodb_master")

test_that("creates objects of the expected class 'allodb'", {
  wsg <- allodb::wsg
  out <- as_allodb(wsg)
  expect_is(out, "allodb")
  expect_true(all(unlist(lapply(wsg, is.character))))
  expect_false(all(unlist(lapply(out, is.character))))
})


test_that("Numeric variables are of correct type (#46)", {
  library(dplyr)
  library(purrr)

  all_doubles <- as_allodb(equations) %>%
    select(dbh_min_cm, dbh_max_cm) %>%
    map_lgl(is.double) %>%
    all()

  expect_true(all_doubles)
  expect_is(as_allodb(wsg)$wsg, "numeric")
})
