context("rowbind_inorder")

test_that("winner rows depend on the order of the list-elements", {
  prio <- list(
    prio1 = tibble(rowid = 1:1, x = "prio1"),
    prio2 = tibble(rowid = 1:2, x = "prio2"),
    prio3 = tibble(rowid = 1:3, x = "prio3")
  )
  combo <- dplyr::bind_rows(
    prio[[1]][1, ],
    prio[[2]][2, ],
    prio[[3]][3, ]
  )
  expect_equal(rowbind_inorder(prio), combo)
  expect_equal(rowbind_inorder(prio, c(1, 2, 3)), combo)

  prio <- list(
    prio1 = tibble(rowid = 1:3, x = "prio1"),
    prio2 = tibble(rowid = 1:2, x = "prio2"),
    prio3 = tibble(rowid = 1:1, x = "prio3")
  )
  order <- c("prio1", "prio2", "prio3")
  combo <- dplyr::bind_rows(
    prio[[3]][1, ],
    prio[[2]][2, ],
    prio[[1]][3, ]
  )
  expect_equal(rowbind_inorder(prio, rev(order)), combo)
  expect_equal(rowbind_inorder(prio, c(3, 2, 1)), combo)
})

test_that("errs with informative message", {
  prio <- list(
    prio1 = tibble(x = "prio1"),
    prio2 = tibble(x = "prio2")
  )
  expect_warning(rowbind_inorder(prio), "Adding `rowid` to")
})

