#load libraries
library(shiny)
library(ggplot2)
library(dplyr)
library(reshape2)
library(scales)
data(economics)

shinyServer(function(input, output) {
  
  # filter data
  economic_data <- reactive({
    filter(economics,
           date >= input$date[1],
           date <= input$date[2]) %>%
      mutate(psavert = psavert/100, unemp_rt = (unemploy / pop))
  })
  
  # plot unemployment data
  output$unemp_data <- renderPlot({
    # combine unemployment and savings rate
    combined_data <-  select(economic_data(), 
                             date, `Personal Savings Rate` = psavert, `Percent of Population Unemploymed` = unemp_rt) %>%
      melt(id = c("date"))
    
    
    # create plot
    ggplot(combined_data, aes(x = date, y = value, color = variable)) +
      geom_line(size = 1, aes(linetype = variable)) +
      scale_color_manual(values = c("green", "red")) +
      xlab ("Date") + 
      ylab ("%") +
      theme (legend.position = "bottom",
             legend.text = element_text(size = 15), 
             panel.background = element_rect(fill = "Black"),
             panel.grid.minor = element_blank(),
             panel.grid.major = element_line(color = "grey", linetype = "dotted"),
             axis.title = element_text(size = 15, color = "Black"),
             axis.text = element_text(size = 10, color = "Black")) +
      scale_y_continuous(labels = percent)
    
  })
  
  #output average unemployment, but split into parts to format calculated values differently
  output$avg_unemp_part1 <- renderText({
    paste0("The average percent of the population that was unemployed (NOT THE SAME AS UNEMPLOYMENT RATE) over the selected period is ")
  })
  
  output$avg_unemp_part2 <- renderText({
    paste0(round(mean(economic_data()$unemp_rt)*100,2), "%")
  })
  
  #determine the number of months above the % of the population unemployed
  output$num_months_above_rate <- renderUI ({
    number_months <- nrow(economic_data())
    above_rate <- filter(economic_data(), unemp_rt > input$max_unemp/100) %>%
      nrow()
    
    
    # split to allow for bolding of calculated values only
    part1 <- paste("The number of months where the % of the population unemployed exceeded the selected rate of ", sep = "")
    output[["part2"]] <- renderText({
      paste(input$max_unemp, sep = "")
    })
    
    part3 <- paste0("% within the specified date range is ")
    output[["part4"]] <- renderText({
      paste0(above_rate)
    })
    part5 <- paste0(" months out of ")
    output[["part6"]] <- renderText({ 
      paste0(number_months)
    })
    part7 <- paste0("total months in the period (")
    output[["part8"]] <- renderText({
      paste0(round((above_rate / number_months) * 100, 2))
    })
    part9 <- paste0("% of the time)")
    
    # output a list of text outputs to display all at once
    list(    
      fluidRow(
        part1,
        textOutput("part2"),
        tags$head(tags$style("#part2{color: blue;
                             font-size: 20px;
  }")),
        part3,
        textOutput("part4"),
        tags$head(tags$style("#part4{color: blue;
                             font-size: 20px;
}")),
        part5,
        textOutput("part6"),
        tags$head(tags$style("#part6{color: blue;
                             font-size: 20px;
}")),
        part7,
        textOutput("part8"),
        tags$head(tags$style("#part8{color: blue;
                             font-size: 20px;
}")),
        part9
        )
      )
    
    
    
})

})
