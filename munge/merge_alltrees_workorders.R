# Adam Laiacano
# Required input: Alltrees_20120606_latlon.csv from the DataKind dropbox at 
# https://www.dropbox.com/sh/8ubk2cxtdbway25/6UVgKPLtoG/Alltrees_20120606.csv


library(ggplot2)
library(plyr)
library(maps)
rm(list=ls())

# Load data from Street Trees Census
street.trees <- read.csv("~/Dropbox/GitRepository/ParksDataDive2012/Alltrees_20120606.csv", 
                         header=TRUE,
                         stringsAsFactors=FALSE)
names(street.trees) <- c(
    'side',
    'address',
    'dbh',
    'season',
    'contract',
    'boro',
    'contract.number',
    'work.order.id',
    'location',
    'species',
    'census',
    'young.tree',
    'tree.adopt',
    'tree.id',
    'join.field',
    'join.field2',
    'x_lon',
    'y_lat'
)

street.trees <- subset(street.trees, select = c(
    'side',
    'dbh',
    'address',
    'season',
    'boro',
    'species',
    'census',
    'young.tree',
    'tree.id',
    'x_lon',
    'y_lat'
    ))

street.trees$boro[street.trees$boro==1] <- "Manhattan"
street.trees$boro[street.trees$boro==2] <- "Bronx"
street.trees$boro[street.trees$boro==3] <- "Brooklyn"
street.trees$boro[street.trees$boro==4] <- "Queens"
street.trees$boro[street.trees$boro==5] <- "Staten Island"
street.trees$boro <- factor(street.trees$boro)

head(street.trees)
write.csv(street.trees, "~/Dropbox/GitRepository/ParksDataDive2012/StreetTrees.csv", row.names=F)
dat = read.csv("~/Dropbox/GitRepository/ParksDataDive2012/StreetTrees.csv", stringsAsFactors=F)
work.orders <- read.csv("~/Dropbox/GitRepository/ParksDataDive2012/WorkOrders_NamesCleaned.csv")
work.orders <- subset(work.orders,
                      select = c(
    'WORKORDERID',
    'WOXCOORDINATE',
    'WOYCOORDINATE',
    'ACTUALFINISHDATE',
    'STATUS', # CLOSED, COMPLETE
    'Text8'
    ))
names(work.orders) <- c(
    'work.order.id',
    'x',
    'y',
    'finish.date',
    'status',
    'species2'
    )
write.csv(work.orders, "~/Dropbox/GitRepository/ParksDataDive2012/WorkOrders.csv", row.names=F)


combined <- rbind.fill(work.orders, street.trees)
write.csv(combined, file='~/Dropbox/GitRepository/ParksDataDive2012/StreetTrees_WorkOrders.csv', na="", row.names=FALSE)
#species2 crossover
crossover = data.frame(species2 = combined$species2, work_order_id = combined$work.order.id)
write.csv(crossover, file='~/Dropbox/GitRepository/ParksDataDive2012/crossover.csv', na="", row.names=FALSE)