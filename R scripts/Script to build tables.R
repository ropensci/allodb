#Dec 20, 2017
#Erika Gonzalez-Akre
#Last update : 01/23/2018
#This simple script is used to build 4 tables for the ForestGEO allometry datapaper

#read.csv file, which could be modified. allotemp_main.cvs resides in 'data" folder in Git.
master<-read.csv("allotemp_main.csv")
#eliminate rows where fam or sp is unknown #use unique(allo_main$species)
master<-subset(master, master$family !="Unkown")
#chnage name of "equation" column to "equation_form"

#Currently, we think 5 tables will go to the paper
#table 1: Basic info ForestGEO sites (could be modified from forestgeo/Site-Data repository)
#table 2: Site-species (includes non-tropical sites, links to equation table with eq Id)
#table 3: Allometric equations (doesn't include sites, but sp? not sure)
#table 4: Wood density (with this scrip and master table we only take wsg for temperate sites, later to be merge with trop)
#table 5: References (links to wood density table with an id, my raw reference table includes sites for my own sanity!) 

#table2
names(master)
sitespecies<-master[c(1:5,23,19,20)]

#table3, needs to include a column after'equation_form' to combine coeficienss+formula so we get
#..."unique" equations, then give unique id
equations<-master[c(20,23,18,16,24,25,26,13,14,17,7,21,22,28 )]  

#table4
wd<-master[c(1:3,6,7,8,30)]
