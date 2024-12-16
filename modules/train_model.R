train_model_ui <- function(id) {
  ns <- NS(id)
  sidebarLayout(
    sidebarPanel(
      actionButton(ns("train"), "Entrenar Modelo")
    ),
    mainPanel(
      h3("Resultados del Modelo"),
      verbatimTextOutput(ns("model_summary"))
    )
  )
}

train_model_server <- function(id, data, selected_vars) {
  moduleServer(id, function(input, output, session) {
    model <- reactiveVal(NULL)
    observeEvent(input$train, {
      req(data(), selected_vars())
      predictors <- selected_vars()$predictors
      target <- selected_vars()$target
      req(predictors, target)

      X <- data()[, predictors, drop = FALSE]
      y <- data()[[target]]
      gnb_model <- naiveBayes(X, y, laplace = 1)
      model(gnb_model)
    })

    output$model_summary <- renderPrint({
      req(model())
      model()
    })
    return(model)
  })
}
