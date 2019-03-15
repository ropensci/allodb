context("master")

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
