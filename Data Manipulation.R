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
  select(datetime,date,time) %>% unique() 

# timestamp <- timestamp %>% filter(!is.na(datetime))

# timestamp$datetime <- as.POSIXct(strptime(timestamp$datetime, "%Y%m%d %H:%M"))
# timestamp$datetime <- arrange(timestamp,-desc(datetime)) 

stations$j <- 1
timestamp$j <- 1

data <- inner_join(stations,timestamp,by='j') %>% select(-j)
data <- arrange(data,datetime,loc)

rm(stations)
rm(timestamp)

train_tap_on <- train_tap_on %>% select(-tap,-lat,-lon,-date,-time)
data <- left_join(data,train_tap_on,by=c("datetime","loc"))
data["count"][is.na(data["count"])] <- 0


avg_count <- data %>% select(loc,date,count) %>% group_by(loc,date) %>% summarise(avg=mean(count)) 
avg_count$avg <- round(avg_count$avg)

d3_data <- inner_join(data,avg_count, by=c("loc","date"))
d3_data$size <- ifelse(!d3_data$count, 0, d3_data$count / d3_data$avg)
d3_data$size[is.infinite(d3_data$size) | is.nan(d3_data$size)] <- NA 
write.csv(d3_data,"/home/shannon/Github/Opal/D3-data.csv",row.names = F)
