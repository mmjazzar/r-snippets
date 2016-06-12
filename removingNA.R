#remove na or blank values

mydata <- read.csv("data science.csv", header = TRUE, na.strings=c("", "NA"), sep = ",")
mydata[mydata==""] <- NA
mydata[mydata$displayed_job_title==""] <- NA
mydata <-na.omit(mydata)
