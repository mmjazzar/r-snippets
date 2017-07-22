library(RMySQL)

# making connection
mydb <- dbConnect(MySQL(), 
                 user = '', 
                 password = '', 
                 dbname = '', 
                 host = 'localhost', 
                 port = 3306)




# Store pre-selected data
rs <- dbSendQuery(mydb, "select * FROM iris")
data <- fetch(rs, n = -1)

# Disconnect from DB
dbClearResult(rs)
dbDisconnect(mydb)
