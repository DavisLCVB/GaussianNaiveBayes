load_data_ui <- function(id) {
  ns <- NS(id)
  sidebarLayout(
    sidebarPanel(
      fileInput(ns("file"), "Subir Archivo CSV", accept = ".csv"),
      actionButton(ns("use_sample"), "Usar Dataset Predefinido")
    ),
    mainPanel(
      h3("Vista previa de los datos"),
      DTOutput(ns("preview_data"))
    )
  )
}

load_data_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    data <- reactiveVal(NULL)
    observeEvent(input$file, {
      data(read.csv(input$file$datapath))
    })
    observeEvent(input$use_sample, {
      data(read.csv("data/titanic.csv"))
    })
    output$preview_data <- renderDT({
      datatable(data(), options = list(pageLength = 5))
    })
    return(data)
  })
}
