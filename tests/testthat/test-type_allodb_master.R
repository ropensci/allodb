context("type_allodb_master")

master <- master()

test_that("has same names as `master` (#62)", {
  skip("FIXME: type_allodb_master() has unexpected names (#62)")

  diff_master_expected <- setdiff(names(master), names(type_allodb_master()))
  expect_length(diff_master_expected, 0)

  diff_expected_master <- setdiff(names(type_allodb_master()), names(master))
  expect_length(diff_expected_master, 0)
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
