# These tests characterize odd behaviour we need to discuss and maybe FIXME

test_that("w/ `NULL` `new_taxa`, `new_allometry`, and `new_coords, outputs
          identical to `new_equations()` -- with all defaults", {


  # Avoid unimportant differences in attributes
  mini_attr <- function(data) {
    mini <- names(attributes(data.frame(x = 1)))
    full <- names(attributes(data))
    extra <- setdiff(full, mini)

    for (i in seq_along(extra)) {
      attr(data, extra[[i]]) <- NULL
    }

    data
  }

  out <- new_equations(
    new_taxa = NULL,
    new_allometry = NULL,
    new_coords = NULL,
    new_min_dbh = 5,
    new_max_dbh = 50,
    new_sample_size = 50
  )

  expect_equal(mini_attr(out), mini_attr(new_equations()))
})

test_that("w/ all defaults, it's insensitive to `new_min_dbh`, `new_max_dbh`,
          and `new_sample_size`", {
  expect_equal(
    new_equations(new_min_dbh = 111, new_max_dbh = 111, new_sample_size = 111),
    new_equations(new_min_dbh = 999, new_max_dbh = 999, new_sample_size = 999)
  )
})

test_that("w/ non-numeric values passed to new_min_dbh, new_max_dbh,
          new_sample_size it throws no error", {
  # The body of `new_equations()` includes an error that seems to not work
  none <- NA
  expect_error(new_equations(new_min_dbh = "a"), none)
  expect_error(new_equations(new_max_dbh = "a"), none)
  expect_error(new_equations(new_sample_size = "a"), none)
})

test_that("outputs a dataframe of unstable structure", {
  # When the output of a function is unstable, it's hard to program with it.
  # Best is to ensure the output has always the same number of columns (unless
  # it's a function which goal is to change the number of columns, e.g.
  # `subset()`).
  out1 <- new_equations(
    new_taxa = "Faga",
    new_allometry = "exp(-2+log(dbh)*2.5)",
    new_coords = c(-0.07, 46.11),
    new_min_dbh = 5,
    new_max_dbh = 50,
    new_sample_size = 50
  )

  out2 <- new_equations(
    new_min_dbh = 5,
    new_max_dbh = 50,
    new_sample_size = 50
  )

  expect_false(identical(ncol(out1), ncol(out2)))
})

test_that("with bad `new_unit_dbh` throws no error", {
  # Arguments interact with each other. This error does not work when
  # new_equations() is called with defaults, but does work when it's passed
  # some values

  # Unexpected: Error doesn't throw
  FIXME_none <- NA
  expect_error(new_equations(new_unit_dbh = "bad "), FIXME_none)

  # Eexpected: Error throws
  expect_snapshot_error(
    new_equations(
      new_unit_dbh = "bad ",
      new_taxa = "Faga",
      new_allometry = "exp(-2+log(dbh)*2.5)",
      new_coords = c(-0.07, 46.11),
      new_min_dbh = 5,
      new_max_dbh = 50,
      new_sample_size = 50
    )
  )
})

test_that("with bad `new_unit_output` throws no error", {
  # Unexpected: Error doesn't throw
  FIXME_none <- NA
  expect_error(new_equations(new_unit_output = "bad "), FIXME_none)

  # Eexpected: Error throws
  expect_snapshot_error(
    new_equations(
      new_unit_output = "bad ",
      new_taxa = "Faga",
      new_allometry = "exp(-2+log(dbh)*2.5)",
      new_coords = c(-0.07, 46.11),
      new_min_dbh = 5,
      new_max_dbh = 50,
      new_sample_size = 50
    )
  )
})

test_that("height can be anything", {
  bad <- "BAD"
  none <- NA
  expect_error(
    new_equations(new_output_var = "Height", new_unit_output = bad),
    none
  )
})
