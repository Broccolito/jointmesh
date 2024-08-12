source("setup.R")

ui = fluidPage(
  titlePanel("JointMesh"),
  withMathJax(),
  helpText("Parameterize Joint Surfaces"),
  
  sidebarLayout(
    sidebarPanel(
      tabsetPanel(
        tabPanel("Fit Data", 
                 div(
                   br(),
                   fileInput(inputId = "ply_file", label = "Upload .ply File", accept = ".ply"),
                   actionButton(inputId = "run_singular", label = "Run JointMesh"),
                   br(), hr(),
                   helpText(
                     "For help, visit the ",
                     a("JointMesh Repository", href = jointmesh_repo, target = "_blank")
                   )
                 )
        ),
        tabPanel("Fit Batch", 
                 div(
                   br(),
                   shinyDirButton(id = "directory", label = "Select Directory",
                                  title = "Please select a directory", 
                                  icon = icon("folder-open")),
                   verbatimTextOutput(outputId = "selected_dir"),
                   br(),
                   actionButton(inputId = "run_batch", label = "Run JointMesh"),
                   br(), hr(),
                   helpText(
                     "For help, visit the ",
                     a("JointMesh Repository", href = jointmesh_repo, target = "_blank")
                   )
                 )
        )
      )
    ),
    mainPanel(
      uiOutput(outputId = "result_ui")
    )
  )
)

server = function(input, output, session){
  
  fitted_model = reactiveVal(0)
  fitted_data_batch = reactiveVal(1)
  roots = c(home = normalizePath("~"))
  
  shinyDirChoose(input, "directory", roots = roots, session = session)
  
  selected_dir = reactive({
    parseDirPath(roots, input$directory)
  })
  
  output$selected_dir = renderText({
    selected_dir()
  })
  
  observeEvent(input$run_batch, {
    fitted_data_batch(fit_data_batch(file_dir = selected_dir()))
    output$result_ui = renderUI({
      div(
        h4("Model Coefficients"),
        DTOutput("fitted_data_batch")
      )
    })
  })
  
  output$fitted_data_batch = renderDT({
    data = fitted_data_batch()
    data = data %>%
      mutate(rsq = round(rsq, 3)) %>%
      mutate(intercept = round(intercept, 3)) %>%
      mutate(x1 = round(x1, 3)) %>%
      mutate(x2 = round(x2, 3)) %>%
      mutate(x3 = round(x3, 3)) %>%
      mutate(x4 = round(x4, 3)) %>%
      mutate(y1 = round(y1, 3)) %>%
      mutate(y2 = round(y2, 3)) %>%
      mutate(y3 = round(y3, 3)) %>%
      mutate(y4 = round(y4, 3)) %>%
      mutate(xy = round(xy, 3)) %>%
      mutate(sqrt_xny = round(sqrt_xny, 3)) %>%
      mutate(sqrt_x2ny2 = round(sqrt_x2ny2, 3))
    
    datatable_formatted = datatable(data,
                                    options = list(pageLength = 20,
                                                   dom = "Bfrtip",
                                                   buttons = list(
                                                     list(
                                                       extend = "csv",
                                                       text = "Export as CSV",
                                                       filename = "data"
                                                     )
                                                   )),
                                    extensions = "Buttons")
    return(datatable_formatted)
  })
  
  observeEvent(input$run_singular, {
    data = read_ply(input$ply_file$datapath, 
                    filename = input$ply_file$name)
    fitted_model(fit_data(data))
    output$result_ui = renderUI({
      div(
        h4("R^2"),
        verbatimTextOutput("rsq"),
        h4("Model Coefficients"),
        DTOutput("coefs"),
        br(),
        plotlyOutput(outputId = "fitted_mesh")
      )
    })
  })
  
  output$rsq = renderText({
    print(round(fitted_model()$rsq,3))
  })
  
  output$coefs = renderDT({
    
    data = fitted_model()$coefficients
    data = data %>%
      mutate(coef = round(coef, 3)) %>%
      mutate(se = round(se, 3)) %>%
      mutate(p_value = formatC(p_value, digits = 2, format = "e", flag = "#"))
    names(data) = c("", "Coefficient", "SE", "P.Value")
    datatable_formatted = datatable(data,
                                    options = list(pageLength = 15,
                                                   dom = "Bfrtip",
                                                   buttons = list(
                                                     list(
                                                       extend = "csv",
                                                       text = "Export as CSV",
                                                       filename = "data"
                                                     )
                                                   )),
                                    extensions = "Buttons")
    return(datatable_formatted)
  })
  
  output$fitted_mesh = renderPlotly({
    visualize_data(fitted_model())
  })
  
  session$onSessionEnded(function(){
    stopApp()
  })
}


shinyApp(ui, server)