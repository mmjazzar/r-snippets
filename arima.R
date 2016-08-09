mydata1<-read.csv("mydata.csv");
# create a time series mydata
mydata<-ts(mydata1[,2],start = c(2007,1,1),frequency = 366)

plot(mydata, xlab="Years", ylab = "peak load")

mydata
#check the data cycles and time
cycle(mydata)
time(mydata)
#remove na values
mydata <-na.omit(mydata)

# removing the seasonality and the trend from timeseries (and no intercept)
# fit a linear model to the trend and seasonal data
# check if time is signficant
# I use zero so there is no intercept. 
# without the zero, the fitting model shows insignificant intercept 
#
m1=lm(mydata~0+time(mydata)+factor(cycle(mydata)))
m1

summary(m1)
# you should not have zero in the confidence intervals
confint(m1)

plot(mydata,type="l",col="red")
# convert the fitted data into a time series so we can draw both ts
fit<-ts(fitted(m1),start = c(2007,1,1),frequency = 366)
lines(fit, col="blue") 


# now take the residual and see if we need to fit ARIMA model to it.
res<-residuals(m1)
# The data may follow an ARIMA(p,d,0) model if the ACF and PACF plots of the differenced data show the following patterns:
#   
# the ACF is exponentially decaying or sinusoidal;
# there is a significant spike at lag p in PACF, but none beyond lag p.
# The data may follow an ARIMA(0,d,q) model if the ACF and PACF plots of the differenced data show the following patterns:
#   
# the PACF is exponentially decaying or sinusoidal;
# there is a significant spike at lag q in ACF, but none beyond lag q.

# plot acf and pcf
par(mfrow=c(1,2))
a = acf(res,main="")
p =pacf(res,main="")
par(mfrow=c(1,1))

# for the monthly load data, notice the pacf and acf graphs, 
# there is no lags and hence no ARIMA model to apply

ts.plot(res)

m2<-auto.arima(res)
summary(m2)

res2<-residuals(m2)
shapiro.test(res2)
confint(m2)

plot(mydata,type="l",col="red")
# convert the fitted data into a time series so we can draw both ts
fit12<-ts(fitted(m1)+fitted(m2),start = c(2007,1,1),frequency = 366)
lines(fit12, col="blue") 


# show only the fitted model m1 to see if ARIMA improves the fitting 
fit1<-ts(fitted(m1),start = c(2007,1,1),frequency = 366)
lines(fit1, col="green") 
###

