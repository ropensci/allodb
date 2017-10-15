

#' Make a function.
#'
#' @param args Arguments.
#' @param body Body.
#' @param env Environment.
#'
#' @author joran (profile: https://goo.gl/6biFxw;
#'   contribution: https://goo.gl/Bg7p5K).
#'
#' @return A function.
#' @export
#'
#' @examples
#' args <- alist(x = x, a = 1, b = NULL)
#' body <- quote(a * x + b)
#' myfun <- make_function(args, body)
#'
#' myfun
#'
#' myfun(x = 2, a = 4, b = 2)
make_function <- function(args, body, env = parent.frame()) {
      as.function(c(args, body), env)
}

args <- alist(x = x, a = 1, b = NULL)
body <- quote(a * x + b)
myfun <- make_function(args, body)
myfun
myfun(x = 2, a = 4, b = 2)

