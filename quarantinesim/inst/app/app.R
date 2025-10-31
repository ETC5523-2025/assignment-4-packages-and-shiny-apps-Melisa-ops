
library(shiny)
library(dplyr)
library(ggplot2)

# Load dataset from your package
data("data_quarantine", package = "quarantinesim")

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { background-color: #f6f7fb; font-family: Arial, sans-serif; }
      h4, h5, label, .control-label { color: #003366; font-weight: bold; }
      .control-label { font-size: 15px; }
      .desc-title {
        color: #003366;
        font-weight: bold;
        font-size: 18px;
        margin-bottom: 8px;
      }
      .desc-box {
        background: #ffffff;
        border-left: 4px solid #3c8dbc;
        padding: 12px 15px;
        margin-top: 12px;
        margin-bottom: 15px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.08);
        line-height: 1.6;
      }
    "))
  ),

  titlePanel(
    div(
      HTML("<b><span style='color:#003366; font-size:28px;'>Interactive Outbreak Risk Dashboard</span></b>")
    )
  )

  ,

  sidebarLayout(
    sidebarPanel(
      # Vaccine coverage input
      tags$label("Vaccine coverage:", class = "control-label"),
      sliderInput(
        "coverage", NULL,
        min = min(data_quarantine$coverage),
        max = max(data_quarantine$coverage),
        value = 0.5,
        step = 0.1
      ),

      # Outcome input
      tags$label("Outcome to display:", class = "control-label"),
      selectInput(
        "outcome", NULL,
        choices = c(
          "Traveller outbreak probability" = "traveller_ob_prob",
          "Worker outbreak probability"    = "worker_ob_prob",
          "Time to 50% outbreak"           = "chance50",
          "Time to 95% outbreak"           = "chance95"
        ),
        selected = "traveller_ob_prob"
      ),

      # Chart type input
      tags$label("Chart type:", class = "control-label"),
      radioButtons(
        "geom_type", NULL,
        choices = c(
          "Line (default)"       = "line",
          "Points"               = "point",
          "Bars (grouped by VE)" = "bar"
        ),
        selected = "line"
      ),

      checkboxInput("show_values", "Show value labels", FALSE),

      # Professional field descriptions
      div(class = "desc-box",
          div("Field Descriptions", class = "desc-title"),
          tags$p(HTML("
            <b>R<sub>0</sub> (Basic reproduction number):</b>
            Average number of secondary infections caused by one infected individual in a fully susceptible population.<br><br>

            <b>VE (Vaccine effectiveness):</b>
            Proportional reduction in infection risk among vaccinated individuals (0–1).<br><br>

            <b>Coverage:</b>
            Proportion of the population that is vaccinated.<br><br>

            <b>Traveller outbreak probability / Worker outbreak probability:</b>
            Estimated probability of an outbreak originating from travellers or quarantine workers.<br><br>

            <b>Chance 50 / Chance 95:</b>
            Time or iteration required for the outbreak probability to reach 50% or 95% (days).
          "))
      )
    ),

    mainPanel(
      tabsetPanel(
        tabPanel(
          "Plot",
          h4(textOutput("plot_title")),
          plotOutput("main_plot", height = 400),
          div(class = "desc-box",
              div("How to Interpret", class = "desc-title"),
              tags$p(" - Adjust the vaccine coverage, chart type, or outcome to explore different outbreak scenarios."),
              tags$p(" - Each line or bar represents a different level of vaccine effectiveness (VE)."),
              tags$p(" - Higher R₀ values indicate greater potential for outbreak spread."),
              tags$p(" - Tick the checkbox to display numeric values on the chart for easier comparison."),
              tags$p(" - Comparing traveller and worker probabilities can help identify which group has a higher outbreak risk under similar conditions."),
              tags$p(" - Use the time to outbreak metrics (Chance 50 / 95) to assess how quickly outbreaks may emerge across different scenarios.")
          )
        ),
        tabPanel(
          "Data",
          h4("Filtered Data"),
          p("Rows below correspond to the selected vaccine coverage."),
          tableOutput("tbl")
        )
      )
    )
  )
)

server <- function(input, output, session) {

  # Filter data by selected coverage
  filtered_data <- reactive({
    data_quarantine %>%
      filter(coverage == input$coverage)
  })

  # Dynamic plot title
  output$plot_title <- renderText({
    nice_name <- switch(
      input$outcome,
      traveller_ob_prob = "Traveller outbreak probability",
      worker_ob_prob    = "Worker outbreak probability",
      chance50          = "Time to 50% outbreak",
      chance95          = "Time to 95% outbreak"
    )
    paste0(nice_name, " at coverage = ", input$coverage)
  })

  # Helper: format labels by variable type
  format_label <- function(varname, values) {
    if (grepl("ob_prob", varname)) {
      format(round(values, 4), nsmall = 4)   # 4 decimals for probabilities
    } else {
      as.character(round(values, 0))         # integers for time variables
    }
  }

  # Main plot
  output$main_plot <- renderPlot({
    fd <- filtered_data()

    if (input$geom_type %in% c("line", "point")) {

      p <- ggplot(fd, aes(
        x = R0,
        y = .data[[input$outcome]],
        color = factor(VE),
        group = VE
      ))

      if (input$geom_type == "line") {
        p <- p + geom_line(linewidth = 1)
      } else {
        p <- p + geom_point(size = 2)
      }

      # Add labels if enabled
      if (input$show_values) {
        p <- p + geom_text(
          aes(label = format_label(input$outcome, .data[[input$outcome]])),
          vjust = -0.5,
          size = 3,
          position = position_nudge(x = 0.05)
        )
      }

      p +
        labs(
          x = "R₀",
          y = "Selected outcome",
          color = "VE"
        ) +
        theme_minimal(base_size = 12)

    } else {
      # --- BAR MODE ---
      p <- ggplot(fd, aes(
        x = factor(R0),
        y = .data[[input$outcome]],
        fill = factor(VE)
      )) +
        geom_col(
          position  = position_dodge(width = 0.7),
          color     = "black",
          linewidth = 0.6
        )

      # Add labels if enabled
      if (input$show_values) {
        p <- p + geom_text(
          aes(label = format_label(input$outcome, .data[[input$outcome]])),
          position = position_dodge(width = 0.7),
          vjust = -0.6,
          size = 3,
          angle = 15
        )
      }

      p +
        labs(
          x = "R₀",
          y = "Selected outcome",
          fill = "VE",
          title = paste("Bars by R₀ and VE — coverage =", input$coverage)
        ) +
        theme_minimal(base_size = 12)
    }
  })

  # Data table tab
  output$tbl <- renderTable({
    filtered_data() %>%
      select(
        R0, VE, coverage,
        traveller_ob_prob, worker_ob_prob,
        chance50, chance95
      )
  })
}

shinyApp(ui, server)
