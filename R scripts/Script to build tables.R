#Dec 20, 2017
#Erika Gonzalez-Akre
#Last update : Dec 20, 2017
#This simple script is used to build 4 tables for the ForestGEO allometry datapaper

#read.csv file, which could be modified. allotemp_main.cvs resides in 'data" folder in Git.
allo_main<-read.csv("allotemp_main.csv")
#eliminate rows where fam or sp is unknown #use unique(allo_main$species)
allo_main<-subset(allo_main, allo_main$family !="Unkown")
#chnage name of "equation" column to "equation_form"

#Currently, we think 5 tables will go to the paper
#table 1: Basic info ForestGEO sites (could be modified from girthub repository)
#table 2: Site-species (includes non-tropical sites, links to equation table with eq Id)
#table 3: Allometric equations (doesn't include sites, but sp? not sure)
#table 4: Wood density (do we actually have to publish these here? it seems that data is everywhere) 
#table 5: References (links to wood density table with an id, my raw reference table includes sites for my own sanity!) 

#table2
names(allo_main)
table2<-allo_main[c(1:5,16 )]

#table 3, needs to include a column after'equation_form' to combine coeficienss+formula so we get
#..."unique" equations, then give unique id
table3<-allo_main[c(16, 15, 11:14, 19:22 )]  

