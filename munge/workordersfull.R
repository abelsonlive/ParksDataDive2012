# removals
work.orders <- read.csv("~/Dropbox/GitRepository/ParksDataDive2012/WorkOrders_NamesCleaned.csv")
work.orders <- subset(work.orders, 
                      select = c(
    'WORKORDERID',
    'WOXCOORDINATE',
    'WOYCOORDINATE'
    ))
names(work.orders) <- c(
    'work.order.id',
    'x',
    'y'
    )

write.csv(work.orders, file='~/Dropbox/GitRepository/ParksDataDive2012/WorkOrdersFull.csv', na="", row.names=FALSE)