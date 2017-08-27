# sperating cells data into multiple cells

# mydata is our data
# 999 is any number 
x <- str_split_fixed(mydata, " ", 999)

# adjusting data.
for (i in 1:nrow(x))
{
  # data adjustment. 
  k <- x[i,]
  k <- as.integer(k)
  k <- na.omit(k)
  k <- as.integer(k)
  k <- as.data.frame(k)
  k <- as.data.frame(t(k))
  
 save to CSV

    write.table(k, "data.csv", row.names=F, na="NA", 
              append = T, quote= FALSE, sep = ",", col.names = F)
  
}
