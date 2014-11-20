# load libraries and data set
library(shiny)
library(ggplot2)
library(dplyr)
data(economics)

shinyUI(fluidPage(
  
  # Title
  titlePanel("US Unemployment Data"),
  #Instructions
  strong("Directions"),
  br(),
  "1) Set the date range cutoff points for the plot data using the date range input",
  br(),
  "This will update the average percent of the population that was unemployed in the section below in blue",
  br(),
  br(),
  "2) Set the max % population unemployed threshold to count the number of months over the specified period where the % of the population that was unemployed exceeded the specified threshold",
  br(),
  br(),
  # Date range for data
  strong("Inputs"),
  inputPanel(
    dateRangeInput("date",
                   "Date Range to Show in Plot",
                   start = min(economics$date),
                   end = max(economics$date),
                   min = min(economics$date),
                   max = max(economics$date)),
    
    # Slider for threshold unemployment level
    sliderInput("max_unemp",
                "Max % Population Unemployed",
                min = 0,
                max = 6,
                value = 2,
                step = 0.25,
                ticks = TRUE)
    
  ),
  
  
  # show plot of data
  mainPanel(
    plotOutput("unemp_data"),
    textOutput("avg_unemp_part1"),
    strong(h4(textOutput("avg_unemp_part2"))),
    tags$head(tags$style("#avg_unemp_part2{color: blue;
                         font-size: 20px;
                         }"
    )
    ),
    br(),
    
    # display months above threshold
    uiOutput("num_months_above_rate")
    )

  
  ))
