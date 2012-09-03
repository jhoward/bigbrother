rm(list=ls())
setwd("~/Documents/bigbrother/data/traffic/counts/")
library(fda)
library(forecast)

sarima.for=function(xdata,nahead,p,d,q,P=0,D=0,Q=0,S=-1,tol=.001){ 
  data=as.ts(xdata) 
  n=length(data)
  constant=1:n
  xmean=matrix(1,n,1)
  if (d>0 & D>0) 
    fitit=arima(data, order=c(p,d,q), seasonal=list(order=c(P,D,Q), period=S))
  if (d>0 & D==0)  
    fitit=arima(data, order=c(p,d,q), seasonal=list(order=c(P,D,Q), period=S),
            xreg=constant,include.mean=F)
  if (d==0 & D==0)
    fitit=arima(data, order=c(p,d,q), seasonal=list(order=c(P,D,Q), period=S),
            xreg=xmean,include.mean=F)
  if (d==0 & D>0)  
    fitit=arima(data, order=c(p,d,q), seasonal=list(order=c(P,D,Q), period=S),
            xreg=constant,include.mean=F)
  if (d>0 & D>0)   nureg=NULL
  if (d>0 & D==0)  nureg=(n+1):(n+nahead)
  if (d==0 & D==0) nureg=matrix(1,nahead,1)
  if (d==0 & D>0)  nureg=(n+1):(n+nahead)
 fore=predict(fitit, n.ahead=nahead, newxreg=nureg)  
#-- graph:
  U = fore$pred + 2*fore$se
  L = fore$pred - 2*fore$se
   a=max(1,n-100)
  minx=min(data[a:n],L)
  maxx=max(data[a:n],U)
   t1=xy.coords(data)$x; 
   if(length(t1)<101) strt=t1[1] else strt=t1[length(t1)-100]
   t2=xy.coords(fore$pred)$x; 
   endd=t2[length(t2)]
   xllim=c(strt,endd)
  ts.plot(data,fore$pred,col=1:2, xlim=xllim, ylim=c(minx,maxx), ylab=deparse(substitute(xdata))) 
  lines(fore$pred, col="red", type="p")
  lines(U, col="blue", lty="dashed")
  lines(L, col="blue", lty="dashed")
#
  return(fore)
}


data=read.table(file="006G283P.txt")
dim(data)

day=factor(x=data[,2])
day_c = factor(x=data[,2])
date=factor(x=data[,1])
counts=matrix(0,nrow=24*dim(data)[1],ncol=1)

for(i in 1:dim(data)[1]){
	counts[(i*24-23):(i*24)]=data[i,3:26]
	day[(i*24-23):(i*24)]=rep(data[i,2],24)
	date[(i*24-23):(i*24)]=rep(data[i,1],24)
}
counts=as.numeric(counts)

#boxplot(counts~day)

sun_day = which(day_c=="Sun")
sun_counts = matrix(0, length(sun_day), 24)
sun_counts = data[sun_day, 3:26]
week_day = which(day_c=="Mon"|day_c=="Tue"|day_c=="Wed"|day_c=="Thu"|day_c=="Fri")
week_counts = matrix(0, length(week_day), 24)
week_counts = data[week_day, 3:26]
counts_sun = matrix(0, nrow=24*dim(sun_counts)[1], ncol=1)
counts_week = matrix(0, nrow=24*dim(week_counts)[1], ncol=1)

for (i in 1:dim(sun_counts)[1]) {
	for (j in 1:24) {
		counts_sun[(i-1)*24 + j] = sun_counts[i, j]
	}
}

for (i in 1:dim(week_counts)[1]) {
	for (j in 1:24) {
		counts_week[(i-1)*24 + j] = week_counts[i, j]
	}
}
counts_sun = as.numeric(counts_sun)
counts_week = as.numeric(counts_week)

train = counts_sun[1:1776]
test = counts_sun[1777:3552]

#train = counts[144:984]
#test = counts[985:1824]

# plot(counts[1:340], type="l")
# acf(counts, lag.max=180)
# pacf(counts, lag.max=180)
# dc = diff(counts, lag=168, differences = 1)
# plot(dc[1:340], type="l")
# acf(dc, lag.max=180)
# pacf(dc, lag.max=180)


# plot(counts_sun[1:240], type="l")
# dcs = diff(counts_sun,lag = 24, differences = 1)
# plot(dcs[1:240], type="l")
# acf(dcs, lag.max=30)
# pacf(dcs)

#mod = auto.arima(train, stepwise=TRUE)

#mod = arima(train, order=c(1,0,1), seasonal=list(order=c(0,1,1), period=24))
#fa = forecast.Arima(mod)
#mod2 = Arima(test, model=mod)
#fa2 = forecast.Arima(mod2)

#sarima.for(train, 48, 1, 0, 1, 0, 1, 1, 24)
# plot(counts_sun[1:120], type="l")
# lines(1:120, fa$fitted[1:120], col="red", type="l")


# mod2 = arima(counts_sun, order=c(1, 0, 1))
# fa2 = forecast.Arima(mod2)
# plot(counts_sun[1:120], type="l")
# lines(1:119, fa2$fitted[2:120], col="red", type="l")

# pred = factor(x = counts_sun[])
# for (i in 24:length(counts_sun)) {
	# predict(mod)
# }

#733 -204.768

# plot(1:24,1:24,ylim=c(min(counts),max(counts)),type="n")
# for(i in 1:dim(data)[1]){
	# lines(1:24,data[i,3:26],col=rgb(0,0,0,.15))
# }

#mod=lm(counts~day)
#anova(mod)

# par(mfrow=c(2,1))
# acf(counts,lag.max=180)
# pacf(counts,lag.max=120)

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

#mod=arima(counts_sun,order=c(1,0,1))#,seasonal=list(order=c(),period=NA))
# mod_predict = predict(mod, n.ahead=24)
# plot(1:24, mod_predict$pred)

get.best.arima <- function(x, maxord = c(2,2,2,2,2,2), p = 24) {
	best.aic <- 1e8 
	a = 1
	n <- length(x) 
	for (p in 0:maxord[1]) for(d in 0:maxord[2]) for(q in 0:maxord[3]) {
		print(a)
		for (P in 0:maxord[4]) for(D in 0:maxord[5]) for(Q in 0:maxord[6]) {
			try({
				fit <- arima(x, order = c(p,d,q), seasonal = list(order = c(P,D,Q), period = p)) 
				if (fit$aic < best.aic) {
					best = fit
					best.aic = fit$aic
				}
				
			})
		}
		a = a + 1
	} 
	best
}

#mod = get.best.arima(train, p=24)
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




