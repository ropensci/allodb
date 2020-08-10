#comparing allodb predicted data against raw data (vaidation data).

library(readxl)
valdata <-read_excel("tests/evaluation_of_equations/1-Validation data.xlsx")

#add Koppen zones to df (just in case)
valdata <- data.frame(valdata,
                      rndCoord.lon = RoundCoordinates(valdata$Longitude),
                      rndCoord.lat = RoundCoordinates(valdata$Latitude))
valdata <- data.frame(valdata,ClimateZ=LookupCZ(valdata))

## use get_biomass function
valdata$agb_allodb = get_biomass(dbh=valdata$DBH,
                              species = valdata$Species,
                              genus= valdata$Genus,
                              coords = cbind(valdata$Longitude, valdata$Latitude)/1000)

#I get the same warning 20 times and not agb values
warnings()

plot (valdata$Ptot, valdata$agb_allodb)

