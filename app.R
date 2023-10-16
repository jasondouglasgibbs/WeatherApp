## app.R ##
library(shinydashboard)
library(dplyr)
library(httr)
library(conflicted)
library(jsonlite)
library(RJSONIO)
library(geojsonR)
library(plotly)
library(scales)
library(readxl)
library(writexl)
library(stringr)
library(readr)
library(lubridate)
ZipToLatLong<-read_xlsx("ZipToLatLong.xlsx")

ui <- dashboardPage(
  dashboardHeader(title = "Basic Weather Dashboard"),
  dashboardSidebar(
    textInput("zip", "ZIP Code (five numbers):",value=21005),
    actionButton("go", "Go")
  ),
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
      textOutput("WeatherStatement"),
      shinydashboard::box(plotlyOutput("HourlyTemp")),
      shinydashboard::box(plotlyOutput("HourlyPrecip")),
      shinydashboard::box(plotlyOutput("HourlyRelHumid")),
      shinydashboard::box(plotlyOutput("HourlyDewPoint")),
      shinydashboard::box(width=12,plotlyOutput("WindSpeedDirPlotly", width="100%"))
      
    )
  )
)

server <- function(input, output, session) {
  
  observeEvent(input$go,{
    req(input$zip)
    FilteredLatLong<-dplyr::filter(ZipToLatLong, ZIP==input$zip)
    
    ##Inputs##
    Lat<-FilteredLatLong[1,"latitude"]
    Long<-FilteredLatLong[1,"longitude"]
  
    ##Builds base URL for forecast information.##
    BaseURL<-paste0("https://api.weather.gov/points/", Lat,",", Long)
    response<-as.character(RETRY("GET", BaseURL, encode="json",time=10))
    content<-FROM_GeoJson(response)
    ##Store state and city information for later use.#
    State<-content$properties$relativeLocation$properties$state
    City<-content$properties$relativeLocation$properties$city
    output$WeatherStatement<-renderText(paste0("Weather for ", City, ", ", State))
    
    ##Hourly Forecast
    ##Retrieve the hourly forecast URL from the overaching API call.##
    HourlyForceCastURL<-content$properties$forecastHourly
    ##Call the API and transform the resulting data into a DF.##
    HourlyForceCastresponse<-as.character(RETRY("GET", HourlyForceCastURL, encode="json",time=10))
    HourlyForeCastcontent<-FROM_GeoJson(HourlyForceCastresponse)
    HourlyForeCastcontent<-HourlyForeCastcontent$properties$periods
    HourlyForeCastcontent<-lapply(HourlyForeCastcontent, function(x) {unlist(x)})
    HourlyForeCastcontent<-dplyr::bind_rows(HourlyForeCastcontent)
    
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
    
    ##Plotting##
    
    ##Plots data from API Query.R##
    
    ##Hourly Temp##
    HourlyTemp <- ggplot(HourlyForeCastcontent, aes(x=startTime, y=temperature)) +
      geom_point() + 
      xlab("Date")+scale_x_datetime(labels = date_format("%Y-%m-%d"),
                                    date_breaks = "24 hours")+ylab("Temperature (Degrees F)")
    HourlyTemp<-ggplotly(HourlyTemp)
    output$HourlyTemp<-renderPlotly(HourlyTemp)
    
    
    ##Hourly Relative Humidity.##
    HourlyRelHumid <- ggplot(HourlyForeCastcontent, aes(x=startTime, y=relativeHumidity.value)) +
      geom_point() + 
      xlab("Date")+scale_x_datetime(labels = date_format("%Y-%m-%d"),
                                    date_breaks = "24 hours")+ylab("Relative Humidity (%)")
    HourlyRelHumid<-ggplotly(HourlyRelHumid)
    output$HourlyRelHumid<-renderPlotly(HourlyRelHumid)
    
    ##Hourly Probability of Precipitation.##
    HourlyPrecip <- ggplot(HourlyForeCastcontent, aes(x=startTime, y=probabilityOfPrecipitation.value)) +
      geom_point() + 
      xlab("Date")+scale_x_datetime(labels = date_format("%Y-%m-%d"),
                                    date_breaks = "24 hours")+
      ylab("Probability of Precipitation (%)")
    HourlyPrecip<-ggplotly(HourlyPrecip)
    output$HourlyPrecip<-renderPlotly(HourlyPrecip)
    
    
    ##Wind Speed and Direction.##
    
    # WindSpeedDirPlot<-ggplot(HourlyForeCastcontent) +
    #   geom_segment(aes(x = startTime,
    #                    y = 0,
    #                    xend = startTime + lubridate::dhours(windSpeed * 1 * -cos((90-Wind_Direction_Degrees) / 360 * 2 * pi)),
    #                    yend = windSpeed * 1 * -sin((90-Wind_Direction_Degrees) / 360 * 2 * pi),
    #                    col = factor(startTime)
    #   ),
    #   arrow = arrow(length = unit(0.5, "cm"))) +
    #   geom_point(aes(startTime, 0), size = 1) +
    #   theme(legend.position = "none")+
    #   geom_text(aes(label=windSpeed, x=startTime + lubridate::dhours(windSpeed * 1 * -cos((90-Wind_Direction_Degrees) / 360 * 2 * pi)), 
    #                 y=(windSpeed * 1 * -sin((90-Wind_Direction_Degrees) / 360 * 2 * pi))),
    #             size=3)+
    #   facet_grid(cols=vars(DATE), space="free_y", scales="free_x")
    
    
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
    output$WindSpeedDirPlotly<-renderPlotly(WindSpeedDirPlotly)
    
    
    ##Hourly Dew Point##
    HourlyDewPoint <- ggplot(HourlyForeCastcontent, aes(x=startTime, y=DEWPOINT_FAHRENHEIT)) +
      geom_point() + 
      xlab("Date")+scale_x_datetime(labels = date_format("%Y-%m-%d"),
                                    date_breaks = "24 hours")+ylab("Dew Point (Degrees F)")
    HourlyDewPoint<-ggplotly(HourlyDewPoint)
    output$HourlyDewPoint<-renderPlotly(HourlyDewPoint)
  }
  )
  
  session$onSessionEnded(function() {
    stopApp()
  })
}

shinyApp(ui, server)
