# Simply filtering some data from dataframe

# How many users who have one of the suspicious_ip, suspicious_dfp have bands 4, 3,,2,1
# k = 52

x <- as.data.frame(mydata$fraud)
y <- as.data.frame(mydata$account)
w <- as.data.frame(mydata$ri_band)

z <- cbind(y,x,w)

# Non duplicated vaalues.
Q1 <- z[!duplicated(z), ]

#Specify the condition k = 17
print(k <- z %>% filter(((mydata$fraud =='(suspicious_ip)(suspicious_dfp)' ) )))
