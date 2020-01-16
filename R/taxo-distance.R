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
#install.packages("RCurl")
library(tidyverse)
library(tidyselect)
library(ape)
library(brranching)
library(phytools)
library(maps)
library(adephylo)
library(ade4)
library(RCurl)
library(data.table)

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

cophenetic(tree) #same as cophenetic.phylo(tree)
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
#using scbi species table as example
scbi<- read.csv("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/scbi.spptable.csv", stringsAsFactors = FALSE)

scbtree <- phylomatic(taxa=scbi$Latin, get = 'GET')
plot(scbtree, no.margin=TRUE)
str(scbtree)
scbtree$node.label

#now add distances as above
scbtree<-modified.Grafen(scbtree, power=2)
cophenetic(scbtree)
dist.nodes(scbtree)

plotTree(scbtree,ftype="i",fsize=0.8,lwd=1, offset=2)
#apply edge lenght labels
edgelabels(round(scbtree$edge.length,3),cex=0.6, bg = "yellow")


####################################
#Ideas discussed on Dec 5, 2019 for allodb
## We want to calculate pairwise distances bewten two trees (really?)
###Build a tree from equation table and species table to compare trees.. Let's explore:
#bur since equations are built at diferent taxa levels we need to use "allometry_specificity" to built trees based on fam, or genus, or species, I think.

equations<-read.csv ("https://raw.githubusercontent.com/forestgeo/allodb/master/data-raw/csv_database/equations.csv", stringsAsFactors = FALSE)
#check unique values for allometry_specificity
unique(equations$allometry_specificity)

#as an example, let create a dataframe for wich allometry_specifity is family
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
#calculate distance then plot again
eqfamtree<-modified.Grafen(eqfamtree, power=2)
cophenetic(eqfamtree)

#apply edge lenght labels
plotTree(eqfamtree,ftype="i",fsize=0.8,lwd=1, offset=2)
edgelabels(round(eqfamtree$edge.length,3,cex=0.6)) #this not working but we don't need it


#now get unique family names from scbi to build a family tree 
unique(scbi$Family)
scbifam <-c(unique(scbi$Family)) #build a vector with scbi families
scbifamtree <- phylomatic(taxa=scbifam, get ='POST') #for some reason thsi exclude rosaceae and ericaceae
plot(scbifamtree) #for some reason some families disapear (ie. Rosaceae, Annonaceae)

#use "cophenetic" to calculate pairwise distance 
scbifamtree<-modified.Grafen(scbifamtree, power=2)
cophenetic(scbifamtree)

class(scbifamtree)

#now compare two trees using the function comparePhylo in the package ape
#this will return a detail report of the comparision and a plot
comparePhylo(eqfamtree, scbifamtree, plot = TRUE)
#and this fuctiion makes a global comparation of two trees
all.equal.list(eqfamtree, scbifamtree, index.return = TRUE)

#visualize the two trees on a diferent way
##first create "the association" matrix:
assoc <- cbind(eqfamtree$tip.label, scbifamtree$tip.label)
#compare trees side by side
cophyloplot(eqfamtree, scbifamtree, length.line = 4, space = 28, gap = 3)


#but we want the distance, numerically, of such trees
#dist.topo (eqfamtree, scbifamtree) #this function I though could work but it doesn't because trees has diferent numbers of tips.
#same with cor_cophenetic(eqfamtree, scbifamtree) from the pack-dendextend which calculates correlation coef. btw two trees, they recommend to use the following function, but it doesn't work either:
intersect_trees(eqfamtree, scbifamtree)


#maybe we can compare two matrices of differnt size?? (need work)
matrix1<-cophenetic(eqfamtree)
matrix2<-cophenetic(scbifamtree)


#and maybe check this: https://cran.r-project.org/web/packages/treespace/vignettes/tipCategories.html
#install.packages("treespace")
#install.packages("dendextend")
library(treespace)
library(dendextend)





#VOILA (not actually)!!!

       