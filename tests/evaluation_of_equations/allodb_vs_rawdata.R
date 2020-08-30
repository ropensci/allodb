#comparing allodb predicted data against raw data (vaidation data).

library(readxl)
library(kgc)
library(allodb)
library(ggplot2)
library(ggpubr)
library(plotly)
library(data.table)


valdata <-read_excel("tests/evaluation_of_equations/1-Validation data.xlsx")

valdata = read_excel("tests/evaluation_of_equations/new_val.xlsx")
## the coordinates of the islands of Izu fall in the sea, which is why they don't have any Koppen climate zone
## I changed them to the coordinates of one of the Izu islands that's the closest to that point and has koppen values
valdata$Longitude[valdata$Location == "The islands of Izu"] <- 139.271
valdata$Latitude[valdata$Location == "The islands of Izu"] <- 34.507
## the latitdue of Jerezi, CZE is completely off
valdata$Latitude[valdata$Location == "Jezeri"] <- 50.55
## the longitud of Brandon, GRB were off
valdata$Longitude[valdata$Location == "Brandon"] <- 0.66
valdata$Longitude[valdata$Location == "England: Brandon"] <- 0.66


#add Koppen zones to df (just in case)
valdata <- data.frame(valdata,
                      rndCoord.lon = RoundCoordinates(valdata$Longitude),
                      rndCoord.lat = RoundCoordinates(valdata$Latitude))
valdata <- data.frame(valdata,ClimateZ=LookupCZ(valdata))

## use get_biomass function
valdata$agb_allodb = get_biomass(dbh=valdata$DBH,
                              species = valdata$Species,
                              genus= valdata$Genus,
                              coords=cbind(valdata$Longitude, valdata$Latitude))

# plot results
val = ggplot(valdata, aes(x = Pabo, y = agb_allodb)) +
  geom_abline(slope=1, intercept=0, lty=2) +
  geom_point(size=1)

#Change label of axis
val = val +  xlab("True AGB (kg)") + ylab("Predicted AGB (kg)")
val
val= val + geom_smooth() + theme_classic()
## we seem to be underestimating large stems with allodb compared to this validation dataset
val_log= val + scale_x_log10() + scale_y_log10() + geom_smooth() + theme_classic()
## not too bad for small to medium stems, very small stems seem to be slightly overestimated

#combine plots in one figure
ggarrange(val, val_log,
          labels = c("A", "B"),
          ncol = 1, nrow = 2)

#check values by moving mouse on graph
ggplotly(val)

sum(valdata$Pabo)
sum(valdata$agb_allodb)

### RMSE
RMSE_allodb = sqrt(sum((valdata$Pabo-valdata$agb_allodb)**2)/nrow(valdata))
RMSE_allodb_log = sqrt(sum((log(valdata$Pabo)-log(valdata$agb_allodb))**2)/nrow(valdata))

## TODO add for example chave equation
WD = BIOMASS::getWoodDensity(genus = valdata$Genus,
                             species = data.table::tstrsplit(valdata$Species, " ")[[2]])
valdata$wsg = WD$meanWD
valdata$agb_chave = BIOMASS::computeAGB(D = valdata$DBH,
                                        WD = valdata$wsg,
                                        coord = cbind(valdata$Longitude, valdata$Latitude))
ggplot(valdata, aes(x = Pabo, y = agb_chave*1000)) +
  geom_abline(slope=1, intercept=0, lty=2) +
  geom_point(size=1)

## chave 2014 does not work well outside the tropics because the E parameter depends heavily on the
## temperature seasonality, which is low in the tropics but high elsewhere

## try chave 2005 for moist tropical forests

## try chojnacky 2014
## get family
data("genus_family")
valdata = merge(valdata, genus_family, by.x = "Genus", by.y = "genus", all.x = TRUE)

source("tests/evaluation_of_equations/chojnackyParams.R")
valdata = data.table(valdata, chojnackyParams(valdata$family, valdata$Genus, valdata$wsg))

valdata[, agb_choj := exp(V1 + V2*log(DBH))]

ggplot(valdata, aes(x = Pabo, y = agb_choj)) +
  geom_abline(slope=1, intercept=0, lty=2) +
  geom_point(size=1)
RMSE_choj = sqrt(sum((valdata$Pabo-valdata$agb_choj)**2)/nrow(valdata))

## allodb performs better than chojnacky!!
