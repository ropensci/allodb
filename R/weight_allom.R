#' Attribute weights to equations
#'
#' This function attributes a weight to each equation based on its sampling
#' size, and taxonomic and climatic similarity with the species/site combination
#' considered.
#'
#' @param genus a character value, containing the genus (e.g. "Quercus") of the
#'   tree.
#' @param coords a numeric vector of length 2 with longitude and latitude.
#' @param species a character vector (same length as genus), containing the
#'   species (e.g. "rubra") of the tree. Default is "NULL", when no species
#'   identification is available.
#' @param new_eqtable Optional. An equation table created with the
#'   `new_equations()` function.
#' @param wna a numeric vector, this parameter is used in the `weight_allom()` function to determine
#'   the sample-size related weights attributed to equations without a specified
#'   sample size. Default is 0.1.
#' @param w95 a numeric vector, this parameter is used to determine the value at which the
#'   sample-size-related weight reaches 95% of its maximum value (max=1).
#'   Default is 500.
#'
#' @details Each equation is given a weight by the function `weight_allom()`,
#'   calculated as the product of the following components:
#'
#'   (1) sample-size weight, calculated as:
#'
#'   \deqn{1-exp(-n*(log(20)/w95))}
#'
#'   where n is the sample size of the equation; the weight given to equations
#'   with no sample size information is determined by argument `wna` (0.1 by
#'   default).
#'
#'   (2) climate weight, based on the similarity between the climatic conditions
#'   of the equation site and the target location, using the three-letter system
#'   of Koppen's climate scheme. Climate weights associated with each
#'   combination of two Koppen climates are provided in `data("koppenMatrix")`.
#'   The resulting weight has a value between 1e-6 (different climate groups)
#'   and 1 (exactly the same climate classification). When an equation was
#'   calibrated with trees from several locations with different Koppen
#'   climates, the maximum value out of all pairwise equation-site climate
#'   weights is used.
#'
#'   (3) taxonomic weight: equal to 1 for same species equations, 0.8 for same
#'   genus equations, 0.5 for same family equations and for equations calibrated
#'   for the same broad functional or taxonomic group (e.g. shrubs, conifers,
#'   angiosperms). All other equations are given a low taxonomic weight of 1e-6:
#'   these equations will have a significant relative weight in the final
#'   prediction only when no other more specific equation is available.
#'
#' @return A named numeric vector, with one weight for each equation.
#'
#' @seealso [get_biomass()], [new_equations()]
#'
#' @export
#'
#' @examples
#' x <- weight_allom(
#'   genus = "Acer",
#'   species = "negundo",
#'   coords = c(-78.2, 38.9)
#' )
#' str(x)
#' head(x)
weight_allom <- function(genus,
                         coords,
                         species = NULL,
                         new_eqtable = NULL,
                         wna = 0.1,
                         w95 = 500) {
  if (!is.null(new_eqtable)) {
    dfequation <- new_eqtable
  } else
    dfequation <- new_equations()

  ### sample size weight ####
  b <- log(20) / w95
  suppressWarnings(dfequation$wn <-
                     (1 - exp(
                       -b * as.numeric(dfequation$sample_size)
                     )))
  dfequation$wn[is.na(dfequation$wn)] <- wna

  ### climate weight ####
  # (1) get koppen climate
  coords_site <- t(as.numeric(coords))
  rcoords_site <- round(coords_site * 2 - 0.5) / 2 + 0.25
  ## extract koppen climate of every location
  koppen_obs <- apply(rcoords_site, 1, function(xk) {
    subset(kgc::climatezones, Lon == xk[1] &  Lat == xk[2])$Cls
  })
  if (length(koppen_obs) == 0 ) {
    warning("The coordinates c(",
            paste(coords,collapse = ","),
            ") are not associated with a Koppen climate zone.")
    dfequation$we <- 1e-6
  } else {
    kopmatrix <- subset(allodb::koppenMatrix, zone1 == koppen_obs)
    compare_koppen <- function(kopp) {
      kopp <- tolower(unlist(strsplit(kopp, ", |; |,|;")))
      max(subset(kopmatrix, tolower(zone2) %in% kopp)$we)
    }
    dfequation$we <- vapply(dfequation$koppen, compare_koppen, FUN.VALUE = 0.9)
    ## error message when the koppen climate of the site does not correspond to
    ## any equation
    if (sum(dfequation$we) < 0.2)
      warning(paste0("The Koppen climate zone corresponding to coordinates (",
                     paste(coords, collapse = ", "),
                     ") is ",
                     koppen_obs,
                     " and is not represented in your equation table."))
  }


  ### taxo weight ####
  ## 'clean' equation taxa column and separate several taxa
  ## all character strings to lower cases to avoid inconsistencies
  dfequation$equation_taxa <- tolower(dfequation$equation_taxa)
  ## remove " sp." from genus in equation taxa
  dfequation$equation_taxa <-
    gsub(" sp//.", "", dfequation$equation_taxa)
  ## split by "/" when there are several species or families
  taxa <-
    data.table::tstrsplit(dfequation$equation_taxa, "/| / | /|/ ")
  taxa <- do.call(cbind, taxa)
  colnames(taxa) <- paste0("taxa", seq_len(ncol(taxa)))
  dfequation <- cbind(dfequation, taxa)
  ## get family of input genus
  genus_obs <- tolower(genus)
  genus_family <-
    subset(allodb::genus_family, tolower(genus) == genus_obs)
  family_obs <- tolower(genus_family$family)

  ## basic weight = 1e-6 (equations used only if no other is available)
  dfequation$wt <- 1e-6

  # same genus
  dfequation$wt[dfequation$taxa1 == genus_obs] <- 0.8
  # same genus, different species
  eqtaxa_g <- data.table::tstrsplit(dfequation$taxa1, " ")[[1]]
  eqtaxa_s <- data.table::tstrsplit(dfequation$taxa1, " ")[[2]]
  dfequation$wt[eqtaxa_g == genus_obs & !is.na(eqtaxa_s)] <- 0.7
  # same species
  dfequation$wt[dfequation$taxa1 == paste(genus_obs, species) |
                  (dfequation$taxa2 == paste(genus_obs, species) &
                     !is.na(dfequation$taxa2))] <- 1
  # # same family
  dfequation$wt[dfequation$taxa1 == family_obs |
                  (!is.na(dfequation$taxa2) &
                     dfequation$taxa2 == family_obs) |
                  (!is.na(dfequation$taxa3) &
                     dfequation$taxa3 == family_obs) |
                  (!is.na(dfequation$taxa4) &
                     dfequation$taxa4 == family_obs) |
                  (!is.na(dfequation$taxa5) &
                     dfequation$taxa5 == family_obs) |
                  (!is.na(dfequation$taxa6) &
                     dfequation$taxa6 == family_obs)] <- 0.5
  # generic equations
  ## conifers / gymnosperms?
  conifers <- allodb::gymno_genus$Genus[allodb::gymno_genus$conifer]
  # yes
  dfequation$wt[genus_obs %in% conifers &
                  dfequation$equation_taxa == "conifers"] <- 0.3
  # no
  dfequation$wt[!(genus_obs %in% allodb::gymno_genus$Genus) &
                  dfequation$equation_taxa == "broad-leaved species"] <-
    0.3
  ## tree or shrub?
  shrub_genus <-
    gsub(" sp\\.",
         "",
         grep(" sp\\.", allodb::shrub_species, value = TRUE))
  # shrubs (all)
  dfequation$wt[(paste(genus_obs, species) %in% allodb::shrub_species |
                   genus_obs %in% shrub_genus) &
                  dfequation$equation_taxa == "shrubs"] <- 0.3
  # shrubs (angio)
  dfequation$wt[(paste(genus_obs, species) %in% allodb::shrub_species |
                   genus_obs %in% shrub_genus) &
                  !(genus_obs %in% allodb::gymno_genus$Genus) &
                  dfequation$equation_taxa == "shrubs (angiosperms)"] <-
    0.3
  # trees (all)
  dfequation$wt[!paste(genus_obs, species) %in% allodb::shrub_species &
                  !genus_obs %in% shrub_genus &
                  dfequation$equation_taxa == "trees
                (angiosperms/gymnosperms)"] <-
    0.3
  # trees (angio)
  dfequation$wt[!paste(genus_obs, species) %in% allodb::shrub_species &
                  !genus_obs %in% shrub_genus &
                  !(genus_obs %in% allodb::gymno_genus$Genus) &
                  dfequation$equation_taxa == "trees (angiosperms)"] <-
    0.3

  ### final weights ####
  # multiplicative weights: if one is zero, the total weight should be zero too
  dfequation$w <- dfequation$wn * dfequation$we * dfequation$wt

  vec_w <- dfequation$w
  names(vec_w) <- dfequation$equation_id
  return(vec_w)
}
