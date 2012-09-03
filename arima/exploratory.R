rm(list=ls())
setwd("~/Documents/bigbrother/data/traffic/counts/")
library(fda)

data=read.table(file="006G283P.txt")
dim(data)

day=factor(x=data[,2])
date=factor(x=data[,1])
day2 = factor(x=data[,2])
counts=matrix(0,nrow=24*dim(data)[1],ncol=1)

for(i in 1:dim(data)[1]){
	counts[(i*24-23):(i*24)]=data[i,3:26]
	day[(i*24-23):(i*24)]=rep(data[i,2],24)
	date[(i*24-23):(i*24)]=rep(data[i,1],24)
}
counts=as.numeric(counts)

#boxplot(counts~day)

hour=rep(1:24,dim(data)[1])
week.day=rep(1,dim(data)[1]*24) #Codes a 1 for weekday and 0 for weekend
in.day=which(day=="Sat"|day=="Sun")
week.day[in.day]=rep(0,length(in.day))
#weekend.day = which(day2=="Sat"|day2=="Sun")
weekend.day = which(day2=="Sun")
weekend.counts = matrix(0, length(weekend.day), 24)
weekend.counts = data[weekend.day, 3:26]
weekday.day = which(day2=="Mon"|day2=="Tue"|day2=="Wed"|day2=="Thu"|day2=="Fri")
weekday.counts = matrix(0, length(weekday.day), 24)
weekday.counts = data[weekday.day, 3:26]
counts.weekend = matrix(0, nrow=24*dim(weekend.counts)[1], ncol=1)
counts.weekday = matrix(0, nrow=24*dim(weekday.counts)[1], ncol=1)

cat("Here")

for (i in 1:dim(weekend.counts)[1]) {
	for (j in 1:24) {
		counts.weekend[(i-1)*24 + j] = weekend.counts[i, j]
	}
}

for (i in 1:dim(weekday.counts)[1]) {
	for (j in 1:24) {
		counts.weekday[(i-1)*24 + j] = weekday.counts[i, j]
	}
}
counts.weekday = as.numeric(counts.weekday)
counts.weekend = as.numeric(counts.weekend)

plot(1:24,1:24,ylim=c(min(counts),max(counts)),type="n")
for(i in 1:dim(data)[1]){
	lines(1:24,data[i,3:26],col=rgb(0,0,0,.15))
}

plot(1:24,1:24,ylim=c(min(counts),max(counts)),type="n")
for(i in 1:dim(weekend.counts)[1]){
	lines(1:24,weekend.counts[i,1:24],col=rgb(0,0,0,.15))
}

# plot(1:24,1:24,ylim=c(min(counts),max(counts)),type="n")
# for(i in 1:dim(weekday.counts)[1]){
	# lines(1:24,weekday.counts[i,1:24],col=rgb(0,0,0,.15))
# }

#mod=lm(counts~day)
#anova(mod)


#par(mfrow=c(2,1))
#acf(counts,lag.max=180)
#pacf(counts,lag.max=120)

# mod4.0=arima(counts,order=c(4,0,0))
# mod5.0=arima(counts,order=c(5,0,0))
# mod6.0=arima(counts,order=c(6,0,0))
# mod7.0=arima(counts,order=c(7,0,0))
# mod8.0=arima(counts,order=c(8,0,0))
# mod24.0=arima(counts,order=c(24,0,0))


# mod4.0$aic-131000
# mod5.0$aic-131000
# mod6.0$aic-131000
# mod7.0$aic-131000
# mod8.0$aic-131000
# mod24.0$aic-131000

#mod=arima(counts.weekend,order=c(1,0,1))#,seasonal=list(order=c(),period=NA))
#mod_predict = predict(mod, n.ahead=24)
#plot(1:24, mod_predict$pred)

# get.best.arima <- function(x.ts, maxord = c(1,1,1,1,1,1)) {
	# best.aic <- 1e8 
	# n <- length(x.ts) 
	# for (p in 0:maxord[1]) for(d in 0:maxord[2]) for(q in 0:maxord[3])
		# for (P in 0:maxord[4]) for(D in 0:maxord[5]) for(Q in 0:maxord[6]) {
			# fit <- arima(x.ts, order = c(p,d,q), seas = list(order = c(P,D,Q),
					# frequency(x.ts)), method = "CSS") 
			# fit.aic <- -2 * fit$loglik + (log(n) + 1) * length(fit$coef)
		# if (fit.aic < best.aic) {
			# best.aic <- fit.aic 
			# best.fit <- fit 
			# best.model <- c(p,d,q,P,D,Q)
		# }
	# } 
	# list(best.aic, best.fit, best.model)
# }


# best.arima <- get.best.arima(counts, maxord = c(rep(2,6)))

# best.fit=best.arima[[2]]
# best.arima
# acf(resid(best.fit))
# pacf(resid(best.fit))


#fbplot(data[,3:26],ylim=c(min(counts),max(counts)))


# best.arima.res <- get.best.arima(resid(mod), maxord = c(2,2,2,2,2,2))
# best.fit.res=best.arima.res[[2]]
# best.arima.res
# par(mfrow=c(1,3))
# acf(counts,lag.max=24*10)
# acf(resid(mod),lag.max=24*10)
# acf(resid(best.fit.res),lag.max=24*10)


# pacf(resid(best.fit.res))




