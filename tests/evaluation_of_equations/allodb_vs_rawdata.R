#comparing allodb predicted data against raw data (vaidation data).

library(readxl)
library(kgc)
library(allodb)
library(ggplot2)
library(ggpubr)
library(plotly)

valdata <-read_excel("tests/evaluation_of_equations/1-Validation data.xlsx")
## the coordinates of the islands of Izu fall in the sea, which is why they don't have any Koppen climate zone
## I changed them to the coordinates of one of the Izu islands that's the closest to that point and has koppen values
valdata$Longitude[valdata$Location == "The islands of Izu"] <- 139.271
valdata$Latitude[valdata$Location == "The islands of Izu"] <- 34.507
## the latitdue of Jerezi, CZE is completely off
valdata$Latitude[valdata$Location == "Jezeri"] <- 50.55

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

## TODO need to solve zero value problem
## I think the problem is becasue the coords lay on the water. Wating for original pub from the library to correct them.

# plot results
val = ggplot(valdata, aes(x = Ptot, y = agb_allodb)) +
  geom_abline(slope=1, intercept=0, lty=2) +
  geom_point(size=1)

#Change label of axis
val = val +  xlab("True AGB (kg)") + ylab("Predicted AGB (kg)")
val
val + geom_smooth()
## we seem to be underestimating large stems with allodb compared to this validation dataset
val + scale_x_log10() + scale_y_log10() + geom_smooth()
## not too bad for small to medium stems, very small stems seem to be slightly overestimated

#check values by moving mouse on graph
ggplotly(val)

sum(valdata$Ptot)
sum(valdata$agb_allodb)

### RMSE
RMSE_allodb = sqrt(sum((valdata$Ptot-valdata$agb_allodb)**2)/nrow(valdata))

## TODO add for example chave equation
