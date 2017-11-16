#' Biomass computation
#'
#' @description
#' Allocate wood density and compute above-ground biomass using the
#'   updated model of Chave et al. (2014), given in Rejou-Mechain et al. (2017).
#'   Palm trees (palm=T) are computed using a different allometric model
#'   (Goodman et al. 2013).
#' @param site provide the full name of your site (in lower case) i.e. 'barro
#'   colorado island'
#' @param palm TRUE or FALSE, if TRUE, biomass of palm trees is computed through
#'   a specific allometric model (Goodman et al. 2013)
#' @param DATA_path allows to provide a different path where the data are located
#' @author Ervan Rutishauser (er.rutishauser@gmail.com)
#'
#' @return a data.table (data.frame) with all relevant variables.
#' @export
computeAGB <- function(df,site,palm=T,DATA_path) {
	requireNamespace("data.table", quietly = TRUE)
	## Allocate wood density
	df$wsg <- density.ind(df=df,site,wsg=WSG)

	# Compute biomass
	df$agb <- AGB.comp(site,df$dbh2, df$wsg,H = NULL)

	# Compute biomass for palms
	if (palm) {
		SP <-  LOAD(paste(DATA_path,list.files(DATA_path)[grep("spptable",list.files(DATA_path))],sep="/"))
		if(is.na(match("genus",tolower(names(SP))))) {
			trim <- function (x) gsub("^\\s+|\\s+$", "", x)
			SP$genus <-  trim(substr(SP$Latin,1,regexpr(" ",SP$Latin)))
			SP$species <-  trim(substr(SP$Latin,regexpr(" ",SP$Latin),50))
			SP <- SP[,c("sp","genus","species","Family")]
			SP$name <- paste(SP$genus,SP$species,sep=" ")
			names(SP) <- c("sp","genus","species","Family","name")
			df <- merge(df,SP,by="sp",all.x=T)
			agbPalm <- function(D) { exp(-3.3488 + 2.7483*log(D/10) + ((0.588)^2)/2)/1000 }
			df['Family'=="Arecaceae",agb:= agbPalm(dbh2)]
		} else {
			SP <- SP[,c("sp","Genus","Species","Family")]
			SP$name <- paste(SP$Genus,SP$Species,sep=" ")
			names(SP) <- c("sp","genus","species","Family","name")
			df <- merge(df,SP,by="sp",all.x=T)
			agbPalm <- function(D) { exp(-3.3488 + 2.7483*log(D/10) + ((0.588)^2)/2)/1000 }
			df['Family'=="Arecaceae",agb:= agbPalm(dbh2)]
		}
	}
	return(df)
}


#' Assign wood density
#' @author Ervan Rutishauser (er.rutishauser@gmail.com)
#' @description Assign wood density using CTFS wood density data base (WSG)
#' @param df a data.table
#' @param site provide the full name of your site (in lower case) i.e. 'barro colorado island'
#' @param wsgdata a list of tree species (mnenomic) and corresponding wood density
#' @param denscol the variable to be return ("wsg" by default). No other option is implemented.
#' @return a data.table (data.frame) with all relevant variables.
#' @export

density.ind <- function (df, site, wsgdata, denscol = "wsg") {
	wsgdatamatch = which(wsgdata$site %in% site.info$wsg.site.name[site.info$site==site])
	if (length(wsgdatamatch) == 0)
		stop("Site name doesn't match!")
	wsgdata = unique(wsgdata[wsgdatamatch, ])
	meanwsg = mean(subset(wsgdata, idlevel == "species")[, denscol],
		na.rm = TRUE)
	m = match(df$sp, wsgdata$sp)
	result = wsgdata[m, denscol]
	result[is.na(m)] = meanwsg
	result[is.na(result)] = meanwsg
	return(result)
}

#' AGB computation
#' @author Ervan Rutishauser (er.rutishauser@gmail.com)
#' @description Compute above-ground biomass using the updated model of Chave et al. (2014), given in Rejou-Mechain et al. (2017)
#' @param site provide the full name of your site (in lower case) i.e. 'barro colorado island'
#' @param D a column with tree diameters (in mm)
#' @param WD a column with wood density values
#' @param H a column with tree heights (optional)
#' @return a vector with AGB values (in Mg)
#' @export

AGB.comp <- function (site,D,WD, H = NULL) {
	if (length(D) != length(WD))
		stop("D and WD have different lenghts")
	if (is.null(site)) {
		stop("You must specified your site") }
	if (!is.null(H)) {
		if (length(D) != length(H))
			stop("H and WD have different length")
		if (any(is.na(H)) & !any(is.na(D)))
			warning("NA values are generated for AGB values because of missing information on tree height, \nyou may construct a height-diameter model to overcome that issue (see ?HDFunction and ?retrieveH)")
		if (any(is.na(D)))
			warning("NA values in D")
		AGB <- (0.0673 * (WD * H * (D/10)^2)^0.976)/1000
	}
	else {
		INDEX <- match(tolower(site),site.info$site)
		if (is.na(INDEX)) {			stop("Site name should be one of the following: \n",paste(levels(factor(site.info$site)),collapse=" - ")) }
		E <- site.info$E[INDEX]
		AGB <- exp(-2.023977 - 0.89563505 * E + 0.92023559 *
				log(WD) + 2.79495823 * log(D/10) - 0.04606298 *
				(log(D/10)^2))/1000
	}
	return(AGB)
}
