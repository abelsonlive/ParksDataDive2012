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
    'work_order_id',
    'location',
    'species',
    'census',
    'young_tree',
    'tree_adopt',
    'tree_id',
    'join_field',
    'join_field2',
    'x_lon',
    'y_lat'
)

street.trees <- subset(street.trees, select = c(
    'dbh',
    'address',
    'season',
    'boro',
    'species',
    'census',
    'young_tree',
    'tree_id',
    'work_order_id',
    'x_lon',
    'y_lat'
    ))

street.trees$boro[street.trees$boro==1] <- "manhattan"
street.trees$boro[street.trees$boro==2] <- "bronx"
street.trees$boro[street.trees$boro==3] <- "brooklyn"
street.trees$boro[street.trees$boro==4] <- "queens"
street.trees$boro[street.trees$boro==5] <- "staten_island"
street.trees$boro <- factor(street.trees$boro)
write.csv(street.trees, "~/Dropbox/GitRepository/ParksDataDive2012/Street_Trees.csv", na="", row.names=F)
head(street.trees)
# removals
work.orders <- read.csv("~/Dropbox/GitRepository/ParksDataDive2012/WorkOrders_NamesCleaned.csv")
work.orders <- subset(work.orders, WOCATEGORY == 'TREEREMV' & STATUS %in% c("CLOSED", "COMPLETE"), 
                      select = c(
    'WORKORDERID',
    'WOXCOORDINATE',
    'WOYCOORDINATE',
    'ACTUALFINISHDATE',
    'STATUS', # CLOSED, COMPLETE
    'Text8'
    ))
names(work.orders) <- c(
    'work_order_id',
    'x',
    'y',
    'finish_date',
    'status',
    'species2'
    )

write.csv(work.orders, file='~/Dropbox/GitRepository/ParksDataDive2012/WorkOrders.csv', na="", row.names=FALSE)
