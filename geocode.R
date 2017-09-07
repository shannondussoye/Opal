# Geocoding script for large list of addresses.
# Shane Lynn 10/10/2013

#load up the ggmap library
library(ggmap)

#define a function that will process googles server responses for us.
getGeoDetails <- function(address){   
  #use the gecode function to query google servers
  geo_reply = geocode(address, output = 'all', messaging = TRUE, override_limit = TRUE)
  #now extract the bits that we need from the returned list
  answer <- data.frame(lat = NA, long = NA, accuracy = NA, formatted_address = NA, address_type = NA, status = NA)
  geo_reply$status
  answer$status <- geo_reply$status
  
  #if we are over the query limit - want to pause for an hour
  while (geo_reply$status == "OVER_QUERY_LIMIT")
  {
    print("OVER QUERY LIMIT - Pausing for 1 hour at:") 
    time <- Sys.time()
    print(as.character(time))
    Sys.sleep(60*60)
    geo_reply = geocode(address, output = 'all', messaging = TRUE, override_limit = TRUE)
    answer$status <- geo_reply$status
  }
  
  #return Na's if we didn't get a match:
  if (geo_reply$status != "OK") 
  {
    return(answer)
  }   
  #else, extract what we need from the Google server reply into a dataframe:
  answer$lat <- geo_reply$results[[1]]$geometry$location$lat
  answer$long <- geo_reply$results[[1]]$geometry$location$lng   
  if (length(geo_reply$results[[1]]$types) > 0) {
    answer$accuracy <- geo_reply$results[[1]]$types[[1]]
  }
  answer$address_type <- paste(geo_reply$results[[1]]$types, collapse = ',')
  answer$formatted_address <- geo_reply$results[[1]]$formatted_address
  answer <- paste(answer$lat,answer$long,answer$accuracy,answer$formatted_address,answer$address_type,answer$status,sep = ";")
  return(answer)
}

substrRight <- function(x,n){substr(x, nchar(x) - n + 1, nchar(x))}

