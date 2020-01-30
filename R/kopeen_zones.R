install.packages("kgc")
library(kgc)

allodb<- read.csv("https://raw.githubusercontent.com/forestgeo/allodb/master/data-raw/csv_database/equations.csv", stringsAsFactors = FALSE, na.strings=c(NA,"NA"," NA"))

#get 3 columns format (site, long, lat)
library(dplyr)
allodb<-select (allodb, equation_id,lat, long)


#convert character to numeric
allodb$lat <- as.numeric(as.character(allodb$lat))
allodb$long <- as.numeric(as.character(allodb$long))


str(allodb)

#need this part of the ocde, but not in equation table..
allodb <- data.frame(allodb,
                   rndCoord.lon = RoundCoordinates(allodb$long),
                   rndCoord.lat = RoundCoordinates(allodb$lat))

#This function will return the climate zone for the coordinates provided.
allodb <- data.frame(allodb,ClimateZ=LookupCZ(allodb))

#add to allodb (euqations table)