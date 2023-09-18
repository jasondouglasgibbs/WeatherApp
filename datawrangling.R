##Data Wrangling and Analysis.##

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

##Coerce Wind Speed to numeric.##
HourlyForeCastcontent$windSpeed<-substr(HourlyForeCastcontent$windSpeed,1,
                                        nchar(HourlyForeCastcontent$windSpeed)-4)
HourlyForeCastcontent$windSpeed<-as.numeric(HourlyForeCastcontent$windSpeed)
HourlyForeCastcontent$DATE<-date(HourlyForeCastcontent$startTime)


##Convert Dewpoint from Celsius to Fahrenheit.##
HourlyForeCastcontent$dewpoint.value<-as.numeric(HourlyForeCastcontent$dewpoint.value)
HourlyForeCastcontent$DEWPOINT_FAHRENHEIT<-round(((HourlyForeCastcontent$dewpoint.value)*(9/5))+32,
                                              digits = 0)

##Coerce probability of Precipitation value to numeric.##
HourlyForeCastcontent$probabilityOfPrecipitation.value<-as.numeric(HourlyForeCastcontent$probabilityOfPrecipitation.value)