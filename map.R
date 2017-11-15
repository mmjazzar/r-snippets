
install.packages("ggmap")
install.packages("measurements")
library(measurements)
library(ggmap)

# LOCATION
wh <- geocode("jabal sawda")
get_googlemap("saudi arabia", zoom = 12) %>% ggmap()




####
mapImageData1 <- get_map(location = c(lon = 42.37028, lat = 18.26778),
                         color = "color",
                         source = "google",
                         maptype = "terrain",
                         zoom = 8) 


ggmap(mapImageData1,extent = "device",ylab = "Latitude",xlab = "Longitude") +
