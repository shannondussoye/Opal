setwd("/home/shannon/R/Projects/Opal/")
library(dplyr)
library(stringr)
library(jsonlite)

data <- read.csv("Data/time-loc_20160725-31.csv") %>% filter(mode=="train")
stations <- data %>% select(loc) %>% unique()
stations$loc2 <- as.character(stations$loc) %>% paste(",New South Wales",sep="")
#geocode
stations$geo <- NA
for(i in 1:nrow(stations)){
  print(paste("Working on index", i))
  #query the google geocoder - this will pause here if we are over the limit.
  stations$geo[i] <- getGeoDetails(stations$loc2[i])
  print(substrRight(stations$geo[i],6))
}


stations[,c(4:6)] <- str_split_fixed(string = stations$geo,pattern = ";",n = 3)
stations <- stations %>% select(-c(V6,geo,loc2)) %>% rename(lat=V4,lon=V5)

data <- left_join(data,stations,by="loc")

write.csv(data,"geocoded_date.csv")

townhalldata <- data %>% filter(loc=="Town Hall Station",date=="20160725")
townhalldata$latlon <- paste(townhalldata$lat,townhalldata$lon,sep = ",")
write.csv(townhalldata,"townhalldata.csv")
townhalldatajson <- townhalldata %>% toJSON()
write_json(townhalldatajson,"townhalldata.json")

data %>% filter(loc=="Town Hall Station") %>% 
  ggplot(aes(x=time,y=count,fill=tap)) +  
  geom_histogram(stat = "identity",position = "dodge") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_grid(date ~. )


data %>% filter(loc=="Town Hall Station",date=="20160730")

d3_data <- data %>% filter(date=="20160730",tap=="on") %>% arrange(time)
write.csv(d3_data,"d3-data.csv")
