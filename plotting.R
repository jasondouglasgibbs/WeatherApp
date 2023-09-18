##Plotting##

##Plots data from API Query.R##

##Hourly Temp##
HourlyTemp <- ggplot(HourlyForeCastcontent, aes(x=startTime, y=temperature)) +
  geom_point() + 
  xlab("Date")+scale_x_datetime(labels = date_format("%Y-%m-%d"),
                                date_breaks = "24 hours")+ylab("Temperature (Degrees F)")
HourlyTemp<-ggplotly(HourlyTemp)
HourlyTemp


##Hourly Relative Humidity.##
HourlyRelHumid <- ggplot(HourlyForeCastcontent, aes(x=startTime, y=relativeHumidity.value)) +
  geom_point() + 
  xlab("Date")+scale_x_datetime(labels = date_format("%Y-%m-%d"),
                                date_breaks = "24 hours")+ylab("Relative Humidity (%)")
HourlyRelHumid<-ggplotly(HourlyRelHumid)
HourlyRelHumid

##Hourly Probability of Precipitation.##
HourlyPrecip <- ggplot(HourlyForeCastcontent, aes(x=startTime, y=probabilityOfPrecipitation.value)) +
  geom_point() + 
  xlab("Date")+scale_x_datetime(labels = date_format("%Y-%m-%d"),
                                date_breaks = "24 hours")+
  ylab("Probability of Precipitation (%)")
HourlyPrecip<-ggplotly(HourlyPrecip)
HourlyPrecip


##Wind Speed and Direction.##

WindSpeedDirPlot<-ggplot(HourlyForeCastcontent) +
  geom_segment(aes(x = startTime,
                   y = 0,
                   xend = startTime + lubridate::dhours(windSpeed * 1 * -cos((90-Wind_Direction_Degrees) / 360 * 2 * pi)),
                   yend = windSpeed * 1 * -sin((90-Wind_Direction_Degrees) / 360 * 2 * pi),
                   col = factor(startTime)
  ),
  arrow = arrow(length = unit(0.5, "cm"))) +
  geom_point(aes(startTime, 0), size = 1) +
  theme(legend.position = "none")+
  geom_text(aes(label=windSpeed, x=startTime + lubridate::dhours(windSpeed * 1 * -cos((90-Wind_Direction_Degrees) / 360 * 2 * pi)), 
                y=(windSpeed * 1 * -sin((90-Wind_Direction_Degrees) / 360 * 2 * pi))),
            size=3)+
  facet_grid(cols=vars(DATE), space="free_y", scales="free_x")

WindSpeedDirPlot



WindSpeedDirPlotly<-plot_ly(HourlyForeCastcontent) %>%
  add_markers(~startTime, ~0) %>%
  add_annotations( x = ~(startTime + lubridate::dhours(windSpeed * 1 * -cos((90-Wind_Direction_Degrees) / 360 * 2 * pi))),
                   y = ~(windSpeed * 1 * -sin((90-Wind_Direction_Degrees) / 360 * 2 * pi)),
                   xref = "x", yref = "y",
                   axref = "x", ayref = "y",
                   text = "",
                   showarrow = T,
                   ax = ~startTime,
                   ay = ~0,
                   data = HourlyForeCastcontent)%>%
  add_text(text = ~windSpeed, x=~(startTime + lubridate::dhours(windSpeed * 1 * -cos((90-Wind_Direction_Degrees) / 360 * 2 * pi))),
           y=~(windSpeed * 1 * -sin((90-Wind_Direction_Degrees) / 360 * 2 * pi)),
           showlegend=FALSE,
           textfont = list(color = "red"))%>%
  plotly::layout(
    yaxis = list(fixedrange = TRUE,title="Wind Speed (MPH) and Direction",
                 showgrid = TRUE, showline = TRUE, showticklabels = FALSE),
    xaxis = list(fixedrange = TRUE,title="Date", zeroline = FALSE, showline = TRUE, showticklabels = TRUE, showgrid = TRUE)) 
WindSpeedDirPlotly


##Hourly Dew Point##
HourlyDewPoint <- ggplot(HourlyForeCastcontent, aes(x=startTime, y=DEWPOINT_FAHRENHEIT)) +
  geom_point() + 
  xlab("Date")+scale_x_datetime(labels = date_format("%Y-%m-%d"),
                                date_breaks = "24 hours")+ylab("Dew Point (Degrees F)")
HourlyDewPoint<-ggplotly(HourlyDewPoint)
HourlyDewPoint
