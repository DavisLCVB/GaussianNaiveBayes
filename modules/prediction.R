prediction_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarPanel(
      h4("Ingresar Nuevos Datos"),
      uiOutput(ns("input_fields")),
      actionButton(ns("predict_btn"), "Realizar Predicción"),
      hr(),
      h4("Cargar Datos para Predicción"),
      fileInput(ns("upload_data"), "Subir Archivo CSV", accept = ".csv"),
      actionButton(ns("predict_file_btn"), "Predecir para Datos Subidos")
    ),
    mainPanel(
      h3("Resultados de la Predicción"),
      verbatimTextOutput(ns("prediction_result")),
      DTOutput(ns("prediction_table"))
    )
  )
}


prediction_server <- function(id, model, selected_vars) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    predictions <- reactiveVal(NULL) # Reactivo para almacenar las predicciones

    # Generar dinámicamente los campos de entrada para las variables predictoras
    output$input_fields <- renderUI({
      req(selected_vars())
      predictors <- selected_vars()$predictors

      lapply(predictors, function(var) {
        # Detectar el tipo de variable
        if (is.factor(data()[[var]])) { # Variable categórica
          selectInput(ns(var), var, choices = unique(data()[[var]]), selected = unique(data()[[var]])[1])
        } else { # Variable numérica
          numericInput(ns(var), var, value = mean(data()[[var]], na.rm = TRUE))
        }
      })
    })

    # Predicción para datos manuales
    observeEvent(input$predict_btn, {
      req(model(), selected_vars())
      predictors <- selected_vars()$predictors

      # Crear un data frame con las entradas manuales
      new_data <- as.data.frame(lapply(predictors, function(var) input[[var]]))
      colnames(new_data) <- predictors

      # Realizar la predicción
      pred_result <- predict(model(), new_data)
      predictions(data.frame(new_data, Predicción = pred_result)) # Guardar predicciones en reactiveVal
    })

    # Predicción para archivo cargado
    observeEvent(input$predict_file_btn, {
      req(input$upload_data, model(), selected_vars())
      predictors <- selected_vars()$predictors

      # Leer los datos subidos
      new_data <- read.csv(input$upload_data$datapath)

      # Validar que las columnas coincidan con las variables predictoras
      if (!all(predictors %in% colnames(new_data))) {
        stop("El archivo subido no contiene todas las columnas requeridas.")
      }

      # Realizar la predicción
      pred_result <- predict(model(), new_data[, predictors, drop = FALSE])
      predictions(data.frame(new_data, Predicción = pred_result)) # Guardar predicciones en reactiveVal
    })

    # Mostrar tabla de predicciones
    output$prediction_table <- renderDT({
      req(predictions())
      datatable(predictions(), options = list(pageLength = 5))
    })

    # Retornar las predicciones como output del módulo
    return(predictions)
  })
}
