#' Help to read datasets safely.
#'
#' Reading the master table with this funcion ensures the following:
#' * Missing values are consistent with `allodb::missing_values_metadata`
#' * Columns have the type we expect, consistent with type_allodb_master().
#' @keywords internal
read_master <- function(file) {
  na_kinds <- unique(c("", allodb::missing_values_metadata$Code))
  readr::read_csv(file, col_type = type_allodb_master(), na = c("", na_kinds))
}

#' Helper of read_master().
#'
#' For details see [`fgeo.tool::type_fgeo()`](https://goo.gl/gVSMT8).
#'
#' Types' reference (see [`readr::read_csv()`](https://goo.gl/DtDvXq).
#' * c = character.
#' * i = integer.
#' * n = number.
#' * d = double.
#' * l = logical.
#' * D = date.
#' * T = date time.
#' * t = time.
#' * ? = guess.
#' * _/- to skip the column.
#' @keywords internal
type_allodb_master <- function() {
  list(
    site = 'c',
    family = 'c',
    species = 'c',
    species_code = 'c',
    life_form = 'c',
    wsg = 'c',
    wsg_id = 'c',
    wsg_specificity = 'c',
    a = 'd',
    b = 'd',
    c = 'd',
    d = 'd',
    dbh_min_cm = 'c',
    dbh_max_cm = 'c',
    sample_size = 'i',
    dbh_units_original = 'c',
    biomass_units_original = 'c',
    allometry_development_method = 'c',
    site_dbh_unit = 'c',
    equation_id = 'c',
    equation_form = 'c',
    equation_allometry = 'c',
    equation_grouping = 'c',
    independent_variable = 'c',
    regression_model = 'c',
    other_equations_tested = 'c',
    log_biomass = 'c',
    bias_corrected = 'c',
    bias_correction_factor = 'c',
    notes_fitting_model = 'c',
    dependent_variable_biomass_component = 'c',
    allometry_specificity = 'c',
    development_species = 'c',
    geographic_area = 'c',
    biomass_equation_source = 'c',
    ref_id = 'c',
    wsg_source = 'c',
    ref_wsg_id = 'c',
    original_data_availability = 'c',
    notes_to_consider = 'c',
    warning = 'c'
  )
}

