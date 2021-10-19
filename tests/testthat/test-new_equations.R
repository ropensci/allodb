test_that("new_equations() returns a dataframe with all
          necessary information", {
  tab <- new_equations()
  expect_s3_class(tab, "data.frame")
  expect_type(tab$equation_id, "character")
  expect_type(tab$equation_taxa, "character")
  expect_type(tab$equation_allometry, "character")
  expect_type(tab$independent_variable, "character")
  expect_type(tab$dependent_variable, "character")
  expect_type(tab$koppen, "character")
  expect_type(tab$dbh_min_cm, "double")
  expect_type(tab$dbh_max_cm, "double")
  expect_type(tab$sample_size, "double")
  expect_type(tab$dbh_units_original, "character")
  expect_type(tab$output_units_original, "character")
})

test_that("new_equations() can be subsetted by taxa", {
  subset_taxa <- new_equations(subset_taxa = c("Quercus", "Acer"))
  cols <- c(
    "equation_id",
    "equation_taxa",
    "equation_allometry",
    "independent_variable",
    "dependent_variable",
    "koppen",
    "dbh_min_cm",
    "dbh_max_cm",
    "sample_size",
    "dbh_units_original",
    "output_units_original"
  )
  expect_s3_class(subset_taxa, "data.frame")
  expect_true(all(cols %in% colnames(new_equations())))
  expect_true(all(grepl(
    "Quercus|Acer", subset_taxa$equation_taxa
  )))
})

test_that("new_equations() can be subsetted by climate", {
  subset_koppen <- new_equations(subset_climate = "Csb")
  cols <- c(
    "equation_id",
    "equation_taxa",
    "equation_allometry",
    "independent_variable",
    "dependent_variable",
    "koppen",
    "dbh_min_cm",
    "dbh_max_cm",
    "sample_size",
    "dbh_units_original",
    "output_units_original"
  )
  expect_s3_class(subset_koppen, "data.frame")
  expect_true(all(cols %in% colnames(subset_koppen)))
  expect_true(all(grepl("Csb", subset_koppen$koppen)))
})

test_that("new_equations() can be subsetted by geographic region", {
  subset_geo <- new_equations(subset_region = "Europe")
  cols <- c(
    "equation_id",
    "equation_taxa",
    "equation_allometry",
    "independent_variable",
    "dependent_variable",
    "koppen",
    "dbh_min_cm",
    "dbh_max_cm",
    "sample_size",
    "dbh_units_original",
    "output_units_original"
  )
  expect_s3_class(subset_geo, "data.frame")
  expect_true(all(cols %in% colnames(subset_geo)))
  expect_true(all(grepl("Europe", subset_geo$geographic_area)))
})

test_that("new_equations() can be subsetted by equation id", {
  ids <- c("13b352", "9c4cc9", "55476a", "74c518", "cde8d1")
  subset_id <- new_equations(subset_ids = ids)
  cols <- c(
    "equation_id",
    "equation_taxa",
    "equation_allometry",
    "independent_variable",
    "dependent_variable",
    "koppen",
    "dbh_min_cm",
    "dbh_max_cm",
    "sample_size",
    "dbh_units_original",
    "output_units_original"
  )
  expect_s3_class(subset_id, "data.frame")
  expect_true(all(cols %in% colnames(subset_id)))
  expect_true(all(subset_id$equation_id %in% ids))
})

test_that("new_equations() can be subsetted by type of output", {
  subset_h <- new_equations(subset_output = "Height")
  cols <- c(
    "equation_id",
    "equation_taxa",
    "equation_allometry",
    "independent_variable",
    "dependent_variable",
    "koppen",
    "dbh_min_cm",
    "dbh_max_cm",
    "sample_size",
    "dbh_units_original",
    "output_units_original"
  )
  expect_s3_class(subset_h, "data.frame")
  expect_true(all(cols %in% colnames(subset_h)))
  expect_true(all(grepl("Height", subset_h$dependent_variable)))
})

test_that(
  "equations can be added to the equation dataframe and then
  used in the get_biomass function",
  {
    all_eqtab <-
      new_equations(
        new_taxa = c("Quercus ilex", "Castanea sativa"),
        new_allometry = c("0.12 * dbh ^ 2.5", "0.15*dbh^2.7"),
        new_coords = c(4, 44),
        new_min_dbh = c(5, 10),
        new_max_dbh = c(35, 68),
        new_sample_size = c(143, 62)
      )
    new_eq <- subset(all_eqtab, grepl("new", equation_id))
    expect_s3_class(new_eq, "data.frame")
    expect_equal(nrow(new_eq), 2)

    agb1 <-
      get_biomass(
        dbh = 20,
        genus = "Quercus",
        coords = c(-78, 40),
        new_eqtable = all_eqtab
      )
    agb2 <-
      get_biomass(
        dbh = 20,
        genus = "Quercus",
        coords = c(-78, 40),
        new_eqtable = new_eq
      )
    expect_equal(agb1, 240, tolerance = 50)
    expect_equal(agb2, 240, tolerance = 50)
  }
)

test_that("equations cannot be added when the input format is not correct", {
  expect_error(
    new_equations(
      new_taxa = "Quercus ilex",
      new_allometry = "0.12 * dbh ^ 2.5",
      new_coords = c(4, 44),
      new_minDBH = c(5, 10),
      new_maxDBH = 35,
      new_sampleSize = 143
    )
  )
  expect_error(
    new_equations(
      new_taxa = "Quercus ilex",
      new_coords = c(4, 44),
      new_minDBH = 5,
      new_maxDBH = 35,
      new_sampleSize = 143
    )
  )
  expect_error(
    new_equations(
      new_taxa = "Quercus ilex",
      new_allometry = "agb = 0.12 * dbh ^ 2.5",
      new_coords = c(4, 44),
      new_minDBH = 5,
      new_maxDBH = 35,
      new_sampleSize = 143
    )
  )
  expect_error(
    new_equations(
      new_taxa = "Quercus ilex",
      new_allometry = "0.12 * dbh ^ 2.5*",
      new_coords = c(4, 44),
      new_minDBH = 5,
      new_maxDBH = 35,
      new_sampleSize = 143
    )
  )
  expect_error(
    new_equations(
      new_taxa = "Quercus ilex",
      new_allometry = "0.12 * dbh ^ 2.5",
      new_coords = c(4, 44),
      new_minDBH = 5,
      new_maxDBH = 35,
      new_sampleSize = "143"
    )
  )
  expect_error(
    new_equations(
      new_taxa = "Quercus ilex",
      new_allometry = "0.12 * dbh ^ 2.5",
      new_coords = 44,
      new_minDBH = 5,
      new_maxDBH = 35,
      new_sampleSize = 143
    )
  )
})

test_that("w/ `new_taxa` and `NULL` `new_allometry` errors gracefully", {
  new_taxa <- "Faga"
  expect_snapshot_error(
    new_equations(
      new_taxa = new_taxa,
      new_allometry = NULL,
      new_coords = c(-0.07, 46.11),
      new_min_dbh = 5,
      new_max_dbh = 50,
      new_sample_size = 50
    )
  )
})

# FIXME: The same applies for a bunch of other arguments, and testing each
# combination seems tedious. This suggests a problem in the design.
test_that("with `new_allometry` and NULL `new_taxa` errors gracefully", {
  expect_snapshot_error(new_equations(new_allometry = "a", new_taxa = NULL))
})

test_that("with a `new_coords` 'matrix' 1x2 works", {
  nrow <- 1
  ncol <- 2
  a_matrix <- matrix(c(-0.07, 46.11), ncol = ncol)
  no_error <- NA
  expect_error(
    new_equations(
      new_taxa = "Faga",
      new_allometry = "exp(-2+log(dbh)*2.5)",
      new_coords = a_matrix,
      new_min_dbh = 5,
      new_max_dbh = 50,
      new_sample_size = 50
    ),
    no_error
  )
})

test_that("with a `new_coords` 'matrix' 2x1 errors gracefully", {
  nrow <- 2
  ncol <- 1
  a_matrix <- matrix(c(-0.07, 46.11), ncol = ncol)
  expect_snapshot_error(
    new_equations(
      new_taxa = "Faga",
      new_allometry = "exp(-2+log(dbh)*2.5)",
      new_coords = a_matrix,
      new_min_dbh = 5,
      new_max_dbh = 50,
      new_sample_size = 50
    )
  )
})

test_that("with arguments of different lenght errors gracefully", {
  too_long <- c("exp(-2+log(dbh)*2.5)", "exp(-2+log(dbh)*2.5)")
  expect_snapshot_error(
    new_equations(
      new_taxa = "Faga",
      new_allometry = too_long,
      new_coords = c(-0.07, 46.11),
      new_min_dbh = 5,
      new_max_dbh = 50,
      new_sample_size = 50
    )
  )

  too_long <- c(5, 5)
  expect_snapshot_error(
    new_equations(
      new_taxa = "Faga",
      new_allometry = "exp(-2+log(dbh)*2.5)",
      new_coords = c(-0.07, 46.11),
      new_min_dbh = too_long,
      new_max_dbh = 50,
      new_sample_size = 50
    )
  )

  too_long <- c(50, 50)
  expect_snapshot_error(
    new_equations(
      new_taxa = "Faga",
      new_allometry = "exp(-2+log(dbh)*2.5)",
      new_coords = c(-0.07, 46.11),
      new_min_dbh = 5,
      new_max_dbh = too_long,
      new_sample_size = 50
    )
  )

  too_long <- c(50, 50)
  expect_snapshot_error(
    new_equations(
      new_taxa = "Faga",
      new_allometry = "exp(-2+log(dbh)*2.5)",
      new_coords = c(-0.07, 46.11),
      new_min_dbh = 5,
      new_max_dbh = 50,
      new_sample_size = too_long
    )
  )
})

test_that("if `new_allometry` isn't of type character errors gracefully", {
  not_character <- 1
  expect_snapshot_error(
    new_equations(
      new_taxa = "Faga",
      new_allometry = not_character,
      new_coords = c(-0.07, 46.11),
      new_min_dbh = 5,
      new_max_dbh = 50,
      new_sample_size = 50
    )
  )
})

test_that("if `new_allometry` conains an assignment errors gracefully", {
  has_assignment <- "a = 1"
  expect_snapshot_error(
    new_equations(
      new_taxa = "Faga",
      new_allometry = has_assignment,
      new_coords = c(-0.07, 46.11),
      new_min_dbh = 5,
      new_max_dbh = 50,
      new_sample_size = 50
    )
  )

  has_assignment <- "a <- 1"
  expect_snapshot_error(
    new_equations(
      new_taxa = "Faga",
      new_allometry = has_assignment,
      new_coords = c(-0.07, 46.11),
      new_min_dbh = 5,
      new_max_dbh = 50,
      new_sample_size = 50
    )
  )
})

test_that("height must be in meters", {
  bad <- "g"
  expect_snapshot_error(
    new_equations(
      new_output_var = "Height",
      new_unit_output = bad,
      new_taxa = "Faga",
      new_allometry = "dbh",
      new_coords = c(-0.07, 46.11),
      new_min_dbh = 5,
      new_max_dbh = 50,
      new_sample_size = 50
    )
  )
})

test_that("height must be in meters", {
  bad <- "g"
  expect_snapshot_error(
    new_equations(
      new_output_var = "Height",
      new_unit_output = bad,
      new_taxa = "Faga",
      new_allometry = "dbh",
      new_coords = c(-0.07, 46.11),
      new_min_dbh = 1,
      new_max_dbh = 2,
      new_sample_size = 50
    )
  )
})

test_that("with bad coordinates errors gracefully", {
  bad <- c(-999, 999)
  expect_snapshot_error(
    new_equations(
      new_taxa = "Faga",
      new_allometry = "dbh",
      new_coords = bad,
      new_min_dbh = 1,
      new_max_dbh = 2,
      new_sample_size = 50
    )
  )
})

test_that("with equation not a function of DBH errors gracefully", {
  bad <- "1"
  expect_snapshot_error(
    new_equations(
      new_taxa = "Faga",
      new_allometry = bad,
      new_coords = c(0, 0),
      new_min_dbh = 1,
      new_max_dbh = 2,
      new_sample_size = 50
    )
  )
})

# TODO: Continue to test that you get the expected errors
