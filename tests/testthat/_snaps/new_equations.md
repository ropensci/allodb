# w/ `new_taxa` and `NULL` `new_allometry` errors gracefully

    You might have forgotten to add the new allometry.

# with `new_allometry` and NULL `new_taxa` errors gracefully

    You must provide the taxa, coordinates, DBH range
             and sample size of you new allometries.

# with a `new_coords` 'matrix' 2x1 errors gracefully

    coords should be a numeric vector or matrix,
                with 2 values or 2 columns.

# with arguments of different lenght errors gracefully

    new_taxa, new_allometry, new_min_dbh, new_max_dbh and
            new_sample_size must all be the same length.

---

    new_taxa, new_allometry, new_min_dbh, new_max_dbh and
            new_sample_size must all be the same length.

---

    new_taxa, new_allometry, new_min_dbh, new_max_dbh and
            new_sample_size must all be the same length.

---

    new_taxa, new_allometry, new_min_dbh, new_max_dbh and
            new_sample_size must all be the same length.

# if `new_allometry` isn't of type character errors gracefully

    The equation allometry should be a character
               vector.

# if `new_allometry` conains an assignment errors gracefully

    new_allometry should should be written as a
               function of DBH  (e.g. '0.5 * dbh ^ 2').

---

    new_allometry should should be written as a
               function of DBH  (e.g. '0.5 * dbh ^ 2').

# height must be in meters

    Height allometries outputs must be in m.

---

    Height allometries outputs must be in m.

# with bad coordinates errors gracefully

    Longitude must be between -180 and 180, and
               latitude between 90 and 0.

# with equation not a function of DBH errors gracefully

    At least one of the new allometries does not
               contain DBH as a dependent variable.

