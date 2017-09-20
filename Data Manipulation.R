library(dplyr)
library(lubridate)

opal_data <- read.csv("Full Data.csv") %>% select(-X,-mode) %>% filter(loc!="UNKNOWN")
train_tap_on <- opal_data %>% filter(tap=="on")
# train_tap_off <- opal_data %>% filter(tap=="off")
rm(opal_data)

train_tap_on <- mutate(train_tap_on,datetime=paste(date,time,sep=" "))

stations <- train_tap_on %>% 
  select(loc,lat,lon) %>% 
  unique()

timestamp <- train_tap_on %>% 
  select(datetime) %>% unique() 

# timestamp <- timestamp %>% filter(!is.na(datetime))

timestamp$datetime <- as.POSIXct(strptime(timestamp$datetime, "%Y%m%d %H:%M"))
timestamp$datetime <- arrange(timestamp,-desc(datetime)) 

stations$j <- 1
timestamp$j <- 1

data <- inner_join(stations,timestamp,by='j') %>% select(-j)
data <- arrange(data,datetime,loc)
write.csv(data,"/home/shannon/Github/Opal/D3-data.csv",row.names = F)
