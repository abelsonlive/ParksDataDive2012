library("foreign")
library("rgdal")
library("sp")
library("spdep")
library("maptools")
library("SpatialEpi")
library("plyr")
shape = read.dbf("/Users/brian/Dropbox/GitRepository/ParksDataDive2012/nyct2010_12b_av/nyct2010.dbf")
risk = read.dbf("/Users/brian/Downloads/storm_risk_index (1)/storm_risk_index_export.dbf")

risk = read.csv("/Users/brian/Downloads/index.csv")

for(i in 1:nrow(risk)){
	if(nchar(risk$ct_6_string[i])==3){
		risk$ct_6_string[i] = paste("000",risk$ct_6_string[i],sep="")
	}
	if(nchar(risk$ct_6_string[i])==4){
		risk$ct_6_string[i] = paste("00",risk$ct_6_string[i],sep="")
	}
	if(nchar(risk$ct_6_string[i])==5){
		risk$ct_6_string[i] = paste("0",risk$ct_6_string[i],sep="")
	}
}
risk = risk[,2:3]
names(risk) = c("index", "CT2010")

data <- join(risk, shape, type="right", by="CT2010")
shapes <- readShapePoly("/Users/brian/Dropbox/GitRepository/ParksDataDive2012/nyct2010_12b_av/nyct2010.shp")

#create a network of neighboring shapes
neighbors <- poly2nb(shapes)

#create weights based off of a shapes neighbors
weights <-nb2listw(neighbors, style="B", zero.policy=TRUE)

#local moran's test for autocorrelation 
shapes$index[is.na(shapes$index)] = 0
morans <- localmoran(shapes$index, weights)
#bind moran's pvalues back to the data
data$pval <- morans[,5]
#rewrite data
write.dbf(data, "/Users/brian/Dropbox/GitRepository/ParksDataDive2012/nyct2010_12b_av/nyct2010.dbf")
