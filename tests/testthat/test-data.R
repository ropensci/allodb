test_that("all dataframes are also tibbles", {
  nms <- utils::data(package = "allodb")$results[, "Item"]
  datasets <- lapply(nms, function(x) get(x, "package:allodb"))
  datasets <- setNames(datasets, nms)
  is_dataframe <- unlist(lapply(datasets, is.data.frame))
  dataframes <- datasets[is_dataframe]

  expect_true(all(unlist(lapply(dataframes, tibble::is_tibble))))
})
