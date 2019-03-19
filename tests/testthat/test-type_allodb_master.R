context("type_allodb_master")

master <- master()

test_that("has same names as `master` (#62)", {
  skip("FIXME: type_allodb_master() has unexpected names (#62)")

  diff_master_expected <- setdiff(names(master), names(type_allodb_master()))
  expect_length(diff_master_expected, 0)

  diff_expected_master <- setdiff(names(type_allodb_master()), names(master))
  expect_length(diff_expected_master, 0)
})



context("set_type")

test_that("set_type creates objects of the expected class 'allodb'", {
  wsg <- allodb::wsg
  out <- set_type(wsg)
  expect_is(out, "allodb")
  expect_true(all(unlist(lapply(wsg, is.character))))
  expect_false(all(unlist(lapply(out, is.character))))
})

test_that("set_type sets numeric variables of correct type (#46)", {
  library(dplyr)
  library(purrr)

  all_doubles <- set_type(equations) %>%
    select(dbh_min_cm, dbh_max_cm) %>%
    map_lgl(is.double) %>%
    all()

  expect_true(all_doubles)
  expect_is(set_type(wsg)$wsg, "numeric")
})
