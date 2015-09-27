library(shiny)
library(timeDate)
library(ggplot2)
library(dplyr)
library(lazyeval)

tracker_data <- readRDS("data/tracker_data.RDS")

function(input, output) {
        # Transform X and Y for summarise
        mean_y <- reactive ({interp(~ mean(var, na.rm=TRUE), var = as.name(input$y))})
        sd_y <- reactive ({interp(~ sd(var, na.rm=TRUE), var = as.name(input$y))})
        
        # Get the Date range
        date.from <- reactive({input$dateRangeInput[1]})
        date.to <- reactive({input$dateRangeInput[2]})
        
        # Create the facets (weekday, weekend and/or holidays)
        filter.type <- reactive({
                types <- character(0)
                if (input$workingdays) {
                 types <- append(types, 'WORKDAY') 
                }
                if (input$weekends) {
                 types <- append(types, 'WEEKEND')
                }
                if (input$holidays) {
                 types <- append(types, 'HOLIDAY')
                }
                types
        })
        
        # Filter the dataset with the given values
        dataset <- reactive({subset(tracker_data, date >= date.from() & date <= date.to() & Day.Type %in% filter.type())})
        
        # Contains the mean and standard error for the displayed graphs
        output$table <- renderTable({
                summarise_(group_by(dataset(), Day.Type), Mean = mean_y(), SD = sd_y())
        })
        
        # Update the plot
        output$plot <- renderPlot({
                p <- ggplot(data = dataset(), aes_string(x=input$x, y=input$y)) + theme_bw() + geom_point()
                
                # If Selected show the proper data
                if (input$workingdays | input$weekends | input$holidays) {
                 p <- p + facet_grid('. ~ Day.Type')
                }
                 
                # Select the regression method to use. Both can be plotted
                if (input$linear) {
                        p <- p + geom_smooth(method = "lm", color="blue")
                }
                if (input$loess) {
                         p <- p + geom_smooth(method = "loess", color="red")
                }
                
                print(p)
        })
}