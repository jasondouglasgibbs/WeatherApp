##API Query for NWS Data##
##See https://weather-gov.github.io/api/general-faqs and##
##https://www.weather.gov/documentation/services-web-api for##
##more information.##


##Inputs##
Lat<-"39.4633"
Long<-"-76.1204"


##Builds base URL for forecast information.##
BaseURL<-paste0("https://api.weather.gov/points/", Lat,",", Long)
response<-as.character(RETRY("GET", BaseURL, encode="json",time=10))
content<-FROM_GeoJson(response)
##Store state and city information for later use.#
State<-content$properties$relativeLocation$properties$state
City<-content$properties$relativeLocation$properties$city

##Hourly Forecast
##Retrieve the hourly forecast URL from the overaching API call.##
HourlyForceCastURL<-content$properties$forecastHourly
##Call the API and transform the resulting data into a DF.##
HourlyForceCastresponse<-as.character(RETRY("GET", HourlyForceCastURL, encode="json",time=10))
HourlyForeCastcontent<-FROM_GeoJson(HourlyForceCastresponse)
HourlyForeCastcontent<-HourlyForeCastcontent$properties$periods
HourlyForeCastcontent<-lapply(HourlyForeCastcontent, function(x) {unlist(x)})
HourlyForeCastcontent<-dplyr::bind_rows(HourlyForeCastcontent)
