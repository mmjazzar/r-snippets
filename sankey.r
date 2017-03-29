# loading libraries
library(googleVis)
library(dplyr)
library(reshape2)
library(webshot)
webshot::install_phantomjs()

##############################################################
# You need to define your edges as following parameters.
# From: the input data.
# To: the destination.
# weights: the thickness of the lines.
# Each node by default is connected to all destination, if you want to 
# disconnect any of them; put the weight value into 0.
# the number of weights are equal to 15, as each node has 3 wights values connected
# to each destination. 
###############################################################
dat <- data.frame(From=c(rep("x",3),
                         rep("y", 3),
                         rep("z", 3),
                         rep("w", 3),
                         rep("Q", 3)),
                  
                  To=c(rep(c("R", "M", 
                             "N"),5)), 
                  Weight=c(6,1,1,0,9.1,3,3,3,1,1,4,1,1,2,3))

# Adjusting the graph.
# 1. adjusting colors.

#c5cbff , #adb2df , #9b9fc6 , #8186b3 , #5c69da
colors_link <- c('#adb2df', '#b7b8b9', 'lightblue', '#d3d6ea', '#9b9fc6')
colors_link_array <- paste0("[", paste0("'", colors_link,"'", collapse = ','), "]")

colors_node <- c('#dde1ff', '#dde1ff', '#dde1ff', '#dde1ff',
                 '#dde1ff', '#dde1ff', '#dde1ff','#dde1ff')
colors_node_array <- paste0("[", paste0("'", colors_node,"'", collapse = ','), "]")

opts <- paste0("{
               link: { colorMode: 'source',
               colors: ", colors_link_array ," },
               node: { colors: ", colors_node_array ," }
               }" )


sk2 <- gvisSankey(dat, from="From", to="To", weight="Weight",
        options=list(height=500, width=800, sankey=opts))
plot(sk2)


# getting HTML file
cat(sk2$html$chart, file="tmp.html")


# take a snapshot from the chart
webshot::webshot("tmp.html", file="out.png", delay=2)


###############
## multi-level charts


datSK <- data.frame(From=c(rep("A",3), rep("B", 3), rep(c("X", "Y", "Z"), 2 )),
                    To=c(rep(c("X", "Y", "Z"),2), rep("M", 3), rep("N", 3)),
                    Weight=c(5,7,6,2,9,4,3,4,5,6, 4,8))


library( riverplot)
x <- riverplot.example()
plot( x )
