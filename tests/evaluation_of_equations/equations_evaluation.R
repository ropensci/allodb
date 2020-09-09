# October 8, 2019
# Scrip to evaluate equations and how they behave above their dbh range.

load("data/equations.rda")

species <- "Tilia americana" # change sp name to produce a new graph
other_taxa_to_add <- "Hippocastanaceae, Tiliaceae" # add other taxa not a sp level

DBH <- c(1:100)

names(equations)

sp_sub <- subset(equations, equation_taxa == species | equation_taxa == other_taxa_to_add)
sp_sub <- sp_sub[c(1, 2, 3, 4), ] # replace the number by the row IDs that you want to see in the plot


agb <- matrix(NA, nrow = length(DBH), ncol = (nrow(sp_sub)))


for (i in 1:nrow(sp_sub)) {
  dbh <- DBH
  dbh <- dbh * as.numeric(sp_sub$dbh_unit_convert[i])
  agb[, i] <- eval(parse(text = sp_sub$equation_allometry[i])) * as.numeric(sp_sub$units_original_convert[i])
}

png(paste0("evaluation_of_equations/", species, ".png"))

for (i in 1:nrow(sp_sub)) {
  col <- rainbow(nrow(sp_sub))[i]
  if (i == 1) {
    plot(agb[, i] ~ DBH,
      type = "l", lty = 2, ylim = c(0, max(agb[, -1])), main = species,
      col = col,
      ylab = "AGB",
      las = 1
    )
  }
  if (i != 1) lines(agb[, i] ~ DBH, lty = 2, col = col)
  # dotted lines are prediction aoutdide the dbh range
  min_dbh <- as.numeric(sp_sub$dbh_min_cm[i])
  max_dbh <- as.numeric(sp_sub$dbh_max_cm[i])
  idx_range_DBH <- DBH >= min_dbh & DBH <= max_dbh
  agb_sub <- agb[idx_range_DBH, ]
  lines(agb_sub[, i] ~ DBH[idx_range_DBH], col = col)
}

legend("topleft",
  col = rainbow(nrow(sp_sub)),
  lty = 1,
  legend = paste(
    sp_sub$ref_id,
    sp_sub$allometry_specificity,
    "n=", sp_sub$sample_size,
    "min=", sp_sub$dbh_min_cm,
    "max=", sp_sub$dbh_max_cm
  ),
  bty = "n",
  cex = 0.8
)

dev.off()
