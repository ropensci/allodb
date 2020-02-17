library(data.table)

koppen = c('Af', 'Am', 'As', 'Aw', 'BSh', 'BSk', 'BWh', 'BWk', 'Cfa', 'Cfb','Cfc', 'Csa', 'Csb', 'Csc', 'Cwa','Cwb', 'Cwc', 'Dfa', 'Dfb', 'Dfc','Dfd', 'Dsa', 'Dsb', 'Dsc', 'Dsd','Dwa', 'Dwb', 'Dwc', 'Dwd')

koppen_dist_0 = read.csv("data/koppen_krista.csv")

## transform distance matrix into data.table
koppen_dist = melt(data.table(koppen_dist_0))
colnames(koppen_dist) = c("zone1T", "zone2T", "simil")
koppen_dist[is.na(simil), simil := simil[zone1T]]

## add moisture letter
koppen_dist2 = expand.grid(zone1 = koppen, zone2 = koppen)
moisture_letters = paste(unique(substr(koppen, 2,2)), collapse = "|")
# temperature (1st and 3rd letter)
koppen_dist2$zone1T = gsub(moisture_letters, "_", koppen_dist2$zone1)
koppen_dist2$zone2T = gsub(moisture_letters, "_", koppen_dist2$zone2)
# moisture (2nd letter)
koppen_dist2$zone1M = substr(koppen_dist2$zone1, 2, 2)
koppen_dist2$zone2M = substr(koppen_dist2$zone2, 2, 2)

koppenMatrix = merge(koppen_dist, koppen_dist2, by = c("zone1T", "zone2T"))
## add 1/3 to similarity when same zone
koppenMatrix[zone1M==zone2M, simil := simil + 1/3]
koppenMatrix = koppenMatrix[, c("zone1", "zone2", "simil")]

## TODO add B__ climate zones
missing = koppen[!koppen %in% unique(koppenMatrix$zone1)]
koppenMatrix = rbind(koppenMatrix, data.table(zone1 = missing, zone2=missing, simil=1))

# koppen = dcast(koppen_dist, zone1 ~ zone2)
# write.csv(koppen, file = "data/koppen_dist.csv")

save(koppenMatrix, file = "data/koppenMatrix.rda")



### new method

koppen = c('Af', 'Am', 'As', 'Aw',
           'BSh', 'BSk', 'BWh', 'BWk',
           'Cfa', 'Cfb','Cfc', 'Csa', 'Csb', 'Csc', 'Cwa','Cwb', 'Cwc',
           'Dfa', 'Dfb', 'Dfc','Dfd', 'Dsa', 'Dsb', 'Dsc','Dwa', 'Dwb', 'Dwc', 'Dwd', 'ET', 'EF')

df = data.table(expand.grid(zone1 = koppen, zone2 = koppen, simil = 0))

## break into letters
df[, group1 := substr(zone1, 1, 1)]; df[, group2 := substr(zone2, 1, 1)]
df[, prec1 := substr(zone1, 2, 2)]; df[, prec2 := substr(zone2, 2, 2)]
df[, heat1 := substr(zone1, 3, 3)]; df[, heat2 := substr(zone2, 3, 3)]

Wgroup = 0.4; Wprec = 0.3; Wheat = 0.3

# if same group (first letter): add Wgroup
df[group1==group2]$simil = Wgroup
# C and D are more similar: add Wgroup/2
df[(group1=="C" & group2=="D") |
     (group2=="C" & group1=="D")]$simil = Wgroup/2

# precipitation
# gradients - tropical: f,m,w,s  // temperate+cold: f,w,s
## for groups A, C and D: add Wprec if same precipitation,
## and decrease by 0.1 when getting further away on the precipitation gradient
df$prec1 = as.numeric(factor(df$prec1, levels = c("f", "m", "w", "s", "W", "S", "F", "T")))
df$prec2 = as.numeric(factor(df$prec2, levels = c("f", "m", "w", "s", "W", "S", "F", "T")))
df[simil > 0 & group1 %in% c("A", "C", "D") & abs(prec1-prec2)*0.1 < Wprec,
   simil := simil + Wprec - abs(prec1-prec2)*0.1]
# for groups B and E: add Wprec only if it is the same precipitation level
df[simil > 0 & group1 %in% c("B", "E") & prec1==prec2, simil := simil + Wprec]

# temperature
# gradient - temperate+cold: a,b,c,d
## for groups C and D: add Wprec if same heat,
## and decrease by 0.1 when getting further away on the heat gradient
df$heat1 = as.numeric(factor(df$heat1))
df$heat2 = as.numeric(factor(df$heat2))
df[simil > 0 & group1 %in% c("C", "D") & abs(heat1-heat2)*0.1 < Wheat,
   simil := simil + Wheat - abs(heat1-heat2)*0.1]
# for groups A, B and E: add Wheat when the same precipitation level is the same
df[simil > 0 & group1 %in% c("A", "B", "E") & heat1==heat2, simil := simil + Wheat]

koppenMatrix = df[, c("zone1", "zone2", "simil")]

koppen = dcast(koppenMatrix, zone1 ~ zone2)
write.csv(koppen, file = "data/new_koppen_dist.csv")

save(koppenMatrix, file = "data/koppenMatrix.rda")

