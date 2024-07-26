##Main script for NWS weather data visualization.##

##Inputs##
ZipUpdate<-TRUE
ZipCode<-"40121"

##Scripts
source("libraries.R")

tic("Total.")

tic("Zip to Lat Long Update.")
if(ZipUpdate){
  source("ZipToLatLongUpdater.R")
}
toc()

tic("API Query.")
source("APIQuery.R")
toc()

tic("Data Wrangling.")
source("datawrangling.R")
toc()

tic("AQI Data")
source("airquality.R")
AQILocation
AQI
AQIO3Fore
AQIpm10Fore
AQIpm25Fore
toc()

tic("Plotting")
source("plotting.R")
HourlyTemp
HourlyRelHumid
HourlyPrecip
WindSpeedDirPlot
WindSpeedDirPlotly
HourlyDewPoint
toc()

toc()