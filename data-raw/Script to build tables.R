# Build the core tables of the data paper.

master <- read.csv("allotemp_main.csv")
# eliminate rows where fam or sp is unknown #use unique(allo_main$species)
master <- subset(master, master$family != "Unkown")
# chnage name of "equation" column to "equation_form"

# Basic info ForestGEO sites (could be modified from
# forestgeo/Site-Data repository).



# TODO: Add table. See https://goo.gl/ic7uya.



# Site-species (includes non-tropical sites, links to equation table
# with eq Id).
names(master)
sitespecies <- master[c(1:5, 23, 19, 20, 24, 6, 7)]
names(sitespecies)
write.csv(sitespecies, file = "sitespecies.csv", row.names = FALSE)

# Allometric equations (doesn't include sites, but sp? not sure)
# Needs to include a column after'equation_form' to combine
# coeficienss+formula so we get "unique" equations, then give unique id
equations <- master[c(20, 23, 18, 24, 25, 26, 13:16, 17, 21, 22, 28)]
names(equations)
write.csv(equations, file = "equations.csv", row.names = FALSE)

# Wood density (with this scrip and master table we only take wsg for
# temperate sites, later to be merge with trop).
# Right now this table may look incomplete.
wsg <- master[c(7, 2, 3, 6, 8, 30, 1)]
names(wsg)
write.csv(wsg, file = "wood_density.csv", row.names = FALSE)

# References (links to wood density table with an id, my raw reference
# table includes sites for my own sanity!).



# TODO: Add table.



