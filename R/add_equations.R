#' Function to add new equations to the equation table (then used in the get_biomass function)
#'
#' This function creates S3 objects of class "numeric".
#'
#' @param taxa character string or vector specifying the taxon (or taxa) for which the allometry has been calibrated
#' @param allometry a character string with the allometric equation
#' @param coords a vector or matrix of coordinates (longitude, latitude) of the calibration data
#' @param minDBH numerical value, minimum DBH for which the equation is valid (in cm)
#' @param maxDBH numerical value, maximum DBH for which the equation is valid (in cm)
#' @param sampleSize number of measurements with which the allometry was calibrated
#' @param unitDBH character string with unit of DBH in the equation (either `cm`, `mm` or `inch`). Default is `cm`.
#' @param unitOutput character string with unit of equation output (either `g`, `kg`, `Mg` or `lbs` if the output is a mass, or `m` if the output is a height).
#' @param inputVar independent variable(s) needed in the allometry. Default is `DBH`, other option is `DBH, H`.
#' @param outputVar dependent variable estimated by the allometry. Default is `Total aboveground biomass`.
#'
#' @return A new equation table including all default equations and the additional equation (equation_id = `new`)
#'
#' @export
#'
#' @examples
#' new_equations = add_equation(
#'   taxa = "Faga",
#'   allometry = "exp(-2+log(dbh)*2.5)",
#'   coords = c(-0.07, 46.11),
#'   minDBH = 5,
#'   maxDBH = 50,
#'   sampleSize = 50
#')
#'
add_equation = function(taxa,
                        allometry,
                        coords,
                        minDBH,
                        maxDBH,
                        sampleSize,
                        unitDBH = "cm",
                        unitOutput = "kg",
                        inputVar = "DBH",
                        outputVar = "Total aboveground biomass") {

  data("equations", envir = environment())

  ## check consistency of inputs
  if (!unitDBH %in% c("cm", "mm", "inch"))
    stop("unitDBH must be either cm, mm or inch.")

  if (!unitOutput %in% c("g", "kg", "Mg", "lbs", "m"))
    stop("unitOutput must be either `g`, `kg`, `Mg` or `lbs`, or `m`.")

  if (outputVar == "Height" & unitOutput != "m")
    stop("Height allometries outputs must be in m.")

  if (maxDBH <= minDBH |
      minDBH < 0 | !is.numeric(minDBH) | !is.numeric(maxDBH))
    stop("minDBH and maxDBH must be positive real numbers, with maxDBH > minDBH.")

  if (length(taxa) != length(allometry) |
      length(allometry) != length(minDBH) |
      length(minDBH) != length(maxDBH) |
      length(maxDBH) != length(sampleSize))
    stop("taxa, allometry, minDBH, maxDBH and sampleSize must all be the same length.")

  if (!is.matrix(coords)) {
    coords = matrix(rep(coords, length(taxa)), ncol = 2, byrow = TRUE)
  }

  if (!is.numeric(coords) |
      !(ncol(coords) == 2 & nrow(coords) == length(taxa)))
    stop(
      "coords must be a numeric vector of length 2 or a matrix with 2 columns (long, lat) and as many rows as the number of equations."
    )

  if (any(coords[, 1] < -180 |
          coords[, 1] > 180 | coords[, 2] < -90 | coords[, 2] > 90))
    stop("Longitude must be between -180 and 180, and latitude between 90 and 90.")

  allometry = tolower(allometry)

  if (any(!grepl("dbh", allometry)))
    stop("Allometry does not contain DBH as a dependent variable.")

  equationID = paste0("new", 1:length(taxa))
  coordsEq = cbind(
    long = coords[, 1],
    lat = coords[, 2]
  )
  climates = allodb::koppenRaster@data@attributes[[1]][, 2]
  koppenZones = climates[raster::extract(allodb::koppenRaster, coordsEq)]
  if (any(grepl("missing", koppenZones)))
    stop(
      "Impossible to find all koppen climate zones based on coordinates. Check that they are Long, Lat."
    )

  new_equations = data.frame(
    equation_id = equationID,
    equation_taxa = taxa,
    equation_allometry = allometry,
    independent_variable = inputVar,
    dependent_variable = outputVar,
    long = coords[, 1],
    lat = coords[, 2],
    koppen = koppenZones,
    dbh_min_cm = minDBH,
    dbh_max_cm = maxDBH,
    sample_size = sampleSize,
    dbh_units_original = unitDBH,
    output_units_original = unitOutput
  )

  new_equations = rbind(new_equations,
                        equations[, colnames(new_equations)])

  ## conversion factor for input
  new_equations = merge(new_equations, unique(equations[, c("output_units_original", 'output_units_CF')]))
  new_equations = merge(new_equations, unique(equations[, c("dbh_units_original", 'dbh_unit_CF')]))

  new_equations = new_equations[, c(
    "equation_id" ,
    "equation_taxa",
    "equation_allometry",
    "independent_variable",
    "dependent_variable",
    "long",
    "lat",
    "koppen",
    "dbh_min_cm",
    "dbh_max_cm",
    "sample_size",
    "dbh_units_original",
    "dbh_unit_CF",
    "output_units_original",
    "output_units_CF"
  )]
  return(new_equations)
}
