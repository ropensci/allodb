#' Validate equations
#'
#' @param equations A character vector giving equations to validate.
#' @param dbh,h Independent variables
#' @param env An environment on which to evaluate the equations.
#'
#' @return This function is called for its side effect of throwing an error if
#'   at least one equation is invalid. Valid equations are returned invisibly.
#'
#' @examples
#' # Good
#' validate_one_equation("dbh + 1")
#'
#' # Fails
#' try(validate_one_equation("bad + 1"))
#'
#' equations <- allodb::equations$equation_allometry
#' try(validate_equations(equations))
#'
#' # FIXME: Some equations use "DBH" in uppercase. Is this intentional?
#' grep("DBH", equations, value = TRUE)[[1]] # But we also have uppercase
#' grep("dbh", equations, value = TRUE)[[1]] # I expected only lowercase
#' valid <- tolower(equations)
#'
#' try(validate_equations(valid))
#' @noRd
validate_equations <- function(equations, dbh = 1, h = 1, env = current_env()) {
  walk_apply(equations, validate_one_equation, dbh = dbh, h = h, env = env)
}

validate_one_equation <- function(equation, dbh = 1, h = 1, env = current_env()) {
  tryCatch(
    eval(parse(text = equation), envir = env),
    error = function(e) {
      abort(c(
        "`text` must be valid R code.",
        x = paste("Invalid:", equation),
        x = paste("Error:", conditionMessage(e))
      ))
    }
  )

  invisible(equation)
}

current_env <- function() {
  parent.frame()
}

# Like purrr::walk()
walk_apply <- function(.x, .f, ...) {
  lapply(.x, .f, ...)
  invisible(.x)
}
