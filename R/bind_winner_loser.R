#' Keep rows from a dataframe and add missing rows from another dataframe.
#'
#' @param winner Dataframes which rows to always keep.
#' @param loser Dataframe from which to add missing rows to the winner
#'   dataframe.
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' winner <- tibble(rowid = 1, x = "from winner")
#' loser <- tibble(rowid = 1:2, x = "from loser")
#' bind_winner_loser(winner, loser)
#'
#' winner2 <- tibble(rowid = 1:2, x = "from winner")
#' loser2 <- tibble(rowid = 1:2, x = "from loser")
#' bind_winner_loser(winner2, loser2)
bind_winner_loser <- function(winner, loser) {
  check_bind_winner_loser(winner, loser)

  # Handle 0-row dataframes
  winner0 <- nrow(winner) == 0
  loser0 <- nrow(loser) == 0
  # Both 0-row: return winner
  if (winner0 && loser0) {
    return(winner)
  }
  # One 0-row: Modify the 0-row one to use column types as the (non-empty) other
  if (winner0) winner <- modify_cols_as_ref(winner, loser)
  if (loser0) loser <- modify_cols_as_ref(loser, winner)

  list(
    w_and_l <- dplyr::semi_join(winner, loser, by = "rowid"),
    w_not_l <- dplyr::anti_join(winner, loser, by = "rowid"),
    l_not_w <- dplyr::anti_join(loser, winner, by = "rowid")
  ) %>%
    purrr::reduce(dplyr::bind_rows)
}

check_bind_winner_loser <- function(winner, loser) {
  check_crucial_names(winner, "rowid")
  check_crucial_names(loser, "rowid")

  missing_winner <- any(is.na(winner$rowid))
  missing_loser <- any(is.na(loser$rowid))
  if (missing_winner || missing_loser) {
    abort("`rowid` can't have missing values.")
  }

  invisible()
}

cols_expr <- function(.data) {
  types <- .data %>%
    purrr::map_chr(typeof) %>%
    strsplit("") %>%
    purrr::map_chr(1)
  .cols <- glue::glue_collapse(glue::glue("{names(types)} = \"{types}\""), ", ")
  rlang::parse_expr(glue::glue("readr::cols({.cols})"))
}

modify_cols_as_ref <- function(.data, ref) {
  .data <- purrr::modify(.data, as.character)
  readr::type_convert(.data, col_types = rlang::eval_tidy(cols_expr(ref)))
}

