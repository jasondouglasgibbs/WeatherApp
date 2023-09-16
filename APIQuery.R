##API Query for NWS Data##
##See https://weather-gov.github.io/api/general-faqs and##
##https://www.weather.gov/documentation/services-web-api for##
##more information.##


##Inputs##
Lat<-"38.8894"
Long<-"-77.0352"


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

##Data coericion, cleaning, and analysis.##

##Start time to POSIXct##
HourlyForeCastcontent$startTime<-substr(HourlyForeCastcontent$startTime,1,
                                        nchar(HourlyForeCastcontent$startTime)-6)
HourlyForeCastcontent$startTime<- gsub("T"," ", HourlyForeCastcontent$startTime) 
HourlyForeCastcontent$startTime<-as.POSIXct(HourlyForeCastcontent$startTime)

##Temperature to numeric.##
HourlyForeCastcontent$temperature<-as.numeric(HourlyForeCastcontent$temperature)

##Relative Humidity to numeric.##
HourlyForeCastcontent$relativeHumidity.value<-as.numeric(HourlyForeCastcontent$relativeHumidity.value)


##Add Wind Direction as numeric (degrees).##
HourlyForeCastcontent<-as.data.frame(HourlyForeCastcontent)
HourlyForeCastcontent$Wind_Direction_Degrees<-NA_integer_

for(i in 1:nrow(HourlyForeCastcontent)){
  if(HourlyForeCastcontent[i,"windDirection"]=="N"){
    HourlyForeCastcontent[i,"Wind_Direction_Degrees"]<-0
  }else if(HourlyForeCastcontent[i,"windDirection"]=="NE"){
    HourlyForeCastcontent[i,"Wind_Direction_Degrees"]<-45
  }else if(HourlyForeCastcontent[i,"windDirection"]=="E"){
    HourlyForeCastcontent[i,"Wind_Direction_Degrees"]<-90
  }else if(HourlyForeCastcontent[i,"windDirection"]=="SE"){
    HourlyForeCastcontent[i,"Wind_Direction_Degrees"]<-135
  }else if(HourlyForeCastcontent[i,"windDirection"]=="S"){
    HourlyForeCastcontent[i,"Wind_Direction_Degrees"]<-180
  }else if(HourlyForeCastcontent[i,"windDirection"]=="SW"){
    HourlyForeCastcontent[i,"Wind_Direction_Degrees"]<-225
  }else if(HourlyForeCastcontent[i,"windDirection"]=="W"){
    HourlyForeCastcontent[i,"Wind_Direction_Degrees"]<-270
  }else{
    HourlyForeCastcontent[i,"Wind_Direction_Degrees"]<-315
  }
}

##Coerce Wind Speed to numeric##
HourlyForeCastcontent$windSpeed<-substr(HourlyForeCastcontent$windSpeed,1,
                                        nchar(HourlyForeCastcontent$windSpeed)-4)
HourlyForeCastcontent$windSpeed<-as.numeric(HourlyForeCastcontent$windSpeed)
HourlyForeCastcontent$DATE<-date(HourlyForeCastcontent$startTime)
