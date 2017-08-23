#read CSV
mydata <- read.csv("data science - sample date.csv", header = TRUE, na.strings=c("", "NA"), sep = ",")

#export CSV
z <- count(mydata = mydata$cityname)
write.csv(z, file = "x.csv")


#appending values
# k is a dataframe
if (file.exists(paste('code', 'test.csv'))==FALSE) write.csv(k, file=paste('code', 'test.csv'), row.names=F)


# better method

  write.table(k, "export.csv", row.names=F, na="NA", 
              append = T, quote= FALSE, sep = ",", col.names = F)
  
