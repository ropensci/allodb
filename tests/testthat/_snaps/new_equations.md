# w/ `new_taxa` and `NULL` `new_allometry` errors gracefully

    `new_allometry` must not be `NULL`
    i Did you forget to add the new allometry?

# with `new_allometry` and NULL `new_taxa` errors gracefully

    You must provide the taxa, coordinates, DBH range
             and sample size of you new allometries.

# with a `new_coords` 'matrix' 2x1 errors gracefully

    `coords` must be a numeric vector or matrix, with 2 values or columns.

# with arguments of different lenght errors gracefully

    All of these arguments must have the same length:
    * `new_taxa`
    * `new_allometry`
    * `new_min_dbh`
    * `new_max_dbh`
    * `new_sample_size`

---

    All of these arguments must have the same length:
    * `new_taxa`
    * `new_allometry`
    * `new_min_dbh`
    * `new_max_dbh`
    * `new_sample_size`

---

    All of these arguments must have the same length:
    * `new_taxa`
    * `new_allometry`
    * `new_min_dbh`
    * `new_max_dbh`
    * `new_sample_size`

---

    All of these arguments must have the same length:
    * `new_taxa`
    * `new_allometry`
    * `new_min_dbh`
    * `new_max_dbh`
    * `new_sample_size`

# if `new_allometry` isn't of type character errors gracefully

    The equation allometry should be a character vector.

# if `new_allometry` conains an assignment errors gracefully

    `new_allometry` must be a function of dbh (e.g. '0.5 * dbh^2').

---

    `new_allometry` must be a function of dbh (e.g. '0.5 * dbh^2').

# height must be in meters

    Height allometries outputs must be in 'm'.

---

    Height allometries outputs must be in 'm'.

# with bad coordinates errors gracefully

    Longitude must be between -180 and 180, and latitude between 90 and 0.

# with equation not a function of DBH errors gracefully

    Each new allometry must contain DBH as a dependent variable.

