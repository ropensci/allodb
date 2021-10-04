#' Illustrate the resampling of AGB values used in \pkg{allodb}.
#'
#' This function illustrates the resampling of AGB values used in \pkg{allodb}.
#' It creates objects of class "ggplot".
#'
#' @param genus A character value, containing the genus (e.g. "Quercus")
#' of the tree.
#' @param coords A numeric vector of length 2 with longitude and latitude.
#' @param species A character value, containing the species (e.g. "rubra") of
#' the tree. Default is `NULL`, when no species identification is available.
#' @param new_eqtable Optional. An equation table created with the
#'  `new_equations()` function. Default is the base \pkg{allodb}
#' equation table.
#' @param logxy Logical: should values be plotted on a log scale? Default is
#'   `FALSE`.
#' @param neq Number of top equations in the legend. Default is 10, meaning that
#'   the 10 equations with the highest weights are shown in the legend.
#' @param eqinfo Which column(s) of the equation table should be used in the
#' legend? Default is "equation_taxa".
#' @param wna a numeric vector, this parameter is used in the
#' `weight_allom()` function to determine the
#' dbh-related and sample-size related weights attributed to equations without
#' a specified dbh range or sample size, respectively. Default is 0.1.
#' @param w95 a numeric vector, this parameter is used in the
#' `weight_allom()` function to determine the
#' value at which the sample-size-related weight reaches 95% of its maximum
#' value (max=1). Default is 500.
#' @param nres number of resampled values. Default is "1e4".
#'
#' @return A ggplot showing all resampled dbh-agb values. The top equations used
#' are shown in the legend. The red curve on the graph represents the final
#'   fitted equation.
#'
#' @seealso [weight_allom()], [new_equations()]
#'
#' @export
#'
#' @examples
#' illustrate_allodb(
#'   genus = "Quercus",
#'   species = "rubra",
#'   coords = c(-78.2, 38.9)
#' )
#'
illustrate_allodb <- function(genus,
                              coords,
                              species = NULL,
                              new_eqtable = NULL,
                              logxy = FALSE,
                              neq = 10,
                              eqinfo = "equation_taxa",
                              wna = 0.1,
                              w95 = 500,
                              nres = 1e4) {
  dfagb <-
    resample_agb(
      genus = genus,
      coords = coords,
      species = species,
      new_eqtable = new_eqtable,
      wna = wna,
      w95 = w95,
      nres = nres
    )
  params <-
    est_params(
      genus = genus,
      coords = coords,
      species = species,
      new_eqtable = new_eqtable,
      wna = wna,
      w95 = w95,
      nres = nres
    )
  pred <- function(x) params$a * x ** params$b

  if (is.null(new_eqtable)) {
    equations <- new_equations()
  } else
    equations <- new_eqtable

  ## get equation info
  eq_info <- apply(equations[, c("equation_id", eqinfo)], 1,
                   function(x)
                     paste(x, collapse = " - "))
  eq_info <-
    tibble::tibble(equation_id = equations$equation_id, equation = eq_info)

  data <- table(equation_id = dfagb$equation_id)
  dfcounts <- tibble::tibble(equation_id = names(data), Freq = unname(data))

  eq_info <- merge(eq_info, dfcounts, by = "equation_id")
  eq_info <- eq_info[order(eq_info$Freq, decreasing = TRUE), ]
  eq_info[(neq + 1):nrow(eq_info), "equation"] <- "other"
  eq_info$equation <-
    factor(eq_info$equation, levels = unique(eq_info$equation))
  dfagb <- merge(dfagb, eq_info, by = "equation_id")

  g <- ggplot2::ggplot(dfagb, ggplot2::aes(x = dbh, y = agb)) +
    ggplot2::geom_point(data = subset(dfagb, equation == "other"),
                        alpha = 0.2) +
    ggplot2::geom_point(data = subset(dfagb, equation != "other"),
                        ggplot2::aes(col = equation)) +
    ggplot2::stat_function(
      fun = pred,
      lwd = 2,
      col = 2,
      lty = 2
    ) +
    ggplot2::theme_classic() +
    ggplot2::labs(x = "DBH (cm)",
                  y = "AGB (kg)",
                  colour = "Top resampled equations")
  if (logxy) {
    g <- g +
      ggplot2::scale_x_log10() +
      ggplot2::scale_y_log10()
  }
  g
}
