library("plyr")
setwd("~/Dropbox/GitRepository/ParksDataDive2012/")
ptf  = "streettrees_workorde_export 2.csv"
d = read.csv(ptf, stringsAsFactors=F)

#cross over season to date
	season = sort(unique(d$season[which(d$dataset!="workorders")]))

	date = c(
		"06-01-2005", 
		"12-01-2005", 
		"12-01-2006", 
		"06-01-2007",
		"12-01-2007",
		"12-01-2008",
		"06-01-2009",
		"12-01-2009",
		"12-01-2010",
		"12-01-2011",
		"06-01-2006",
		"06-01-2007",
		"06-01-2008",
		"06-01-2009",
		"12-01-2009"
		)
	mergedf = data.frame(season, date, stringsAsFactors=F)
	d = join(mergedf, d, type="right", by="season")

	d$date[is.na(d$date)] = d$finish_date[!is.na(d$date)]

	#add species removal description
	mergeSpeciesdf = read.csv("crossover.csv", stringsAsFactors=F)
	d = join(mergeSpeciesdf, d, by="work_order_id", type="right")