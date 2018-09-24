context("type_allodb_master")

test_that("reads cleanly: Throws no warning when reading allodb_master.csv", {
  expect_warning(
    readr::read_csv(
      here::here("data-raw/allodb_master.csv"), col_type = type_allodb_master()
    ), NA
  )
})

test_that("has same names as `master`", {
  master <- readr::read_csv(here::here("data-raw/allodb_master.csv"))
  expect_length(setdiff(names(master), names(type_allodb_master())), 0)
  expect_length(setdiff(names(type_allodb_master()), names(master)), 0)
})
