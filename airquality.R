##Air Quality Script##
##Reference: https://aqicn.org/api/"
AQItoken<-"6640265ae7ee49e61eed86a7ce4d2687ed07d3ba"


##Builds base URL for forecast information.##
BaseURL<-paste0("http://api.waqi.info/feed/geo:", Lat$latitude,";", Long$longitude,"/?token=",AQItoken)
response<-as.character(RETRY("GET", BaseURL, encode="json",time=10))
content<-jsonlite::fromJSON(response)
AQI<-content$data$aqi
AQI

AQIO3Fore<-content$data$forecast$daily$o3
AQIO3Fore
AQIpm10Fore<-content$data$forecast$daily$pm10
AQIpm10Fore
AQIpm25Fore<-content$data$forecast$daily$pm25
AQIpm25Fore

AQILocation<-content$data$city$name
