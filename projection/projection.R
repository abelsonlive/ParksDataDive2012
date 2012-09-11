# Adam Laiacano
# NYC DataKind/NYC Parks Department Data Dive
# Sept 7-9, 2012

library(reshape)
library(ggplot2)
library(plyr)

recipe <- read.csv("data/future_tree_recipes.csv", stringsAsFactors=FALSE)

# Remove the damn percent signs and convert to numerics
recipe.m <- melt.data.frame(recipe, id.vars="tree_name")
recipe.m$value <- as.numeric(gsub("%", "", recipe.m$value)) / 100
recipe <- cast(recipe.m, tree_name ~ variable, values='value')
rm(recipe.m)

code.names <- read.csv("data/Species code listing_with Common Names.csv")
recipe <- merge(subset(code.names, select=c('Species', 'Species.Code')), recipe, by.x="Species", by.y="tree_name")

# Load data from Street Trees Census
street.trees <- read.csv("../streettrees_export.csv", stringsAsFactors=FALSE)

# extract lat/lon from the_geom field
street.trees$lon <- as.numeric(gsub("^[^0-9-]+([-0-9\\.]+),.+", "\\1", street.trees$the_geom))
street.trees$lat <- as.numeric(gsub("^.+coordinates[^,]+,([-0-9\\.]+)\\].+", "\\1", street.trees$the_geom))
street.trees <- subset(street.trees, lat > 0) # outliers


street.trees <- subset(street.trees, select = c(
    'dbh',
    'season',
    'boro',
    'species',
    'census_tract'
))

# clean up the boroughs. 
street.trees <- subset(street.trees, boro != "0")
street.trees$boro <- tolower(street.trees$boro)
street.trees$boro[street.trees$boro == "staten island"] <- "staten_island"

# hard coded date conversions. nice touch.
street.trees$season.dt <- as.Date('2005-06-01')
street.trees$season.dt[street.trees$season=='FALL05'] <- as.Date('2005-12-01')
street.trees$season.dt[street.trees$season=='FALL06'] <- as.Date('2006-12-01')
street.trees$season.dt[street.trees$season=='FALL07'] <- as.Date('2007-12-01')
street.trees$season.dt[street.trees$season=='FALL08'] <- as.Date('2008-12-01')
street.trees$season.dt[street.trees$season=='FALL09'] <- as.Date('2009-12-01')
street.trees$season.dt[street.trees$season=='FALL10'] <- as.Date('2010-12-01')
street.trees$season.dt[street.trees$season=='FALL11'] <- as.Date('2011-12-01')
street.trees$season.dt[street.trees$season=='SPRING05'] <- as.Date('2005-06-01')
street.trees$season.dt[street.trees$season=='SPRING06'] <- as.Date('2006-06-01')
street.trees$season.dt[street.trees$season=='SPRING07'] <- as.Date('2007-06-01')
street.trees$season.dt[street.trees$season=='SPRING08'] <- as.Date('2008-06-01')
street.trees$season.dt[street.trees$season=='SPRING09'] <- as.Date('2009-06-01')
street.trees$season.dt[street.trees$season=='SPRING10'] <- as.Date('2010-06-01')
street.trees$season.dt[street.trees$season=='SPRING11'] <- as.Date('2011-06-01')
street.trees$season.dt[street.trees$season=='FALL06/SP07'] <- as.Date('2007-06-01')
street.trees$season.dt[street.trees$season=='FALL08/SP09'] <- as.Date('2009-06-01')
street.trees$season.dt[street.trees$season=='SPRING09/FALL09'] <- as.Date('2009-12-01')

future.seasons = c(
    "2011-12-01",
    "2012-06-01",
    "2012-12-01",
    "2013-06-01",
    "2013-12-01",
    "2014-06-01"
    )

st <- street.trees
st$lat <- st$lon <- NULL
st$season.dt <- as.character(st$season.dt)

st$species <- as.character(st$species)


for(season in future.seasons) {
    x <- ddply(idata.frame(st),
               .(census_tract),
               function(xin) {
                   if (nrow(xin) == 0) {return(data.frame())}
                   
                   boro <- xin$boro[1]
                   trees_to_plant = round(runif(1,1,5)) # TODO: replace with estimate of number of trees
                   tree.dist <- ddply(idata.frame(xin), .(species), nrow)
                   tree.dist <- merge(tree.dist, subset(recipe, select=c('Species.Code', boro)), by.y="Species.Code", by.x="species")
                   if (nrow(tree.dist) == 0){ 
                       # no matches == no planting.
                       return(data.frame())
                   }
                   tree.dist[,boro] <- tree.dist[,boro] * tree.dist$V1
                   tree.dist$V1 <- NULL
                   if(sum(tree.dist[,boro]) == 0){return(data.frame())}
                   tree.dist[,boro] <- tree.dist[,boro] / sum(tree.dist[,boro])
                   
                   ret <- data.frame(
                       census_tract=rep(xin$census_tract[1], trees_to_plant),
                       boro=rep(xin$boro[1], trees_to_plant),
                       species = sample(as.character(tree.dist$species), trees_to_plant, tree.dist[,boro], replace=TRUE)
                   )
                   ret$species <- as.character(ret$species)
                   ret
               },
               .progress='text'
    )
    x$season.dt <- season
    st <- rbind.fill(st, x)
}
st$season.dt <- as.Date(st$season.dt)


census.tract <- 15100
d <- subset(st, census_tract==census.tract)

d$season <- as.Date(d$season.dt)
d2 <- ddply(idata.frame(d), .(season, species), summarize, tot=length(season))
d3 <- ddply(idata.frame(d2), .(species), function(x) {data.frame(season=x$season, tot.trees=cumsum(x$tot))})
d3$species <- factor(d3$species)
d3$season <- as.Date(as.character(d3$season))

# get the trees that have been planted the most. This is a bit ugly but it works.
most.planted <- ddply(d3, .(species), summarize, planted=max(tot.trees)-min(tot.trees), tot.trees=max(tot.trees))
most.planted <- head(most.planted[order(-most.planted$planted, -most.planted$tot.trees),], 10)$species
d3 <- ddply(d3, .(species), transform, show.in.plot=(max(season)>="2010-01-01" | species[1] %in% most.planted))

## if the latest date isn't in there, add it.
d3 <- subset(d3, show.in.plot)
max.date <- max(d3$season)
for (species in unique(d3$species)){
    if (max(d3$season[d3$species==species]) < max.date){
        d3 <- rbind.fill(
            d3, 
            data.frame(
                species=species,
                season=max.date,
                tot.trees=max(d3$tot.trees[d3$species==species])
            )
        )
    }
}
ggplot(d3, aes(x=season, y=tot.trees, color=species)) + geom_point(alpha=.4) + geom_line() +
    opts(title=paste("Most Planted Species In Census Block", census.tract)) + 
    scale_y_continuous("Total Trees") +
    scale_x_date("Date")

qplot(species, data=subset(d, season>'2005-06-01' & species %in% names(summary(factor(d$species)))[1:100]), fill=factor(season)) + 
    opts(title="Tree Plantings") +
    scale_x_discrete('Species Code') +
    scale_y_continuous("Newly Planted Trees") +
    coord_flip()
