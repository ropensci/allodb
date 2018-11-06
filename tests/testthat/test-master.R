context("master")

test_that("doesn't duplicate names", {
  names_dot_y <- any(grepl(".*\\.y", names(master())))
  expect_false(names_dot_y)

  names_dot_x <- any(grepl(".*\\.x", names(master())))
  expect_false(names_dot_x)
})
