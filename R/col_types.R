#' Help to read datasets safely, with consistent column type.
#'
#' For details see [https://forestgeo.github.io/fgeo.tool/reference/type_fgeo].
#'
#' Types' reference (see [readr::read_csv()].
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
#'
#' @export
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
    n_trees = 'i',
    dbh_units_original = 'c',
    biomass_units_original = 'c',
    allometry_development_method = 'c',
    equation_id = 'c',
    equation = 'c',
    equation_grouping = 'c',
    model_parameters = 'c',
    regression_model = 'c',
    other_equations_tested = 'c',
    log_biomass = 'c',
    bias_corrected = 'c',
    bias_correction_factor = 'c',
    notes_fitting_model = 'c',
    biomass_component = 'c',
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
