#' Drop rows known to contain problematic equaitons.
#'
#' @param .data An __allodb__ dataframe with the variable `equation_id`.
#'
#' @return A dataframe.
#' @export
#'
#' @keywords internal
#'
#' @examples
#' drop_bad_equations(master())
drop_bad_equations <- function(.data) {
  if (utils::hasName(.data, "equation_id"))
    return(dplyr::filter(.data, ! .data$equation_id %in% bad_eqn_id))

  col_nms <- glue::glue_collapse(
    rlang::expr_label(names(.data)), sep = ', ', last = ' and '
  )
  rlang::abort(glue::glue("
    `.data` must have the column `equation_id`
    Columns found:
    {col_nms}.
  "))
}
