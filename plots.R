# ==============================================================================
# SCRIPT: plots.R
# PROJECT: TCP vs UDP Protocol Performance Analysis Using R Programming
# SUBTITLE: A Comparative Study of Throughput, Latency, Packet Loss, Jitter,
#           and Reliability
# AUTHOR: BCA 3rd Year Student Project
# SUBJECTS: IDCCN, R Programming Language, Computational Data Analytics (CDA)
# ==============================================================================
# PURPOSE:
# Generates 6 publication-quality, high-resolution (300 DPI) academic charts
# using ggplot2 illustrating protocol differences across throughput, latency,
# packet loss, jitter, packet sizes, and network environments.
# ==============================================================================

suppressPackageStartupMessages({
  if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2", repos = "https://cloud.r-project.org")
  if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr", repos = "https://cloud.r-project.org")
  library(ggplot2)
  library(dplyr)
})

generate_network_plots <- function(input_file = "output/cleaned_network_performance.csv",
                                   output_dir = "output") {
  
  cat("======================================================================\n")
  cat("     TCP vs UDP DATA VISUALIZATION ENGINE (ggplot2 - 300 DPI)         \n")
  cat("======================================================================\n\n")
  
  if (!file.exists(input_file)) {
    input_file <- "data/network_performance.csv"
  }
  
  if (!file.exists(input_file)) {
    stop("Input data file not found. Please run generate_data.R first.")
  }
  
  df <- read.csv(input_file, stringsAsFactors = FALSE)
  
  # Standardize factor ordering for clean visualization
  df$network_condition <- factor(df$network_condition,
                                levels = c("Ideal_LAN", "Moderate_Congestion", "Severe_Loss_High_Jitter"),
                                labels = c("Ideal LAN", "Moderate Congestion", "Severe Loss & Jitter"))
  df$protocol <- factor(df$protocol, levels = c("TCP", "UDP"))
  
  # Professional academic color palette
  protocol_colors <- c("TCP" = "#1f77b4", "UDP" = "#e41a1c")
  
  # Common aesthetic theme
  academic_theme <- theme_bw(base_size = 12) +
    theme(
      plot.title       = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(b = 6)),
      plot.subtitle    = element_text(size = 11, hjust = 0.5, color = "#444444", margin = margin(b = 10)),
      plot.caption     = element_text(size = 9, color = "#666666", hjust = 1, margin = margin(t = 8)),
      axis.title       = element_text(face = "bold", size = 11),
      axis.text        = element_text(size = 10, color = "#222222"),
      legend.title     = element_text(face = "bold", size = 11),
      legend.position  = "bottom",
      panel.grid.minor = element_blank(),
      strip.background = element_rect(fill = "#e9ecef", color = "#cccccc"),
      strip.text       = element_text(face = "bold", size = 11)
    )
  
  # ----------------------------------------------------------------------------
  # CHART 1: Throughput Comparison (Boxplot by Condition)
  # ----------------------------------------------------------------------------
  cat("[Plot 1/6] Generating Throughput Comparison (output/throughput_comparison.png)...\n")
  p1 <- ggplot(df, aes(x = network_condition, y = throughput_mbps, fill = protocol)) +
    geom_boxplot(alpha = 0.85, outlier.shape = 21, outlier.size = 2, position = position_dodge(0.8)) +
    stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "white",
                 position = position_dodge(0.8), color = "black") +
    scale_fill_manual(values = protocol_colors, name = "Protocol:") +
    labs(
      title    = "TCP vs UDP Throughput Performance Comparison",
      subtitle = "Comparison of achieved transmission throughput across network environments (Diamond = Mean)",
      x        = "Network Condition",
      y        = "Throughput (Mbps)",
      caption  = "Source: Academic Network Simulation (IDCCN / BCA 3rd Year) | Diamonds indicate group means"
    ) +
    academic_theme
  
  ggsave(file.path(output_dir, "throughput_comparison.png"), plot = p1, width = 8, height = 5.5, dpi = 300)
  
  # ----------------------------------------------------------------------------
  # CHART 2: Latency Comparison (Boxplot with Jitter/Points)
  # ----------------------------------------------------------------------------
  cat("[Plot 2/6] Generating Latency Comparison (output/latency_comparison.png)...\n")
  p2 <- ggplot(df, aes(x = network_condition, y = latency_ms, fill = protocol)) +
    geom_boxplot(alpha = 0.85, outlier.shape = 21, position = position_dodge(0.8)) +
    stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "white",
                 position = position_dodge(0.8), color = "black") +
    scale_fill_manual(values = protocol_colors, name = "Protocol:") +
    labs(
      title    = "TCP vs UDP Latency (Round-Trip / Transit Delay)",
      subtitle = "Latency inflation under congestion caused by TCP ARQ retransmissions and Head-of-Line blocking",
      x        = "Network Condition",
      y        = "Latency (milliseconds - ms)",
      caption  = "Lower latency is preferable | UDP achieves lower latency under congestion as it does not retransmit"
    ) +
    academic_theme
  
  ggsave(file.path(output_dir, "latency_comparison.png"), plot = p2, width = 8, height = 5.5, dpi = 300)
  
  # ----------------------------------------------------------------------------
  # CHART 3: Packet Loss Comparison (Bar Chart of Mean Loss %)
  # ----------------------------------------------------------------------------
  cat("[Plot 3/6] Generating Packet Loss Comparison (output/packet_loss_comparison.png)...\n")
  loss_summary <- df %>%
    group_by(network_condition, protocol) %>%
    summarise(
      Mean_Loss = mean(packet_loss_pct),
      SD_Loss   = sd(packet_loss_pct),
      .groups   = "drop"
    )
  
  p3 <- ggplot(loss_summary, aes(x = network_condition, y = Mean_Loss, fill = protocol)) +
    geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7, alpha = 0.9, color = "black") +
    geom_errorbar(aes(ymin = pmax(0, Mean_Loss - SD_Loss), ymax = Mean_Loss + SD_Loss),
                  position = position_dodge(0.8), width = 0.25, color = "#333333") +
    geom_text(aes(label = sprintf("%.1f%%", Mean_Loss)),
              position = position_dodge(0.8), vjust = -0.6, size = 3.8, fontface = "bold") +
    scale_fill_manual(values = protocol_colors, name = "Protocol:") +
    scale_y_continuous(limits = c(0, max(loss_summary$Mean_Loss + loss_summary$SD_Loss, 28))) +
    labs(
      title    = "Observed Packet Loss Rate by Protocol and Condition",
      subtitle = "TCP maintains 0% application loss via retransmissions; UDP experiences unmitigated wire drops",
      x        = "Network Condition",
      y        = "Packet Loss Percentage (%)",
      caption  = "Error bars represent +/- 1 Standard Deviation | Lower is preferable"
    ) +
    academic_theme
  
  ggsave(file.path(output_dir, "packet_loss_comparison.png"), plot = p3, width = 8, height = 5.5, dpi = 300)
  
  # ----------------------------------------------------------------------------
  # CHART 4: Jitter Comparison (Violin / Boxplot Distribution)
  # ----------------------------------------------------------------------------
  cat("[Plot 4/6] Generating Jitter Comparison (output/jitter_comparison.png)...\n")
  p4 <- ggplot(df, aes(x = network_condition, y = jitter_ms, fill = protocol)) +
    geom_boxplot(alpha = 0.85, outlier.shape = 21, position = position_dodge(0.8)) +
    stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "yellow",
                 position = position_dodge(0.8), color = "black") +
    scale_fill_manual(values = protocol_colors, name = "Protocol:") +
    labs(
      title    = "Packet Delay Variation (Jitter) Across Network Environments",
      subtitle = "Fluctuations in inter-arrival delay impacting multimedia streaming (Yellow diamond = Mean)",
      x        = "Network Condition",
      y        = "Jitter (milliseconds - ms)",
      caption  = "Lower jitter is essential for VoIP, videoconferencing, and real-time multiplayer gaming"
    ) +
    academic_theme
  
  ggsave(file.path(output_dir, "jitter_comparison.png"), plot = p4, width = 8, height = 5.5, dpi = 300)
  
  # ----------------------------------------------------------------------------
  # CHART 5: Performance Across Packet Sizes (Line Chart with Points)
  # ----------------------------------------------------------------------------
  cat("[Plot 5/6] Generating Packet Size Scaling (output/packet_size_comparison.png)...\n")
  size_summary <- df %>%
    group_by(packet_size_bytes, protocol, network_condition) %>%
    summarise(
      Mean_Throughput = mean(throughput_mbps),
      .groups = "drop"
    )
  
  p5 <- ggplot(size_summary, aes(x = factor(packet_size_bytes), y = Mean_Throughput,
                                 color = protocol, group = protocol)) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 3.5, shape = 19) +
    facet_wrap(~ network_condition) +
    scale_color_manual(values = protocol_colors, name = "Protocol:") +
    labs(
      title    = "Throughput Scaling with Increasing Packet Size (Bytes)",
      subtitle = "Larger MTU payload sizes amortize per-packet header overhead and boost effective throughput",
      x        = "Packet Payload Size (Bytes)",
      y        = "Mean Throughput (Mbps)",
      caption  = "Small 64-byte packets suffer heavy header-to-payload ratio overhead; 1460-byte MSS maximizes throughput"
    ) +
    academic_theme
  
  ggsave(file.path(output_dir, "packet_size_comparison.png"), plot = p5, width = 9.5, height = 5.5, dpi = 300)
  
  # ----------------------------------------------------------------------------
  # CHART 6: Multi-Dimensional Network Condition Matrix (Faceted Multi-Metric)
  # ----------------------------------------------------------------------------
  cat("[Plot 6/6] Generating Comprehensive Condition Comparison (output/network_condition_comparison.png)...\n")
  
  # Create a normalized comparative bar chart across key metrics
  comp_summary <- df %>%
    group_by(network_condition, protocol) %>%
    summarise(
      Throughput_Mbps   = mean(throughput_mbps),
      Latency_ms        = mean(latency_ms),
      Delivery_Rate_pct = mean(delivery_success_pct),
      .groups = "drop"
    )
  
  # Reshape for multi-panel faceting
  reshaped_comp <- tidyr::pivot_longer(
    comp_summary,
    cols = c("Throughput_Mbps", "Latency_ms", "Delivery_Rate_pct"),
    names_to = "Metric",
    values_to = "Value"
  )
  
  metric_labels <- c(
    "Throughput_Mbps"   = "Throughput (Mbps - Higher is Better)",
    "Latency_ms"        = "Latency (ms - Lower is Better)",
    "Delivery_Rate_pct" = "Delivery Success Rate (% - Higher is Better)"
  )
  
  p6 <- ggplot(reshaped_comp, aes(x = network_condition, y = Value, fill = protocol)) +
    geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7, alpha = 0.9, color = "black") +
    geom_text(aes(label = round(Value, 1)), position = position_dodge(0.8), vjust = -0.5, size = 3.2, fontface = "bold") +
    facet_wrap(~ Metric, scales = "free_y", labeller = as_labeller(metric_labels)) +
    scale_fill_manual(values = protocol_colors, name = "Protocol:") +
    labs(
      title    = "Holistic Protocol Evaluation Across Operational Conditions",
      subtitle = "Multi-metric comparison highlighting the fundamental trade-off between reliability and speed",
      x        = "Network Condition",
      y        = "Metric Value (Native Units)",
      caption  = "TCP prioritizes 100% delivery reliability; UDP prioritizes minimum latency and delay"
    ) +
    academic_theme +
    theme(axis.text.x = element_text(angle = 20, hjust = 1, size = 9))
  
  ggsave(file.path(output_dir, "network_condition_comparison.png"), plot = p6, width = 11, height = 6.5, dpi = 300)
  
  cat("[SUCCESS] All 6 high-resolution charts saved to 'output/' directory.\n\n")
}

# Run standalone if executed directly
if (!interactive()) {
  generate_network_plots()
}

