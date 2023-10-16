##Main script for NWS weather data visualization.##

##Inputs##
ZipUpdate<-TRUE
ZipCode<-"21005"

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