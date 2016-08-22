#example 1


# define mts with distinct y-axis scales
temperature <- ts(frequency = 12, start = c(1980, 1),
  data = c(7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 
           25.2, 26.5, 23.3, 18.3, 13.9, 9.6))
rainfall <- ts(frequency = 12, start = c(1980, 1),
  data = c(49.9, 71.5, 106.4, 129.2, 144.0, 176.0, 
           135.6, 148.5, 216.4, 194.1, 95.6, 54.4))
weather <- cbind(rainfall, temperature)

# assign the "rainfall" series to the y2 axis
dygraph(weather) %>%
  dySeries("rainfall", axis = 'y2')
  
  
#example 2
  
  x <- 1:5
y1 <- rnorm(5)
y2 <- rnorm(5,20)
par(mar=c(5,4,4,5)+.1)
plot(x,y1,type="l",col="red")
par(new=TRUE)
plot(x, y2,,type="l",col="blue",xaxt="n",yaxt="n",xlab="",ylab="")
axis(4)
mtext("y2",side=4,line=3)
legend("topleft",col=c("red","blue"),lty=1,legend=c("y1","y2"))
