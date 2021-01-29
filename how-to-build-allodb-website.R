(devtools::check())

install.packages("styler")
library(styler)
#usethis::use_tidy_style()



install.packages("pkgdown")
library(pkgdonw)

##How to update allodb website
#1. Update your documentattion files in R/data
#

#Use this to update documetation
devtools::document()

#run this to check that everything is correct before rebuilding site. THis wll update documentation again and and re=wrire NAMESPACE
#It also will write a report as it is running with 'Test failures"
#(devtools::check())

#run roxygen2 to update website
install.packages("roxygen2")



#then rebuilt the website, push
pkgdown::build_site()


#to check that we have good practices
goodpractice::goodpractice()
install.packages("goodpractice")
