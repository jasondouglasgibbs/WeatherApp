##Main script for NWS weather data visualization.##

##Inputs##
ZipUpdate<-FALSE

##Scripts
source("libraries.R")
if(ZipUpdate){
  source("ZipToLatLongUpdater.R")
}
source("APIQuery.R")
source("datawrangling.R")
source("plotting.R")
HourlyTemp
HourlyRelHumid
HourlyPrecip
WindSpeedDirPlot
WindSpeedDirPlotly
HourlyDewPoint