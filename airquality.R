##Air Quality Script##
##Reference: https://aqicn.org/api/"
AQItoken<-"6640265ae7ee49e61eed86a7ce4d2687ed07d3ba"


##Builds base URL for AQI information and queries the API.##
BaseURL<-paste0("http://api.waqi.info/feed/geo:", Lat$latitude,";", Long$longitude,"/?token=",AQItoken)
response<-as.character(RETRY("GET", BaseURL, encode="json",time=10))
content<-jsonlite::fromJSON(response)
AQI<-content$data$aqi
AQI
##Creates dataframes for each pollutant that is forecasted and binds them together##
AQIO3Fore<-content$data$forecast$daily$o3
AQIO3Fore$pollutant<-"o3"
AQIpm10Fore<-content$data$forecast$daily$pm10
AQIpm10Fore$pollutant<-"pm10"
AQIpm25Fore<-content$data$forecast$daily$pm25
AQIpm25Fore$pollutant<-"pm2.5"
AQIForecast<-bind_rows(AQIO3Fore,AQIpm10Fore,AQIpm25Fore)
AQIForecast$day<-as.Date(AQIForecast$day)

##Creates a plot of the AQI data.##
AQIPlot<-ggplot(data=AQIForecast, aes(x=day, y = max, color=pollutant))+
  geom_line()+xlab("Date")+ylab("Individual AQI by Pollutant")
AQIPlotly<-ggplotly(AQIPlot)
AQIPlotly

