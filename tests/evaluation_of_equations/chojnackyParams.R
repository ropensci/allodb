#' Retrieve Chojnacky parameters based on taxonomy and wood density
#'
#' @param family Character vector containing name of family corresponding to observations
#' @param genus Character vector containing genus
#' @param wsg Numerical vector containing wood density
#'
#' @return A matrix with 2 columns: the intercept and slope in the Chojnacky equations (Chojnacky et al, 2014)
#'
#' @export
#'
chojnackyParams <- function(family, genus, wsg) {
  pars <- matrix(rep(c(-2.2118, 2.4133), each = length(family)), ncol = 2)

  pars[family == "Cupressaceae" & wsg < 0.3, 1] <- -1.9615
  pars[family == "Cupressaceae" & wsg < 0.3, 2] <- 2.1063
  pars[family == "Cupressaceae" & wsg >= 0.3 & wsg < 0.4, 1] <- -2.7765
  pars[family == "Cupressaceae" & wsg >= 0.3 & wsg < 0.4, 2] <- 2.4195
  pars[family == "Cupressaceae" & wsg >= 0.4, 1] <- -2.6327
  pars[family == "Cupressaceae" & wsg >= 0.4, 2] <- 2.4757

  pars[family == "Betulaceae" & wsg < 0.4, 1] <- -2.5932
  pars[family == "Betulaceae" & wsg < 0.4, 2] <- 2.5349
  pars[family == "Betulaceae" & wsg >= 0.4 & wsg < 0.5, 1] <- -2.2271
  pars[family == "Betulaceae" & wsg >= 0.4 & wsg < 0.5, 2] <- 2.4513
  pars[family == "Betulaceae" & wsg >= 0.5 & wsg < 0.6, 1] <- -2.7765
  pars[family == "Betulaceae" & wsg >= 0.5 & wsg < 0.6, 2] <- 2.348
  pars[family == "Betulaceae" & wsg >= 0.6, 1] <- -2.2652
  pars[family == "Betulaceae" & wsg >= 0.6, 2] <- 2.5349

  pars[family == "Pinaceae" & wsg < 0.45, 1] <- -2.6177
  pars[family == "Pinaceae" & wsg < 0.45, 2] <- 2.4638
  pars[family == "Pinaceae" & wsg >= 0.45, 1] <- -3.0506
  pars[family == "Pinaceae" & wsg >= 0.45, 2] <- 2.6465

  pars[family == "Fagaceae", 1] <- -2.0705
  pars[family == "Fagaceae", 2] <- 2.4410

  pars[family == "Salicaceae" & wsg < 0.35, 1] <- -2.6863
  pars[family == "Salicaceae" & wsg < 0.35, 2] <- 2.4561
  pars[family == "Salicaceae" & wsg >= 0.35, 1] <- -2.4441
  pars[family == "Salicaceae" & wsg >= 0.35, 2] <- 2.4561

  pars[family == "Hamamelidaceae", 1] <- -2.6390
  pars[family == "Hamamelidaceae", 2] <- 2.5466

  pars[family == "Magnoliaceae", 1] <- -2.5497
  pars[family == "Magnoliaceae", 2] <- 2.5011

  pars[family == "Juglandaceae", 1] <- -2.5095
  pars[family == "Juglandaceae", 2] <- 2.5437

  pars[family == "Oleaceae" & wsg < 0.55, 1] <- -2.0314
  pars[family == "Oleaceae" & wsg < 0.55, 2] <- 2.3524
  pars[family == "Oleaceae" & wsg >= 0.55, 1] <- -1.8384
  pars[family == "Oleaceae" & wsg >= 0.55, 2] <- 2.3524

  pars[family == "Aceraceae" & wsg < 0.5, 1] <- -2.0470
  pars[family == "Aceraceae" & wsg < 0.5, 2] <- 2.3852
  pars[family == "Aceraceae" & wsg >= 0.5, 1] <- -1.8011
  pars[family == "Aceraceae" & wsg >= 0.5, 2] <- 2.3852

  pars[genus == "Abies" & wsg < 0.35, 1] <- -2.3123
  pars[genus == "Abies" & wsg < 0.35, 2] <- 2.3482
  pars[genus == "Abies" & wsg >= 0.35, 1] <- -3.1774
  pars[genus == "Abies" & wsg >= 0.35, 2] <- 2.6426

  pars[genus == "Carya", 1] <- -2.5095
  pars[genus == "Carya", 2] <- 2.6175

  pars[genus == "Larix", 1] <- -2.3012
  pars[genus == "Larix", 2] <- 2.3853

  pars[genus == "Picea" & wsg < 0.35, 1] <- -3.0300
  pars[genus == "Picea" & wsg < 0.35, 2] <- 2.5567
  pars[genus == "Picea" & wsg >= 0.35, 1] <- -2.1364
  pars[genus == "Picea" & wsg >= 0.35, 2] <- 2.3233

  pars[genus == "Pinus" & wsg < 0.45, 1] <- -2.6177
  pars[genus == "Pinus" & wsg < 0.45, 2] <- 2.4638
  pars[genus == "Pinus" & wsg >= 0.45, 1] <- -3.0506
  pars[genus == "Pinus" & wsg >= 0.45, 2] <- 2.6465

  pars[genus == "Pseudotsuga", 1] <- -2.4623
  pars[genus == "Pseudotsuga", 2] <- 2.4852

  pars[genus == "Tsuga" & wsg < 0.4, 1] <- -2.3480
  pars[genus == "Tsuga" & wsg < 0.4, 2] <- 2.3876
  pars[genus == "Tsuga" & wsg >= 0.4, 1] <- -2.9208
  pars[genus == "Tsuga" & wsg >= 0.4, 2] <- 2.5697

  return(pars)
}
