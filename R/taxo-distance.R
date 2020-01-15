######################################################
# Purpose: calculate phylogenetic distances for allodb
# prep by: Erika Gonzalez-Akre. Dec 2019.
# This is a work in progress
#######################################################

#install.packages("ape")
#install.packages("brranching")
#install.packages("phytools")
#install.packages("maps")
#install.packages("adephylo")
#install.packages("ade4")
#install.packages("tidyverse")
library(tidyverse)
library(tidyselect)
library(ape)
library(brranching)
library(phytools)
library(maps)
library(adephylo)
library(ade4)
#install.packages("V.PhyloMaker") --this didn't work
#so install github version
install.packages("remotes")
remotes::install_github("jinyizju/V.PhyloMaker")
#also read this: https://github.com/jinyizju/S.PhyloMaker
#for plotting: #http://www.phytools.org/anthrotree/plot/



#We need to construct a tree to find the evolutionary distance between species
#use function `phylomatic` to create a phylogenetic tree in pack-brranching
p <- c("Quercus alba","Castanea dentata", "Liriodendron tulipifera", "Abies alba", "Acer rubrum")
tree <- phylomatic(taxa=p, get = 'POST')
plot(tree, no.margin=TRUE)
str(tree)

#but this tree has no edge.lenght (or branch lenght) therefore we cannot calculate distance
#edge.lenght=a numeric vector giving the lengths of the branches given by edge

#so use the function "modified.Grafen(tree, power=2)" from pack-phytools to compute edge lenghts 
tree<-modified.Grafen(tree, power=2)
node.paths(tree, node)#this could give an error (Error in Children(x, node) : object 'node' not found) but keep going
str(tree)

#Now use the fuction "cophenetic" from the pack-ape to calculate pairwise distance 
#between the pairs of tips from a phylogenetic tree using its branch lengths
#dist.nodes does the same but between all nodes, internal and terminal, of the tree

cophenetic(tree)
dist.nodes(tree)

#We can also calculate different set of distances using the function 'distTips' fomr the pack-adephylo
#see the vignette for explanation: https://rdrr.io/cran/adephylo/man/distTips.html
distTips(tree, 1:3)
distTips(tree, 1:3, "nNodes")
distTips(tree, 1:3, "Abouheif")
distTips(tree, 1:3, "sumDD")

# and we can plot the tree with distances
plotTree(tree, fsize=1,lwd=1, offset=1)
#the offset argument moves the names a bit to the right
edgelabels(round(tree$edge.length,3),cex=0.7, bg = "yellow")

#tiplabels()
#nodelabels()

#or plot it as fan
plotTree(tree,type="fan")

###################################################
#using scbi as example
scbi<-read.csv ("scbi.spptable.csv", stringsAsFactors = FALSE)
scbtree <- phylomatic(taxa=scbi$Latin, get = 'GET')
plot(scbtree, no.margin=TRUE)
str(scbtree)
scbtree$node.label

scbtree<-modified.Grafen(scbtree, power=2)
cophenetic(scbtree)
dist.nodes(scbtree)

plotTree(scbtree,ftype="i",fsize=0.8,lwd=1, offset=2)
#apply edge lenght labels
edgelabels(round(scbtree$edge.length,3),cex=0.6, bg = "yellow")



###########################Ideas discussed on Dec 5 for allodb #########
###Build a tree for equation table
#we need to use "allometry_specificity" to built trees based on fam, or genus, or species


equations<-read.csv ("equations.csv")
#check unique values for allometry_specificity
unique(equations$allometry_specificity)

#as an example, lets create a dataframe for wich allometry_specifity is family
eq_fam<-filter(equations, allometry_specificity == "Family")
#check unique family names in dataframe
unique(eq_fam$equation_taxa)

#create a tree for families
eqfam <- c("Betulaceae","Cornaceae", "Ericaceae", "Lauraceae", "Platanaceae", "Rosaceae", "Ulmaceae", "Cupressaceae",
         "Fagaceae", "Hamamelidaceae", "Hippocastanaceae", "Tiliaceae", "Magnoliaceae", "Oleaceae", "Salicaceae",
         "Sapindaceae", "Fabaceae", "Pinaceae" )

#But if you run this "as it" from the eq table, you get an error becasue i.e. Tiliaceae is not accepted name anymore,
#or Hippocastanaceae.So Replaced by Malvaceae and Sapindaceae, respectively
eqfam <- c("Betulaceae","Cornaceae", "Ericaceae", "Lauraceae", "Platanaceae", "Rosaceae", "Ulmaceae", "Cupressaceae",
         "Fagaceae", "Hamamelidaceae", "Sapindaceae", "Malvaceae", "Magnoliaceae", "Oleaceae", "Salicaceae",
         "Sapindaceae", "Fabaceae", "Pinaceae" )

eqfamtree <- phylomatic(taxa=eqfam, get = 'POST')
plot(eqfamtree, no.margin=TRUE)
#apply edge lenght labels
edgelabels(round(eqfamtree$edge.length,3,cex=0.6))

#calculate distance then plot again
eqfamtree<-modified.Grafen(eqfamtree, power=2)
cophenetic(eqfamtree)
dist.nodes(eqfamtree)



#now get unique family names from scbi to buil a family tree 
unique(scbi$Family)
scbifam <-c(unique(scbi$Family)) #build a vector with scbi families
scbifamtree <- phylomatic(taxa=scbifam, get ='POST') #for some reason thsi exclude rosaceae and ericaceae
plot(scbifamtree)

#use "cophenetic" to calculate pairwise distance 
scbifamtree<-modified.Grafen(scbifamtree, power=2)
cophenetic(scbifamtree)
       