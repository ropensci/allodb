% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_biomass.R
\name{get_biomass}
\alias{get_biomass}
\title{Compute tree aboveground biomass (AGB) based on allometric equations}
\usage{
get_biomass(
  dbh,
  genus,
  coords,
  species = NULL,
  new_eqtable = NULL,
  wna = 0.1,
  w95 = 500,
  nres = 10000
)
}
\arguments{
\item{dbh}{a numeric vector containing tree diameter at breast height (dbh)
measurements, in cm.}

\item{genus}{a character vector (same length as dbh), containing the genus
(e.g. "Quercus") of each tree.}

\item{coords}{a numeric vector of length 2 with longitude and latitude (if
all trees were measured in the same location) or a matrix with 2 numerical
columns giving the coordinates of each tree.}

\item{species}{a character vector (same length as dbh), containing the
species (e.g. "rubra")  of each tree. Default is \code{NULL}, when no species
identification is available.}

\item{new_eqtable}{Optional. An equation table created with the
\code{\link[=new_equations]{new_equations()}} function.}

\item{wna}{a numeric vector, this parameter is used in the \code{\link[=weight_allom]{weight_allom()}}
function to determine the dbh-related weight attributed to equations
without a specified dbh range. Default is 0.1.}

\item{w95}{a numeric vector, this parameter is used in the \code{\link[=weight_allom]{weight_allom()}}
function to determine the value at which the sample-size-related weight
reaches 95\% of its maximum value (max=1). Default is 500.}

\item{nres}{number of resampled values. Default is "1e4".}
}
\value{
A "numeric" vector of the same length as dbh, containing AGB value
(in kg) for every stem.
}
\description{
This function calculates the aboveground biomass (or other tree components)
of a given tree based on published allometric equations. Users need to
provide a table (i.e. dataframe) with DBH (cm), parsed species Latin names,
and site(s) coordinates. The biomass of all trees in one (or several)
censuses can be estimated using this function.
}
\details{
\code{allodb} estimates AGB by calibrating a new allometric equation for each
taxon (arguments \code{genus} and  \code{species}) and location (argument \code{coords}) in
the user-provided census data. The new allometric equation is based on a set
of allometric equations that can be customized using the \code{new_eqtable}
argument. Each equation is then given a weight with the \code{\link[=weight_allom]{weight_allom()}}
function, based on: 1) its original sample size (numbers of trees used to
develop a given allometry), 2) its climatic similarity with the target
location, and 3) its taxonomic similarity with the target taxon (see
documentation of the \code{\link[=weight_allom]{weight_allom()}} function). The final weight attributed
to each equation is the product of those three weights. Equations are then
resampled with the\code{\link[=resample_agb]{resample_agb()}} funtion: the number of samples per
equation is proportional to its weight, and the total number of samples is
provided by the argument \code{nres}. The resampling is done by drawing DBH values
from a uniform distribution on the DBH range of the equation, and estimating
the AGB with the equation. The couples of values (DBH, AGB) obtained are then
used in the function \code{\link[=est_params]{est_params()}} to calibrate a new allometric equation,
by applying a linear regression to the log-transformed data. The parameters
of the new allometric equations are then used in the \code{\link[=get_biomass]{get_biomass()}} function
by back-transforming the AGB predictions based on the user-provided DBHs.
}
\section{Warning}{

The function can run into some memory problems when used on large datasets
(usually several hundred thousand observations).
}

\examples{
# Estimate biomass of all individuals from the Lauraceae family at the SCBI
# plot
lau <- subset(scbi_stem1, Family == "Lauraceae")
lau$agb <- get_biomass(lau$dbh, lau$genus, lau$species,
  coords = c(-78.2, 38.9)
)
lau

# Estimate biomass from multiple sites (using scbi_stem1 as example with
# multiple coord)
dat <- scbi_stem1[1:100, ]
dat$long <- c(rep(-78, 50), rep(-80, 50))
dat$lat <- c(rep(40, 50), rep(41, 50))
dat$biomass <- get_biomass(
  dbh = dat$dbh,
  genus = dat$genus,
  species = dat$species,
  coords = dat[, c("long", "lat")]
)
dat
}
\seealso{
\code{\link[=weight_allom]{weight_allom()}}, \code{\link[=new_equations]{new_equations()}}
}
