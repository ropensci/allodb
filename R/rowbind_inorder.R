#' Reduce a list of dataframes row-binding each dataframe in a given order.
#'
#' This function orders a list of dataframes then reduces the list in order, by
#' row-binding each dataframe with the following one and using
#' [bind_winner_loser()].
#'
#' @param .x List of dataframes. Each should have a `rowid` column giving the
#'   index of each row. Otherwise, `rowid` will be added with a warning.
#' @param order String giving the name or index of the list elements in the
#'   order they should be row-bind, with elements on the left winning over
#'   elements on the right.
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' prio <- list(
#'   prio1 = tibble(rowid = 1:1, x = "prio1"),
#'   prio2 = tibble(rowid = 1:2, x = "prio2"),
#'   prio3 = tibble(rowid = 1:3, x = "prio3")
#' )
#' rowbind_inorder(prio)
#' # Same
#' rowbind_inorder(prio, c(1, 2, 3))
#'
#' # 3 overwrites all other
#' rowbind_inorder(prio, c("prio3", "prio2", "prio1"))
#'
#' # 2 overwrites over 1
#' rowbind_inorder(prio, c(2, 1))
#'
#' # Adds `rowid` with a warning
#' prio <- list(
#'   prio1 = tibble(rowid = 1, x = "prio1"),
#'   prio2 = tibble(x = "prio2"),
#'   prio3 = tibble(x = "prio3")
#' )
#' rowbind_inorder(prio)
rowbind_inorder <- function(.x, order = NULL) {
  order <- order %||% names(.x)

  add_rowid_if_needed <- function(.x) {
    lacks_rowid <- !purrr::map_lgl(.x, ~rlang::has_name(.x, "rowid"))

    nms <- glue::glue_collapse(
      rlang::expr_label(names(.x)[lacks_rowid]),
      sep = ", ", last = " and "
    )
    if (any(lacks_rowid)) {
      warn(glue("Adding `rowid` to {nms}"))
    }

    purrr::modify_if(.x, lacks_rowid, tibble::rowid_to_column)
  }

  .x <- add_rowid_if_needed(.x)

  purrr::reduce(.x[order], bind_winner_loser)
}
