# Adds to data/ the wood density data set from CTFS sites.

# On Tue, Nov 7, 2017 at 12:55 PM, Lao, Suzanne <LAOZ@si.edu> wrote:
# Hi Mauro,
# We have an old version that needs updating. I have attached this file.
#
# From: Mauro Lepore [mailto:maurolepore@gmail.com]
# Hi Suzanne,
# Can I can use the wood density data set of CTFS to develop a function to
# calculate biomass for CTFS sites?

library(tibble)

load("./data-raw/wsg.ctfs.Rdata")
wsg_ctfs3 <- as.tibble(wsg.ctfs3)
use_data(wsg_ctfs3)
