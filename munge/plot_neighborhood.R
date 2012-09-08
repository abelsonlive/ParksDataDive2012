# Adam Laiacano
# This lets you select a lat/lon and a rectangular distance and it makes some
# interesting plots about planting history/diversity for that area. The current
# values are set to the Park Slope/Prospect Park area.

lon <- -73.976
lat <- 40.67

source('merge_alltrees_workorders.R')  
grabxy <- function(data, xpoint, ypoint, range=1000){
    data <- subset(data, x > (xpoint-range/2) & x < (xpoint+range/2) & y > (ypoint-range/2) & y < (ypoint+range/2))
    data
}

qplot(x, y, data=street.trees[sample(1:nrow(street.trees), 10000),])

d <- grabxy(street.trees, lon, lat, range=.03)

d2 <- ddply(idata.frame(subset(d, species != "other")), .(season, species), summarize, tot=length(season))
d3 <- ddply(idata.frame(d2), .(species), function(x) {data.frame(season=x$season, tot.trees=cumsum(x$tot))})

qplot(x,y, data=d, color=log10(dbh)) + opts(title="Tree Diameters") + coord_map()
qplot(as.numeric(season), tot.trees, data=d3, color=species, geom=c('point', 'line')) + opts(title="Top 10 Species")
qplot(species, data=subset(d, species %in% names(summary(factor(d$species)))[1:10])) + opts(title="Species Diversity")
