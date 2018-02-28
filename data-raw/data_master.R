# Clean master data

master <- readr::read_csv(here::here("data-raw/allotemp_main.csv"))

# FIXME: Remove ambiguity of this code chunk (#29; https://goo.gl/rmuzmH)
# eliminate rows where fam or sp is unknown #use unique(allo_main$species)
master <- subset(master, family != "Unkown")
# chnage name of "equation" column to "equation_form"
