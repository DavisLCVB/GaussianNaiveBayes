visualization_ui <- function(id) {
  ns <- NS(id)
  sidebarLayout(
    sidebarPanel(
      selectInput(ns("visualization_type"), "Tipo de Visualización:",
        choices = c("Distribuciones", "Dispersión 2D")
      ),
      conditionalPanel(
        condition = "input.visualization_type == 'Dispersión 2D'",
        ns = ns,
        selectInput(ns("x_var"), "Variable en el Eje X:", choices = NULL),
        selectInput(ns("y_var"), "Variable en el Eje Y:", choices = NULL)
      )
    ),
    mainPanel(
      h3("Visualización de Resultados"),
      plotlyOutput(ns("plot_output")),
      verbatimTextOutput(ns("conf_matrix"))
    )
  )
}

visualization_server <- function(id, data, selected_vars, model) {
  moduleServer(id, function(input, output, session) {
    # Actualizar opciones de variables predictoras
    observe({
      req(selected_vars())
      col_names <- selected_vars()$predictors
      updateSelectInput(session, "x_var", choices = col_names)
      updateSelectInput(session, "y_var", choices = col_names)
    })

    # Renderizar el gráfico de salida
    output$plot_output <- renderPlotly({
      req(data(), selected_vars(), model(), input$visualization_type)
      vis_type <- input$visualization_type
      X <- data()[, selected_vars()$predictors, drop = FALSE]
      y <- data()[[selected_vars()$target]]

      if (vis_type == "Dispersión 2D") {
        req(input$x_var, input$y_var)
        gg <- ggplot(data(), aes_string(x = input$x_var, y = input$y_var, color = selected_vars()$target)) +
          geom_point(size = 3) +
          labs(title = "Dispersión 2D de las Clases") +
          theme_minimal()
        ggplotly(gg)
      } else if (vis_type == "Distribuciones") {
        gg <- ggplot(data(), aes_string(x = selected_vars()$predictors[1], fill = selected_vars()$target)) +
          geom_density(alpha = 0.5) +
          labs(title = "Distribuciones de Clases") +
          theme_minimal()
        ggplotly(gg)
      }
    })

    # Renderizar la matriz de confusión
    output$conf_matrix <- renderPrint({
      req(data(), selected_vars(), model())
      X <- data()[, selected_vars()$predictors, drop = FALSE]
      y_true <- data()[[selected_vars()$target]]
      y_pred <- predict(model(), X)

      table(Predicción = y_pred, Real = y_true)
    })
  })
}
