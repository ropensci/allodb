context("rank_eqn")

library(dplyr)

test_that("winner wins", {
  winner <- tibble(rowid = 1, x = "win", y = 1)
  loser <- tibble(rowid = 1, x = "lose", y = 9)
  out <- bind_winner_loser(winner, loser)
  expect_equal(out, winner)

  winner <- tibble(rowid = 1:2, x = "win", y = 1)
  loser <- tibble(rowid = 1:2, x = "lose", y = 9)
  out <- bind_winner_loser(winner, loser)
  expect_equal(out, winner)

  winner <- tibble(rowid = 1:2, x = "win", y = c(1, NA))
  loser <- tibble(rowid = 1:2, x = "lose", y = c(9, NA))
  out <- bind_winner_loser(winner, loser)
  expect_equal(out, winner)
})

test_that("loser complements", {
  winner <- tibble(rowid = 1, x = "win", y = 1)
  loser <- tibble(rowid = 1:2, x = "lose", y = 9)
  out <- bind_winner_loser(winner, loser)
  combo <- bind_rows(winner[1, ], loser[2, ])
  expect_equal(out, combo)

  winner <- tibble(rowid = 1, x = "win", y = 1)
  winner <- winner[0, ]
  loser <- tibble(rowid = 1:2, x = "lose", y = 9)
  out <- bind_winner_loser(winner, loser)
  expect_equal(out, loser)
})

test_that("with both 0-row returns 0-row as winner", {
  winner <- tibble(rowid = 1, x = "win")[0, ]
  loser <- tibble(rowid = 1:2, x = "lose")[0, ]
  out <- bind_winner_loser(winner, loser)
  expect_equal(out, winner)
})

test_that("with 0-row loser returns 0-row as winner", {
  winner <- tibble(rowid = 1, x = "win")
  loser <- tibble(rowid = 1:2, x = "lose")[0, ]
  out <- bind_winner_loser(winner, loser)
  expect_equal(out, winner)
})

test_that("errs with informative message", {
  msg <- "Ensure.*rowid"
  winner <- tibble(x = "win", y = 1)
  loser <- tibble(x = "lose", y = 9)
  expect_error(bind_winner_loser(winner, loser), msg)

  msg <- "rowid.*can't have missing values"
  winner <- tibble(rowid = NA, x = "win", y = 1)
  loser <- tibble(rowid = 1, x = "lose", y = 9)
  expect_error(bind_winner_loser(winner, loser), msg)
})

test_that("the winner dataframe is the first one of the list", {
  prio1 <- tibble(rowid = 1, x = "prio1")
  prio2 <- tibble(rowid = 1, x = "prio2")
  prio3 <- tibble(rowid = 1, x = "prio3")

  prio <- list(prio1, prio2, prio3)
  expect_equal(purrr::reduce(prio, bind_winner_loser), prio1)

  prio <- list(prio2, prio1, prio3)
  expect_equal(purrr::reduce(prio, bind_winner_loser), prio2)

  prio <- list(prio3, prio2, prio1)
  expect_equal(purrr::reduce(prio, bind_winner_loser), prio3)
})

test_that("the winner can be determined by reordering the list", {
  prio <- list(
    prio1 = tibble(rowid = 1, x = "prio1"),
    prio2 = tibble(rowid = 1, x = "prio2"),
    prio3 = tibble(rowid = 1, x = "prio3")
  )

  order <- c("prio3", "prio1", "prio2")
  expect_equal(purrr::reduce(prio[order], bind_winner_loser), prio[[3]])
  expect_equal(purrr::reduce(prio[rev(order)], bind_winner_loser), prio[[2]])
})

