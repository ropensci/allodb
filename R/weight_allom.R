#' Function to attribute weights
#'
#' This function creates S3 objects of class "numeric".
#'
#' @param genus A character vector, containing the genus (e.g. "Quercus") of
#'   each tree. Default is NULL, when no identification is available.
#' @param species A character vector (same length as genus), containing the
#'   species (e.g. "rubra")  of each tree. Default is NULL, when no
#'   identification is available.
#' @param coords A numerical vector of length 2 with longitude and latitude (if
#'   all trees were measured in the same location) or a matrix with 2 numerical
#'   columns giving the coordinates of each tree.
#' @param new_equations Optional. An equation table created with the
#'   add_equation() function. Default is the base allodb equation table.
#' @param wna this parameter is used in the weighting function to determine the
#'   dbh-related and sample-size related weights attributed to equations without
#'   a specified dbh range or sample size, respectively. Default is 0.1
#' @param wsteep this parameter controls the steepness of the dbh-related weight
#'   in the weighting function. Default is 3.
#' @param w95 this parameter is used in the weighting function to determine the
#'   value at which the sample-size-related weight reaches 95% of its maximum
#'   value (max=1). Default is 500.
#'
#' @return A data frame xxx
#' @export
#'
#' @examples
#' data(scbi_stem1)
#' weight_allom(
#'   genus = scbi_stem1$genus,
#'   species = scbi_stem1$species,
#'   coords = c(-78.2, 38.9)
#' )
#'
weight_allom <- function(genus,
                         species = NULL,
                         coords,
                         new_equations = NULL,
                         wna = 0.1,
                         wsteep = 3,
                         w95 = 500
) {

  if (!is.null(new_equations)) {
    dfequation <- new_equations
  } else dfequation <- new_equations()

  dfeq <- data.table::setDT(dfequation[, c("equation_id", "sample_size", "dbh_min_cm", "dbh_max_cm", "koppen", "equation_taxa")])
  ## keep equation_id order by turning it into a factor
  dfeq$equation_id <- factor(dfeq$equation_id, levels = dfequation$equation_id)

  ## 'clean' equation taxa column and separate several taxa
  ## all character strings to lower cases to avoid inconsistencies
  dfeq$equation_taxa <- tolower(dfeq$equation_taxa)
  ## remove " sp." from genus in equation taxa
  dfeq$equation_taxa <- gsub(" sp//.", "", dfeq$equation_taxa)
  ## split by "/" when there are several species or families
  taxa <- data.table::tstrsplit(dfeq$equation_taxa, "/| / | /|/ ")
  dfeq$taxa1 <- taxa[[1]]
  dfeq$taxa2 <- taxa[[2]]
  dfeq$taxa3 <- taxa[[3]]
  dfeq$taxa4 <- taxa[[4]]
  dfeq$taxa5 <- taxa[[5]]
  dfeq$taxa6 <- taxa[[6]]

  ### sample size weight ####
  b = log(20) / w95
  suppressWarnings(dfeq$wN <- (1 - exp(-b * as.numeric(dfeq$sample_size))))
  # b=0.006 -> we reach 95% of the max value of weight_N when Nobs = log(20)/0.006 = 500
  # implication: new observations will not increase weight_N much when Nobs > 500
  dfeq$wN[is.na(dfeq$wN)] <- wna

  ## prepare observations: species x site ####

  ### get koppen climate ####
  # (1) get koppen climate for all locations
  # if only one location, transform coords into matrix with 2 numeric columns
  if (length(unlist(coords)) == 2) {
    coordsSite <- t(as.numeric(coords))
  } else if (length(unlist(unique(coords))) == 2) {
    coordsSite <- t(apply(unique(coords), 2, as.numeric))
  } else {
    coordsSite <- apply(unique(coords), 2, as.numeric)
  }
  ## extract koppen climate of every location
  # koppen climate raster downloaded from http://koeppen-geiger.vu-wien.ac.at/present.htm on the 2/10/2020
  climates <- allodb::koppenRaster@data@attributes[[1]][, 2]
  koppenObs <- climates[raster::extract(allodb::koppenRaster, coordsSite)]
  if (length(koppenObs) > 1) {
    coordsLev <- apply(coords, 1, function(x) paste(x, collapse = "_"))
    coordsLev <- factor(coordsLev, levels = unique(coordsLev))
    koppenObs <- koppenObs[as.numeric(coordsLev)]
  }

  dfobs = unique(data.table::data.table(genus = tolower(genus),
                                        species = tolower(species),
                                        koppenObs))
  dfobs$obs_id = 1:nrow(dfobs)

  ## add family
  genus_family <- allodb::genus_family
  genus_family$genus <- tolower(genus_family$genus)
  genus_family$family <- tolower(genus_family$family)
  dfobs <- merge(dfobs, genus_family, by = "genus", all.x = TRUE)

  ## combine observations and equations ####
  combinations <- expand.grid(obs_id = 1:length(genus), equation_id = dfequation$equation_id)
  dfweights <- merge(dfeq, combinations, by = "equation_id")
  dfweights <- merge(dfweights, dfobs, by = "obs_id")
  rm(combinations, dfobs, dfeq)

  ### koppen climate weight ####
  dfkoppen <- unique(dfweights[, c("koppenObs", "koppen")])
  compare_koppen <- function(Z) {
    z1 <- tolower(Z[1])
    z2 <- tolower(unlist(strsplit(Z[2], ", |; |,|;")))
    max(allodb::koppenMatrix$wE[tolower(allodb::koppenMatrix$zone1) == z1 &
                                  tolower(allodb::koppenMatrix$zone2) %in% z2])
  }
  dfkoppen$wE <- apply(dfkoppen, 1, compare_koppen)
  dfweights <- merge(dfweights, dfkoppen, by = c("koppenObs", "koppen"))

  ### taxonomic weight ####
  ## basic weight = 1e-6 (equations used only if no other is available)
  dfweights$wT <- 1e-6

  # same genus
  dfweights$wT[dfweights$taxa1 == dfweights$genus] <- 0.8
  # same genus, different species
  eqtaxaG <- data.table::tstrsplit(dfweights$taxa1, " ")[[1]]
  eqtaxaS <- data.table::tstrsplit(dfweights$taxa1, " ")[[2]]
  dfweights$wT[eqtaxaG == dfweights$genus & !is.na(eqtaxaS)] <- 0.7
  # same species
  dfweights$wT[dfweights$taxa1 == paste(dfweights$genus, dfweights$species) |
                 (dfweights$taxa2 == paste(dfweights$genus, dfweights$species) &
                    !is.na(dfweights$taxa2))] <- 1
  # # same family
  dfweights$wT[dfweights$taxa1 == dfweights$family |
                 (!is.na(dfweights$taxa2) & dfweights$taxa2 == dfweights$family) |
                 (!is.na(dfweights$taxa3) & dfweights$taxa3 == dfweights$family) |
                 (!is.na(dfweights$taxa4) & dfweights$taxa4 == dfweights$family) |
                 (!is.na(dfweights$taxa5) & dfweights$taxa5 == dfweights$family) |
                 (!is.na(dfweights$taxa6) & dfweights$taxa6 == dfweights$family)] <- 0.5
  # generic equations
  ## conifers / gymnosperms?
  conifers <- allodb::gymno_genus$Genus[allodb::gymno_genus$conifer]
  # yes
  dfweights$wT[dfweights$genus %in% conifers &
                 dfweights$equation_taxa == "conifers"] <- 0.3
  # no
  dfweights$wT[!(dfweights$genus %in% allodb::gymno_genus$Genus) &
                 dfweights$equation_taxa == "broad-leaved species"] <- 0.3
  ## tree or shrub?
  shrub_genus <- gsub(" sp\\.", "", grep(" sp\\.", allodb::shrub_species, value = TRUE))
  # shrubs (all)
  dfweights$wT[(paste(dfweights$genus, dfweights$species) %in% allodb::shrub_species |
                  dfweights$genus %in% shrub_genus) &
                 dfweights$equation_taxa == "shrubs"] <- 0.3
  # shrubs (angio)
  dfweights$wT[(paste(dfweights$genus, dfweights$species) %in% allodb::shrub_species |
                  dfweights$genus %in% shrub_genus) &
                 !(dfweights$genus %in% allodb::gymno_genus$Genus) &
                 dfweights$equation_taxa == "shrubs (angiosperms)"] <- 0.3
  # trees (all)
  dfweights$wT[!paste(dfweights$genus, dfweights$species) %in% allodb::shrub_species &
                 !dfweights$genus %in% shrub_genus &
                 dfweights$equation_taxa == "trees (angiosperms/gymnosperms)"] <- 0.3
  # trees (angio)
  dfweights$wT[!paste(dfweights$genus, dfweights$species) %in% allodb::shrub_species &
                 !dfweights$genus %in% shrub_genus &
                 !(dfweights$genus %in% allodb::gymno_genus$Genus) &
                 dfweights$equation_taxa == "trees (angiosperms)"] <- 0.3

  # multiplicative weights: if one is zero, the total weight should be zero too
  dfweights$w <- dfweights$wN * dfweights$wE * dfweights$wT

  data.table::setorder(dfweights, obs_id, equation_id)
  Mw <- data.table::dcast(dfweights, obs_id ~ equation_id, value.var = "w")
  data.table::setorder(Mw, obs_id)
  Mw <- as.matrix(Mw)[, -1]
  Mw <- matrix(Mw,
               ncol = nrow(dfequation),
               dimnames = list(NULL, colnames(Mw))
  )
  return(Mw)
}
