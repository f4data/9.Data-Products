library(shiny)

tracker_data <- readRDS("data/tracker_data.RDS")

# The type of day will be used for the facets
type.index <- which(names(tracker_data)=="Day.Type")

shinyUI(fluidPage(
        
        titlePanel("Tracked Activities Explorer"),
        
        plotOutput('plot'),
        
        fluidRow(
                tabsetPanel(
                        tabPanel("Overview",
                                 div(
                                         p("Nowadays the activity trackers provide a lot of information for the end users but the real challenge is to extract useful information from all the data gathered."),
                                         p("In the period of time from 2015-04-01 to 2015-08-31 I have tracked myself with a ", a(href='http://www2.withings.com/eu/en/products/activite/','Withings Activite watch'), " in the following areas: activity (number of steps), sleeping time, blood pressure and weight."),
                                         p("The data is easily accessible through Withings ",a(href='https://healthmate.withings.com/','website')," and can be downloaded in form of tabularized data."),
                                         p("The information has been summarized as a daily record and has been cleaned for a better usage."),
                                         p("The goal of this project is to perform an exploratory analysis and observe potential differences between workdays, weekends and holidays."),
                                         p("The parameters evaluated are the following:"),
                                         tags$ol(
                                                 tags$li("date: date where the data was collected"),
                                                 tags$li("Steps: number of steps walked or run"),
                                                 tags$li("Distance.km: number of KM walked"),
                                                 tags$li("Calories: number of Calories burned"),
                                                 tags$li("Deep.Sleep.hrs: number of hours of deep sleep"),
                                                 tags$li("Light.Sleep.hrs: number of hours of light sleep"),
                                                 tags$li("Total.Sleep.hrs: number of hours of deep and light sleep"),
                                                 tags$li("Awake.hrs: number of hours awake while lying on the bed without sleeping (e.g. reading)"),
                                                 tags$li("Wake.Up.times: number of times wake up during the sleep"),
                                                 tags$li("Heart.Rate.bpm: Beats Per Minute measured"),
                                                 tags$li("Weight.kg: weight in KG"),
                                                 tags$li("Fat.Mass.percent: percentage of fat in the body")
                                        )
                                 )
                        ),
                        tabPanel("Parameters", 
                                 column(3,
                                        dateRangeInput('dateRangeInput', 'Date Range', 
                                                       start = '2015-04-02', end = '2015-09-01', 
                                                       min = '2015-04-01', max = '2015-08-31', 
                                                       format = "yyyy-mm-dd", startview = "month", weekstart = 1, 
                                                       language = "en", separator = " to "),
                                        
                                        br(),
                                        selectInput('x', 'X', names(tracker_data[,-type.index])),
                                        selectInput('y', 'Y', names(tracker_data[,-type.index]), names(tracker_data)[[3]])
                                 ),
                                 column(2, offset=1,
                                        h4('Type of day:'),
                                        checkboxInput('workingdays', 'Working Days', value = TRUE),
                                        checkboxInput('weekends', 'Weekends'),
                                        checkboxInput('holidays', 'Holidays')
                                 ),
                                 column(2,
                                        h4('Type of Regression:'),
                                        checkboxInput('linear', 'Linear'),
                                        checkboxInput('loess', 'Loess')
                                 ),
                                 column(2,
                                        h4('Statistics of Y'),
                                        tableOutput('table')
                                 )
                        ),
                         tabPanel("Help",
                                div(
                                        h4('Date Range'),
                                        p('Choose the date range to analyze. Min: 2015-04-01. Max: 2015-08-31'),
                                        h4('X and Y'),
                                        p('Choose what variables to display. See Overview Tab for a description.'),
                                        h4('Type of Day'),
                                        p('Choose what data to display'),
                                        tags$ol(
                                                tags$li('Working Days: typically from Monday to Friday'),
                                                tags$li('Weekends: just Saturday and Sunday'),
                                                tags$li('Holidays: official bank holidays and days off')
                                        ),
                                        h4('Type of Regression'),
                                        tags$ol(
                                                tags$li('Linear: fits a linear model in the data'),
                                                tags$li('Loess: fits a loess model in the data')
                                        ),
                                        h4('Statistics of Y'),
                                        p('Computes the MEAN and STANDARD DEVIATION for the selected Y variable in the selected types of days')                                 
                                )
                        ),
                        selected="Parameters"
                )
      )
))