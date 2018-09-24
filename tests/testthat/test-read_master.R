context("read_master")

path <- here::here("data-raw/allodb_master.csv")
master <- read_master(path)

test_that("reads cleanly: Throws no warning when reading allodb_master.csv", {
  expect_warning(master, regexp = NA)
})



context("type_allodb_master")

test_that("has same names as `master`", {
  expect_length(setdiff(names(master), names(type_allodb_master())), 0)
  expect_length(setdiff(names(type_allodb_master()), names(master)), 0)
})
