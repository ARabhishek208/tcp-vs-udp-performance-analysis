# ==============================================================================
# SCRIPT: app.R (OPTIONAL INTERACTIVE SHINY DASHBOARD)
# PROJECT: TCP vs UDP Protocol Performance Analysis Using R Programming
# SUBTITLE: A Comparative Study of Throughput, Latency, Packet Loss, Jitter,
#           and Reliability
# AUTHOR: BCA 3rd Year Student Project
# ==============================================================================
# HOW TO RUN:
# In RStudio, open app.R and click the "Run App" button in the top-right corner.
# Or in the R console run:
#   install.packages("shiny") # if not installed
#   shiny::runApp()
# ==============================================================================

if (!requireNamespace("shiny", quietly = TRUE)) {
  message("Package 'shiny' is required for the interactive dashboard.")
  message("Install it by typing: install.packages('shiny')")
}

suppressPackageStartupMessages({
  library(shiny)
  library(ggplot2)
  library(dplyr)
})

# Load dataset
dataset_path <- if (file.exists("output/cleaned_network_performance.csv")) {
  "output/cleaned_network_performance.csv"
} else if (file.exists("data/network_performance.csv")) {
  "data/network_performance.csv"
} else {
  source("generate_data.R")
  generate_network_data("data/network_performance.csv")
  "data/network_performance.csv"
}

df_full <- read.csv(dataset_path, stringsAsFactors = FALSE)

# Define User Interface
ui <- fluidPage(
  theme = NULL, # Standard clean bootstrap
  titlePanel("TCP vs UDP Performance Analysis Dashboard | BCA Project"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Experimental Controls"),
      helpText("Filter network observations by protocol, environment, and packet size."),
      
      checkboxGroupInput("protocols", "Select Protocol(s):",
                         choices = c("TCP", "UDP"),
                         selected = c("TCP", "UDP")),
      
      selectInput("condition", "Network Condition:",
                  choices = c("All Conditions", unique(df_full$network_condition)),
                  selected = "All Conditions"),
      
      selectInput("packet_size", "Packet Size (Bytes):",
                  choices = c("All Sizes", sort(unique(df_full$packet_size_bytes))),
                  selected = "All Sizes"),
      
      hr(),
      h5("Key Parameters Analyzed:"),
      tags$ul(
        tags$li("Throughput (Mbps) [Higher is better]"),
        tags$li("Latency (ms) [Lower is better]"),
        tags$li("Packet Loss (%) [Lower is better]"),
        tags$li("Jitter (ms) [Lower is better]")
      ),
      hr(),
      p(em("Developed for BCA 3rd Year University Project & Viva Demonstration"))
    ),
    
    mainPanel(
      width = 9,
      tabsetPanel(
        type = "tabs",
        
        # TAB 1: Visualizations
        tabPanel("Performance Visualizations",
          fluidRow(
            column(12,
              h4("Comparative Metric Distribution"),
              selectInput("metric_choice", "Select Metric to Plot:",
                          choices = c("Throughput (Mbps)" = "throughput_mbps",
                                      "Latency (ms)"       = "latency_ms",
                                      "Packet Loss (%)"    = "packet_loss_pct",
                                      "Jitter (ms)"        = "jitter_ms",
                                      "Delivery Rate (%)"  = "delivery_success_pct"),
                          selected = "throughput_mbps"),
              plotOutput("metricPlot", height = "400px")
            )
          ),
          hr(),
          fluidRow(
            column(12,
              h4("Throughput vs Latency Trade-off Scatter"),
              plotOutput("scatterPlot", height = "350px")
            )
          )
        ),
        
        # TAB 2: Summary Statistics Table
        tabPanel("Statistical Summary",
          h4("Summary Metrics for Selected Data"),
          tableOutput("summaryTable"),
          hr(),
          h4("Theoretical Protocol Reference Matrix"),
          tags$table(class = "table table-bordered table-striped",
            tags$thead(
              tags$tr(
                tags$th("Parameter"),
                tags$th("TCP (RFC 793)"),
                tags$th("UDP (RFC 768)")
              )
            ),
            tags$tbody(
              tags$tr(tags$td("Connection Mode"), tags$td("Connection-oriented (3-way handshake)"), tags$td("Connectionless (No setup)")),
              tags$tr(tags$td("Reliability"), tags$td("Guaranteed via ACKs & Retransmissions"), tags$td("Best-effort; no delivery guarantee")),
              tags$tr(tags$td("Header Overhead"), tags$td("20 - 60 Bytes"), tags$td("8 Bytes fixed")),
              tags$tr(tags$td("Flow / Congestion Control"), tags$td("Sliding window & Slow start"), tags$td("None (Transmits at sender rate)")),
              tags$tr(tags$td("Latency"), tags$td("Higher under loss due to retransmission RTT"), tags$td("Consistently lower; no wait state")),
              tags$tr(tags$td("Standard Applications"), tags$td("HTTP, HTTPS, SSH, FTP, SMTP"), tags$td("DNS, VoIP, Live Video, Gaming, SNMP"))
            )
          )
        ),
        
        # TAB 3: Data Explorer
        tabPanel("Raw Dataset Explorer",
          h4("Filtered Experimental Observations"),
          downloadButton("downloadData", "Download Filtered Data (CSV)"),
          br(), br(),
          dataTableOutput("rawDataTable")
        )
      )
    )
  )
)

# Define Server Logic
server <- function(input, output, session) {
  
  # Reactive filtered dataset
  filtered_df <- reactive({
    data <- df_full
    
    if (length(input$protocols) > 0) {
      data <- data %>% filter(protocol %in% input$protocols)
    }
    
    if (input$condition != "All Conditions") {
      data <- data %>% filter(network_condition == input$condition)
    }
    
    if (input$packet_size != "All Sizes") {
      data <- data %>% filter(packet_size_bytes == as.integer(input$packet_size))
    }
    
    data
  })
  
  # Render Metric Boxplot
  output$metricPlot <- renderPlot({
    req(nrow(filtered_df()) > 0)
    metric <- input$metric_choice
    
    ggplot(filtered_df(), aes_string(x = "network_condition", y = metric, fill = "protocol")) +
      geom_boxplot(alpha = 0.85, position = position_dodge(0.8)) +
      stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "white",
                   position = position_dodge(0.8), color = "black") +
      scale_fill_manual(values = c("TCP" = "#1f77b4", "UDP" = "#e41a1c")) +
      theme_bw(base_size = 13) +
      labs(title = paste("Comparison of", names(which(c("throughput_mbps" = "Throughput (Mbps)",
                                                        "latency_ms" = "Latency (ms)",
                                                        "packet_loss_pct" = "Packet Loss (%)",
                                                        "jitter_ms" = "Jitter (ms)",
                                                        "delivery_success_pct" = "Delivery Rate (%)") == metric))),
           x = "Network Condition", y = metric) +
      theme(legend.position = "bottom", plot.title = element_text(face = "bold", hjust = 0.5))
  })
  
  # Render Scatter Trade-off Plot
  output$scatterPlot <- renderPlot({
    req(nrow(filtered_df()) > 0)
    ggplot(filtered_df(), aes(x = latency_ms, y = throughput_mbps, color = protocol, shape = network_condition)) +
      geom_point(size = 3.5, alpha = 0.85) +
      scale_color_manual(values = c("TCP" = "#1f77b4", "UDP" = "#e41a1c")) +
      theme_bw(base_size = 13) +
      labs(title = "Throughput vs Latency Operating Trade-off",
           x = "Latency (ms) - Lower is Better",
           y = "Throughput (Mbps) - Higher is Better",
           color = "Protocol", shape = "Condition") +
      theme(legend.position = "right", plot.title = element_text(face = "bold", hjust = 0.5))
  })
  
  # Render Summary Table
  output$summaryTable <- renderTable({
    req(nrow(filtered_df()) > 0)
    filtered_df() %>%
      group_by(protocol, network_condition) %>%
      summarise(
        Count          = n(),
        Mean_Throughput= round(mean(throughput_mbps), 2),
        Mean_Latency   = round(mean(latency_ms), 2),
        Mean_Loss_pct  = round(mean(packet_loss_pct), 2),
        Mean_Jitter_ms = round(mean(jitter_ms), 2),
        Mean_Success   = round(mean(delivery_success_pct), 2),
        .groups        = "drop"
      )
  })
  
  # Render Data Table
  output$rawDataTable <- renderDataTable({
    filtered_df()
  }, options = list(pageLength = 10, scrollX = TRUE))
  
  # Download handler
  output$downloadData <- downloadHandler(
    filename = function() { paste0("filtered_network_data_", Sys.Date(), ".csv") },
    content = function(file) {
      write.csv(filtered_df(), file, row.names = FALSE)
    }
  )
}

# Launch Application
shinyApp(ui = ui, server = server)

