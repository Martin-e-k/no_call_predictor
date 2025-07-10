# This is a Shiny app that takes patient information and returns a probabilty that
# a NIPT test will fail due to low fetal fraction

library(shiny)

# Load the model
model <- readRDS("models/glm_smote_demo_model.rds")

# Example: predict from user input
newdata <- data.frame(
  BMI = 28,
  Gatotal = 100,
  NF = 1.8,
  HCG = 1.255,
  PAPPA = 0.755,
  conception_group = "natural"
)

# Make prediction
prob <- predict(model, newdata = newdata, type = "response")

ui <- fluidPage(
  titlePanel("Likelihood of NIPT test failure due to insufficient fetal fraction"),

  
  sidebarLayout(
    sidebarPanel(
      numericInput("BMI", "BMI:", value = 28, min = 10, max = 60),
      numericInput("Gatotal", "Gestational Age Total (days):", value = 100, min = 70, max = 300),
      numericInput("NF", "Nuchal Fold (NF):", value = 1.8, min = 0.1, max = 10, step = 0.1),
      numericInput("HCG", "HCG MoM:", value = 1.255, min = 0.01, max = 10, step = 0.01),
      numericInput("PAPPA", "PAPP-A MoM:", value = 0.755, min = 0.01, max = 10, step = 0.01),
      
      selectInput("conception_group", "Conception Method:",
                  choices = c("natural", "assisted"),
                  selected = "natural"),
      
      actionButton("predict_btn", "Predict")
    ),
    
    mainPanel(
      h3("Predicted Failure Probability"),
      verbatimTextOutput("prediction_output"),
      
      tags$hr(),
      
      tags$div(
        style = "color: red; font-weight: bold;",
        "⚠️ Disclaimer: This app is a demo only. The predictions shown are based on a preliminary model and should not be used for clinical decision-making."
      )
    )
  )
)

server <- function(input, output, session) {
  
  model <- readRDS("models/glm_smote_demo_model.rds")
  
  observeEvent(input$predict_btn, {
    newdata <- data.frame(
      BMI = input$BMI,
      Gatotal = input$Gatotal,
      NF = input$NF,
      HCG = input$HCG,
      PAPPA = input$PAPPA,
      conception_group = input$conception_group
    )
    
    # Make prediction
    prob <- predict(model, newdata = newdata, type = "response")
    
    output$prediction_output <- renderText({
      paste0("Estimated risk of failure: ", round(prob * 100, 1), "%")
    })
  })
}

shinyApp(ui, server)
