# Interfaz del módulo de exportación
export_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarPanel(
      h4("Exportar Resultados"),
      downloadButton(ns("download_predictions"), "Descargar Predicciones (CSV)"),
      downloadButton(ns("download_metrics"), "Descargar Métricas (CSV)")
    ),
    mainPanel(
      h3("Opciones de Exportación"),
      p("Seleccione los datos o gráficos que desea exportar.")
    )
  )
}

# Lógica del servidor del módulo de exportación
export_server <- function(id, predictions, metrics, plot) {
  moduleServer(id, function(input, output, session) {
    # Exportar predicciones como CSV
    output$download_predictions <- downloadHandler(
      filename = function() {
        paste("predicciones-", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        req(predictions())
        write.csv(predictions(), file, row.names = FALSE)
      }
    )

    # Exportar métricas como CSV
    output$download_metrics <- downloadHandler(
      filename = function() {
        paste("metricas-", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        req(metrics())
        write.csv(metrics(), file, row.names = FALSE)
      }
    )
  })
}
