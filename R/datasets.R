#' List datasets in a package.
#'
#' @param package String giving the name of a package.
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' datasets("allodb")
datasets <- function(package) {
  sort(utils::data(package = package)$results[ , "Item"])
}
