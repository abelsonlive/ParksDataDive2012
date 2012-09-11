rm(list=ls())
library("plyr")
library("stringr")
setwd("~/Dropbox/GitRepository/ParksDataDive2012/")

# clean up street trees
	st = read.csv("streettrees_export.csv", stringsAsFactors=F)
	st$census_block = as.character(st$census_block)
	st$census_tract = as.character(st$census_tract)
	st = st[!is.na(st$census_block),]
	st = st[!is.na(st$census_tract),]
	st = subset(st, 
			select=c(
				"cartodb_id", 
				"census_block", 
				"census_tract", 
				"species",
				"season")
			)
	season = sort(unique(st$season))
	date = c(
		"2005-06-01", 
		"2005-12-01", 
		"2006-12-01", 
		"2007-06-01",
		"2007-12-01",
		"2008-12-01",
		"2009-06-01",
		"2009-12-01",
		"2010-12-01",
		"2011-12-01",
		"2006-06-01",
		"2007-06-01",
		"2008-06-01",
		"2009-06-01",
		"2009-12-01"
		)
	mergedf = data.frame(season, date, stringsAsFactors=F)
	st = join(mergedf, st, type="right", by="season")
	st$dataset= "streettree"

# clean up removals
	rm = read.csv("workorders_export.csv", stringsAsFactors=F)
	rm$census_block = as.character(rm$census_block)
	rm$census_tract = as.character(rm$census_tract)
	rm = rm[!is.na(rm$census_block),]
	rm = rm[!is.na(rm$census_tract),]
	rm = subset(rm, 
			select=c(
				"census_block", 
				"census_tract", 
				"finish_date", 
				"species2", 
				"work_order_id")
			)
	rm = rm[which(rm$finish_date!=""),]
	rm$finish_date = str_trim(gsub("[0-9]+:[0-9]+","", rm$finish_date))
	rm$date = as.Date(rm$finish_date, "%m/%d/%y")
	rm$dataset= "workorder"

# merge datasets	
	df = rbind.fill(st, rm)
	df = subset(df, 
			select=c
				(
				 "census_block", 
				 "census_tract",
				 "species",
				 "date",
				 "dataset"
				)
			)
df$date = as.Date(df$date)
df = df[order(df$date),]
df$id = paste("tree", 1:nrow(df), sep="")
df$species[which(df$species=="")] <- NA

# SAMPLE SPECIES FROM DISTRIBUTION #
plyfcn = function(dfcb){
	spec.names = unique(dfcb$species)
	spec.names = spec.names[!is.na(spec.names)]
	n.spec = length(spec.names)
	spec = vector("list", n.spec)
	names(spec) = spec.names
	if(length(spec) > 0){
			for(s in 1:spec.n){
				spec[[s]] = 0.00001
			}
		for(i in 1:nrow(dfcb)){
			if(!is.na(dfcb$species[i])){
				if (dfcb$species[i] == 0){
					spec[[dfcb$species[i]]] <- 1
				} else {
				# plant the tree
					spec[[dfcb$species[i]]] <- spec[[dfcb$species[i]]] + 1
				}
			} else {				
				dfcb$species[i] = sample(names(spec), 1, prob = unlist(spec))
				# unplant the tree
				if (spec[[dfcb$species[i]]] > 1){
					spec[[dfcb$species[i]]] <- spec[[dfcb$species[i]]] - 1
				}
			}
		}
	}
return(dfcb)
}
out = ddply(df, .(census_block), plyfcn, .progress="text")