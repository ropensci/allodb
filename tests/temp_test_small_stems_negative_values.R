library(ggplot2)
library(data.table)
library(ggpubr)
library(allodb)

data(scbi_stem1)

data = data.table(expand.grid(dbh=(1:20)/2,
                  name = unique(paste(scbi_stem1$genus,
                                      scbi_stem1$species))))
data$genus = tstrsplit(data$name, " ")[[1]]
data$species = tstrsplit(data$name, " ")[[2]]

data$agb = get_biomass(
  dbh = data$dbh,
  genus = data$genus,
  species = data$species,
  coords = c(-78.2, 38.9)
)
sum(data$agb<0)

## non monotonic
data = setorder(data, name, dbh)
which_nonmon = subset(data[, .(non_mon = any(diff(agb) < 0)), .(name)], (non_mon))
data_nonmon = merge(data, which_nonmon[, -"non_mon"], by = c("name"))
ggplot(data_nonmon, aes(x = dbh, y = agb, color = name)) + geom_line()

df = data.frame(dbh = seq(0.25, 2, 0.1),
                genus = "Rubus",
                species = "phoenicolasius")
agb_weight = get_biomass(
  dbh = df$dbh,
  genus = "Rubus",
  species = "phoenicolasius",
  coords = c(-78.2, 38.9), add_weight = TRUE
)
df$agb = agb_weight[, 1]
weight = agb_weight[, -1]
totalW = colSums(weight, na.rm=TRUE)

# ## first 5 equations
weightMax = weight[,order(totalW, decreasing = T)[1:5]]
dt = melt(data.table(dbh = df$dbh, weightMax), id.vars = "dbh", variable.name = "equationID", value.name = "weight")
dt = merge(dt, equations[, c("equation_id", "equation_taxa", "dbh_min_cm", "dbh_max_cm", "koppen")],
           by.x = "equationID", by.y = "equation_id")
dt[, `:=`(dbh_min_cm = as.numeric(dbh_min_cm), dbh_max_cm = as.numeric(dbh_max_cm))]
DFtaxaID = unique(dt[, c("equationID", "equation_taxa")])
equationTaxaID = sapply(colnames(weightMax), function(j)
  paste(j, DFtaxaID$equation_taxa[DFtaxaID$equationID == j], sep=" - "))
dt$equationTaxaID = factor(paste(dt$equationID, dt$equation_taxa, sep=" - "), levels = equationTaxaID)

g = ggplot(df, aes(x=dbh, y=agb)) +
  geom_line() +
  theme_bw() +
  theme(legend.position = "none") +
  labs(y="AGB (tons)", x = "DBH (cm)")
w = ggplot(dt, aes(x=dbh, y = equationTaxaID, fill=weight)) +
  geom_raster() +
  lims(x = range(dt$dbh)) +
  scale_fill_gradientn(colours = rev(terrain.colors(10))) +
  geom_point(aes(x=dbh_min_cm), col="blue") +
  geom_point(aes(x=dbh_max_cm), col="red") +
  labs(x="DBH (cm)", y = "")
ggarrange(g, w, widths = c(1,2))
ggsave("tests/graphs/test_non_monotonic_allometries_scbi.pdf", height = 2, width=10)

curve(29.615*((1.488+1.195*x)^3.243)*1e-3, xlim=c(0.5, 6), xlab = "DBH (cm)", ylab = "AGB (Mg)", lty=2)
curve(0.041*((1.488+1.195*x)^2.649), add=TRUE, lty=2, col=2)
curve(29.615*((1.488+1.195*x)^3.243)*1e-3, add=TRUE, xlim=c(0.28, 1.59), lw=2)
curve(0.041*((1.488+1.195*x)^2.649), add=TRUE, xlim=c(5.5, 31), col=2, lw=2)
