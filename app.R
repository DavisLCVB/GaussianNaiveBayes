# Gaussian Naive Bayes
# Grupo 02 - Pentahot Crew
# Entregable del curso de Big Data

# Cargar paquetes
library(shiny) # Para crear la aplicación web
library(DT) # Para mostrar tablas interactivas
library(e1071) # Para entrenar el modelo de Gaussian Naive Bayes
library(ggplot2) # Para visualizar los datos
library(plotly) # Para visualizar los datos


# Cargar módulos
source("modules/load_data.R") # Cargar datos
source("modules/select_vars.R") # Seleccionar variables
source("modules/train_model.R") # Entrenar modelo
source("modules/visualization.R") # Visualizar resultados
source("modules/prediction.R") # Realizar predicciones
source("modules/export.R") # Exportar resultados

ui <- fluidPage(
  tags$head(
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "tailwind.min.css"
    )
  ),
  tags$body(
    style = "background-color: #101418; color: #e1e2e8"
  ),
  div(
    class = "quicksand-title text-5xl text-center text-white p-4",
    titlePanel("Gaussian Naive Bayes"),
  ),
  div(
    class = "container mx-auto bg-[#0b0e13] rounded-lg p-8",
    navbarPage(
    title = div(class = "quicksand-title text-2xl text-white bg-[#191c20] m-0", "Gaussian Naive Bayes"),

    # Pestaña 1: Carga de datos
    tabPanel(
      "Carga de Datos",
      load_data_ui("load_data")
    ),

    # Pestaña 2: Selección de variables
    tabPanel(
      "Selección de Variables",
      select_vars_ui("select_vars")
    ),

    # Pestaña 3: Entrenamiento del Modelo
    tabPanel(
      "Entrenamiento del Modelo",
      train_model_ui("train_model")
    ),

    # Pestaña 4: Visualización de Resultados
    tabPanel(
      "Visualización de Resultados",
      visualization_ui("visualization")
    ),

    # Pestaña 5: Predicciones
    tabPanel(
      "Predicciones",
      prediction_ui("prediction")
    ),

    # Pestaña 6: Exportación
    tabPanel(
      "Exportación",
      export_ui("export")
    )
    )
  )
)

server <- function(input, output, session) {
  data <- load_data_server("load_data")
  selected_vars <- select_vars_server("select_vars", data)
  model <- train_model_server("train_model", data, selected_vars)
  visualization_server("visualization", data, selected_vars, model)
  predictions <- prediction_server("prediction", model, selected_vars)

  metrics <- reactive({
    req(data(), model())
    X <- data()[, selected_vars()$predictors, drop = FALSE]
    y_true <- data()[[selected_vars()$target]]
    y_pred <- predict(model(), X)
    confusion_matrix <- table(Predicción = y_pred, Real = y_true)
    as.data.frame(as.table(confusion_matrix))
  })

  current_plot <- reactive({
    req(input$visualization_type == "Distribuciones")
    ggplot(data(), aes_string(x = selected_vars()$predictors[1], fill = selected_vars()$target)) +
      geom_density(alpha = 0.5) +
      labs(title = "Distribuciones de Clases") +
      theme_minimal()
  })

  export_server("export", predictions, metrics, current_plot)
}

# Ejecutar la aplicación
shinyApp(ui = ui, server = server)
