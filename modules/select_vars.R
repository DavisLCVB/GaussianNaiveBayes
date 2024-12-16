select_vars_ui <- function(id) {
  ns <- NS(id)
  sidebarLayout(
    sidebarPanel(
      selectInput(ns("predictors"), "Seleccionar Variables Predictoras:", choices = NULL, multiple = TRUE),
      selectInput(ns("target"), "Seleccionar Variable Objetivo:", choices = NULL)
    ),
    mainPanel(
      h3("Variables seleccionadas"),
      textOutput(ns("predicted_vars")),
      textOutput(ns("selected_vars"))
    )
  )
}

select_vars_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    observe({
      req(data())
      col_names <- names(data())
      updateSelectInput(session, "predictors", choices = col_names)
      updateSelectInput(session, "target", choices = col_names)
    })
    selected_vars <- reactive({
      req(input$predictors, input$target)
      list(predictors = input$predictors, target = input$target)
    })
    output$predicted_vars <- renderText({
      paste("Variables predictoras seleccionadas:", paste(selected_vars()$predictors, collapse = ", "))
    })
    output$selected_vars <- renderText({
      paste("Variable objetivo seleccionada:", selected_vars()$target)
    })
    return(selected_vars)
  })
}
