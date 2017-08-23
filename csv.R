#read CSV
mydata <- read.csv("data science - sample date.csv", header = TRUE, na.strings=c("", "NA"), sep = ",")

#export CSV
z <- count(mydata = mydata$cityname)
write.csv(z, file = "x.csv")
