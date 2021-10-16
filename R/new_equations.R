#' Modify the original equation table
#'
#' This function modifies the original equation table to be used in other
#' functions of the package including: subset the original equation table, add
#' new equations, and choose whether to include equations with a height
#' allometry.
#'
#' @param subset_taxa character vector with taxa to be kept. Default is "all",
#'   in which case all taxa are kept.
#' @param subset_climate character vector with Koppen climate classification to
#'   be kept. Default is "all", in which case all climates are kept.
#' @param subset_region character vector with name of location(s) or
#'   country(ies) or broader region(s) (eg. "Europe", "North America") to be
#'   kept. Default is "all", in which case all regions/countries are kept.
#' @param subset_ids character vector with equation IDs to be kept. Default is
#'   "all", in which case all equations are kept.
#' @param subset_output What dependent variable(s) should be provided in the
#'   output? Default is "Total aboveground biomass" and "Whole tree (above
#'   stump)", other possible values are: "Bark biomass", "Branches (dead)",
#'   "Branches (live)", "Branches total (live, dead)", "Foliage total",
#'   "Height", "Leaves", "Stem (wood only)", "Stem biomass", "Stem biomass (with
#'   bark)", "Stem biomass (without bark)", "Whole tree (above and
#'   belowground)". Be aware that currently only a few equations represent those
#'   other variables, so estimated values might not be very accurate.
#' @param new_taxa character string or vector specifying the taxon (or taxa) for
#'   which the allometry has been calibrated
#' @param new_allometry a character string with the allometric equation
#' @param new_coords a vector or matrix of coordinates (longitude, latitude) of
#'   the calibration data
#' @param new_min_dbh numerical value, minimum DBH for which the equation is
#'   valid (in cm). Default is `NULL` (nothing is added).
#' @param new_max_dbh numerical value, maximum DBH for which the equation is
#'   valid (in cm). Default is `NULL` (nothing is added).
#' @param new_sample_size number of measurements with which the allometry was
#'   calibrated. Default is `NULL` (nothing is added).
#' @param new_unit_dbh character string with unit of DBH in the equation (either
#'   `cm`, `mm` or `inch`). Default is "cm".
#' @param new_unit_output character string with unit of equation output (either
#'   "g", "kg", "Mg" or "lbs" if the output is a mass, or "m" if the output is a
#'   height).
#' @param new_input_var independent variable(s) needed in the allometry. Default
#'   is "DBH", other option is "DBH, H".
#' @param new_output_var dependent variable estimated by the allometry. Default
#'   is "Total aboveground biomass".
#' @param use_height_allom a logical value. In \pkg{allodb}
#' we use Bohn et al. (2014)
#' for European sites. User need to provide height allometry
#' when needed to calculate AGB. Default is `TRUE`.
#'
#' @return A new equation dataframe (`tibble::tibble()` object).
#'
#' @export
#'
#' @examples
#' new_equations(
#'   new_taxa = "Faga",
#'   new_allometry = "exp(-2+log(dbh)*2.5)",
#'   new_coords = c(-0.07, 46.11),
#'   new_min_dbh = 5,
#'   new_max_dbh = 50,
#'   new_sample_size = 50
#' )
new_equations <- function(subset_taxa = "all",
                          subset_climate = "all",
                          subset_region = "all",
                          subset_ids = "all",
                          subset_output = c(
                            "Total aboveground biomass",
                            "Whole tree (above stump)"
                          ),
                          new_taxa = NULL,
                          new_allometry = NULL,
                          new_coords = NULL,
                          new_min_dbh = NULL,
                          new_max_dbh = NULL,
                          new_sample_size = NULL,
                          new_unit_dbh = "cm",
                          new_unit_output = "kg",
                          new_input_var = "DBH",
                          new_output_var = "Total aboveground biomass",
                          use_height_allom = TRUE) {
  ## open the equation table and get it in the right format ####
  equations_orig <- allodb::equations
  colnames(equations_orig) <- tolower(colnames(equations_orig))
  new_equations <- equations_orig

  suppressWarnings(new_equations$dbh_min_cm <-
    as.numeric(new_equations$dbh_min_cm))
  suppressWarnings(new_equations$dbh_max_cm <-
    as.numeric(new_equations$dbh_max_cm))
  suppressWarnings(new_equations$sample_size <-
    as.numeric(new_equations$sample_size))
  suppressWarnings(new_equations$dbh_unit_cf <-
    as.numeric(new_equations$dbh_unit_cf))
  suppressWarnings(new_equations$output_units_cf <-
    as.numeric(new_equations$output_units_cf))

  ## replace height with height allometry  ####
  ## from Bohn et al. 2014 in Jansen et al. 1996
  if (use_height_allom &
    "jansen_1996_otvb" %in% new_equations$ref_id) {
    eq_jansen <- subset(new_equations, ref_id == "jansen_1996_otvb")
    ## height allometries defined per genus -> get info in Jansen allometries
    eq_jansen$genus <-
      data.table::tstrsplit(eq_jansen$equation_notes, " ")[[5]]
    ## create height allometry dataframe
    hallom <-
      subset(
        new_equations,
        ref_id == "bohn_2014_ocai" &
          dependent_variable == "Height"
      )
    hallom <- hallom[, c("equation_taxa", "equation_allometry")]
    colnames(hallom) <- c("genus", "hsub")
    ## merge with jansen allometries (equations that do not have a corresponding
    ## height allometry will not be substituted)
    eq_jansen <- merge(eq_jansen, hallom, by = "genus")
    # substitute H by its DBH-based estimation
    to_merge <- eq_jansen[, c("hsub", "equation_allometry")]
    eq_jansen$equation_allometry <- apply(to_merge, 1, function(xx) {
      gsub("\\(h", paste0("((", xx[1], ")"), xx[2])
    })
    # replace independent_variable column
    eq_jansen$independent_variable <- "DBH"
    # replace in equation table
    new_equations <-
      rbind(
        subset(new_equations, !equation_id %in% eq_jansen$equation_id),
        eq_jansen[, colnames(new_equations)]
      )
  } else {
    new_equations <-
      subset(new_equations, independent_variable == "DBH")
  }

  ## subset equation table ####
  if (any(subset_taxa != "all")) {
    keep <- vapply(new_equations$equation_taxa, function(tax0) {
      any(vapply(subset_taxa, function(i) {
        grepl(i, tax0)
      }, FUN.VALUE = TRUE))
    }, FUN.VALUE = TRUE)
    new_equations <- new_equations[keep, ]
  }

  if (any(subset_climate != "all")) {
    keep <- vapply(new_equations$koppen, function(clim0) {
      any(vapply(subset_climate, function(i) {
        grepl(i, clim0)
      }, FUN.VALUE = TRUE))
    }, FUN.VALUE = TRUE)
    new_equations <- new_equations[keep, ]
  }

  if (any(subset_region != "all")) {
    keep <- vapply(new_equations$geographic_area, function(reg0) {
      any(vapply(subset_region, function(i) {
        grepl(i, reg0)
      }, FUN.VALUE = TRUE))
    }, FUN.VALUE = TRUE)
    new_equations <- new_equations[keep, ]
  }

  if (any(subset_ids != "all")) {
    new_equations <- subset(new_equations, equation_id %in% subset_ids)
  }

  new_equations <-
    subset(new_equations, dependent_variable %in% subset_output)

  ## add new equations ####
  # check that new allometry was added
  if (is.null(new_allometry) & (!is.null(new_taxa) | !is.null(new_coords))) {
    abort(c(
      "`new_allometry` must not be `NULL`",
      i = "Did you forget to add the new allometry?"
    ))
  }

  if (!is.null(new_allometry)) {
    ## check consistency of inputs
    if (is.null(new_taxa) |
      is.null(new_coords) |
      is.null(new_min_dbh) |
      is.null(new_max_dbh) |
      is.null(new_sample_size)) {
      abort(
        "You must provide the taxa, coordinates, DBH range
         and sample size of you new allometries."
      )
    }

    if (!is.numeric(new_min_dbh) |
      !is.numeric(new_max_dbh) | !is.numeric(new_sample_size)) {
      abort(
        "`new_min_dbh`, `new_max_dbh`, and `new_sample_size` must be numeric."
      )
    }

    if (is.matrix(new_coords)) {
      ncoords <- ncol(new_coords)
    } else {
      ncoords <- length(new_coords)
    }
    if (!is.numeric(new_coords) | ncoords != 2) {
      abort(
        "`coords` must be a numeric vector or matrix, with 2 values or columns."
      )
    }

    if (length(new_taxa) != length(new_allometry) |
      length(new_allometry) != length(new_min_dbh) |
      length(new_min_dbh) != length(new_max_dbh) |
      length(new_max_dbh) != length(new_sample_size)) {
      abort(c(
        "All of these arguments must have the same length:",
        "`new_taxa`",
        "`new_allometry`",
        "`new_min_dbh`",
        "`new_max_dbh`",
        "`new_sample_size`"
      ))
    }

    if (!is.character(new_allometry)) {
      abort("The equation allometry should be a character vector.")
    }
    if (any(grepl("=|<-", new_allometry))) {
      abort("`new_allometry` must be a function of dbh (e.g. '0.5 * dbh^2').")
    }
    dbh <- 10
    eval(parse(text = tolower(new_allometry)))

    if (!new_unit_dbh %in% c("cm", "mm", "inch")) {
      abort("`new_unit_dbh` must be in 'cm', 'mm' or 'inch'.")
    }

    if (!new_unit_output %in% c("g", "kg", "Mg", "lbs", "m")) {
      abort("`new_unit_output` must be 'g', 'kg', 'Mg' or 'lbs', or 'm'.")
    }

    if (new_output_var == "Height" & new_unit_output != "m") {
      abort("Height allometries outputs must be in 'm'.")
    }

    if (any(new_max_dbh <= new_min_dbh) |
      any(new_min_dbh < 0) |
      any(!is.numeric(new_min_dbh)) |
      any(!is.numeric(new_max_dbh))) {
      abort(
        "`new_max_dbh` must greater than `new_min_dbh` and both positive numbers"
      )
    }

    if (!is.matrix(new_coords)) {
      new_coords <-
        matrix(rep(new_coords, length(new_taxa)),
          ncol = 2,
          byrow = TRUE
        )
    }

    if (!is.numeric(new_coords) |
      !(ncol(new_coords) == 2 &
        nrow(new_coords) == length(new_taxa))) {
      abort(
        "new_coords must be a numeric vector of length 2 or
        a matrix with 2 columns (long, lat) and as many rows
        as the number of equations."
      )
    }

    if (any(new_coords[, 1] < -180 |
      new_coords[, 1] > 180 |
      new_coords[, 2] < -90 | new_coords[, 2] > 90)) {
      abort("Longitude must be between -180 and 180, and
           latitude between 90 and 0.")
    }

    new_allometry <- tolower(new_allometry)

    if (any(!grepl("dbh", new_allometry))) {
      abort("At least one of the new allometries does not
           contain DBH as a dependent variable.")
    }

    new_equation_id <- paste0("new", seq_len(length(new_taxa)))
    coords_eq <- cbind(
      long = new_coords[, 1],
      lat = new_coords[, 2]
    )
    rcoords_eq <- round(coords_eq * 2 - 0.5) / 2 + 0.25
    ## extract koppen climate of every location
      koppen_zones <- apply(rcoords_eq, 1, function(k) {
      subset(climatezones, Lon == k[1] & Lat == k[2])$Cls
    })
    koppen_zones <- as.character(unlist(koppen_zones))
    if (length(koppen_zones) != nrow(rcoords_eq)) {
      abort(
        "Impossible to find all koppen climate zones based
        on coordinates. Please check that they are Long, Lat."
      )
    }

    added_equations <- tibble::tibble(
      equation_id = new_equation_id,
      equation_taxa = new_taxa,
      equation_allometry = new_allometry,
      independent_variable = new_input_var,
      dependent_variable = new_output_var,
      long = new_coords[, 1],
      lat = new_coords[, 2],
      koppen = koppen_zones,
      dbh_min_cm = new_min_dbh,
      dbh_max_cm = new_max_dbh,
      sample_size = new_sample_size,
      dbh_units_original = new_unit_dbh,
      output_units_original = new_unit_output
    )

    new_equations <- rbind(
      added_equations,
      new_equations[, colnames(added_equations)]
    )

    ## add conversion factors
    dbh_cf <-
      unique(equations_orig[, c("dbh_units_original", "dbh_unit_cf")])
    output_cf <-
      unique(equations_orig[, c("output_units_original", "output_units_cf")])
    suppressWarnings(dbh_cf$dbh_unit_cf <-
      as.numeric(dbh_cf$dbh_unit_cf))
    suppressWarnings(output_cf$output_units_cf <-
      as.numeric(output_cf$output_units_cf))
    new_equations <- merge(new_equations, dbh_cf)
    new_equations <- merge(new_equations, output_cf)

    new_equations <- new_equations[, c(
      "equation_id",
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
      "dbh_unit_cf",
      "output_units_original",
      "output_units_cf"
    )]
  }

  return(tibble::as_tibble(new_equations))
}
