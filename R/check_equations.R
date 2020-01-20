### Equations mismatches ###

library(data.table)
library(ggplot2)
library(plotly)

load("data/equations.rda")

equations = subset(equations, independent_variable == "DBH" & dependent_variable == "Total aboveground biomass")

# for now, remove problematic equation dc04c7
equations = subset(equations, equation_id != "dc04c7")

# transform columns to numeric
numeric_columns = c(
  "lat",
  "long",
  "elev_m",
  "dbh_min_cm",
  "dbh_max_cm",
  "sample_size",
  "dbh_unit_CF",
  "output_units_CF",
  "r_squared"
)
suppressWarnings(equations[, numeric_columns] <-
                   apply(equations[, numeric_columns], 2, as.numeric))

# remove NAs in dbh min and max
equations = subset(equations, !is.na(dbh_min_cm) & !is.na(dbh_max_cm))
equations = subset(equations, allometry_specificity %in% c("Genus", "Species"))
allom = list()
for (i in 1:nrow(equations)) {
  dbh = seq(equations$dbh_min_cm[i], min(equations$dbh_max_cm[i],200), length.out = 20)
  orig_equation = equations$equation_allometry[i]
  new_dbh = paste0("(dbh*", equations$dbh_unit_CF[i],")")
  new_equation = gsub("dbh|DBH", new_dbh, orig_equation)
  allom[[i]] = data.table(equ_id = equations$equation_id[i],
                          dbh, agb = eval(parse(text = new_equation)))
  # conversion to kg with output_units_CF, then tons
  allom[[i]]$agb = allom[[i]]$agb*equations$output_units_CF[i] *0.001
}
allom = rbindlist(allom)

## plot agb = f(dbh)
g = ggplot(allom, aes(x=dbh, y=agb, color=equ_id))  +
  geom_hline(yintercept = 0, lty=2) +
  stat_function(fun=function(x) exp(-2.023977 - 0.89563505 * 1.5 +
                                      0.92023559 * log(0.6) +
                                      2.79495823 * log(x) -
                                      0.04606298 * (log(x)^2))/1000, col=1)+
  geom_line() +
  theme(legend.position = 'none')

## zoom on small dbh values (between 0 and 35): a few equations start with agb < 0, e.g. 9f4b7d
gzoom = g + lims(x=c(0,10), y = c(-0.1, 0.1))
gzoom
p = ggplotly(g)
p
