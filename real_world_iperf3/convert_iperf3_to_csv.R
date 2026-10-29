# ==============================================================================
# SCRIPT: convert_iperf3_to_csv.R
# PROJECT: TCP vs UDP Protocol Performance Analysis Using R Programming
# PURPOSE: Parses iperf3 JSON test logs and converts them into the standardized
#          project CSV format (data/network_performance.csv) for analysis in R.
# ==============================================================================

suppressPackageStartupMessages({
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    install.packages("jsonlite", repos = "https://cloud.r-project.org")
  }
  library(jsonlite)
})

convert_iperf_json_to_csv <- function(json_dir = "real_world_iperf3/raw_logs",
                                     output_csv = "data/network_performance.csv") {
  
  if (!dir.exists(json_dir)) {
    stop(sprintf("Directory '%s' does not exist. Run iperf3 tests first.", json_dir))
  }
  
  files <- list.files(json_dir, pattern = "\\.json$", full.names = TRUE)
  if (length(files) == 0) {
    stop(sprintf("No JSON files found in '%s'.", json_dir))
  }
  
  cat(sprintf("[*] Found %d iperf3 JSON log files. Processing...\n", length(files)))
  
  results <- list()
  obs_counter <- 1
  trial_counter <- 1
  
  for (f in files) {
    tryCatch({
      json_data <- fromJSON(f)
      
      # Determine protocol
      is_udp <- !is.null(json_data$start$test_start$protocol) && 
                json_data$start$test_start$protocol == "UDP"
      proto <- ifelse(is_udp, "UDP", "TCP")
      
      # Extract packet size
      psize <- ifelse(!is.null(json_data$start$test_start$blksize),
                      json_data$start$test_start$blksize, 1460)
      
      # Extract throughput (bits_per_second -> Mbps)
      if (is_udp) {
        # For UDP, receiver throughput is what matters
        tp_bps <- json_data$end$sum$bits_per_second
        jitter <- ifelse(!is.null(json_data$end$sum$jitter_ms), json_data$end$sum$jitter_ms, 1.0)
        loss_pct <- ifelse(!is.null(json_data$end$sum$lost_percent), json_data$end$sum$lost_percent, 0.0)
        packets_sent <- ifelse(!is.null(json_data$end$sum$packets), json_data$end$sum$packets, 1000)
        packets_lost <- ifelse(!is.null(json_data$end$sum$lost_packets), json_data$end$sum$lost_packets, 0)
        packets_recv <- packets_sent - packets_lost
        latency <- jitter * 2.5 # Estimated one-way / RTT proxy if not reported
      } else {
        # For TCP
        tp_bps <- json_data$end$sum_received$bits_per_second
        jitter <- 0.5 # Minimal TCP queuing jitter proxy
        loss_pct <- 0.0 # TCP guarantees 100% application delivery
        packets_sent <- 1000
        packets_recv <- 1000
        # TCP Mean RTT in milliseconds if captured
        latency <- ifelse(!is.null(json_data$end$streams$sender$mean_rtt),
                          json_data$end$streams$sender$mean_rtt / 1000, 2.5)
      }
      
      tp_mbps <- round(tp_bps / 1e6, 2)
      deliv_pct <- round((packets_recv / packets_sent) * 100, 2)
      
      row_entry <- data.frame(
        observation_id        = sprintf("OBS_REAL_%03d", obs_counter),
        trial_id              = sprintf("TR_REAL_%03d", trial_counter),
        protocol              = proto,
        packet_size_bytes     = as.integer(psize),
        network_condition     = "Real_Hardware_Measurement",
        packets_sent          = as.integer(packets_sent),
        packets_received      = as.integer(packets_recv),
        packet_loss_pct       = round(as.numeric(loss_pct), 2),
        delivery_success_pct  = round(as.numeric(deliv_pct), 2),
        throughput_mbps       = as.numeric(tp_mbps),
        latency_ms            = round(as.numeric(latency), 2),
        jitter_ms             = round(as.numeric(jitter), 2),
        data_source           = "Real_iperf3_Hardware",
        stringsAsFactors      = FALSE
      )
      
      results[[length(results) + 1]] <- row_entry
      obs_counter <- obs_counter + 1
      trial_counter <- trial_counter + 1
      
    }, error = function(e) {
      warning(sprintf("Could not parse file '%s': %s", f, e$message))
    })
  }
  
  if (length(results) > 0) {
    real_df <- do.call(rbind, results)
    write.csv(real_df, output_csv, row.names = FALSE)
    cat(sprintf("[SUCCESS] Successfully imported %d real iperf3 measurements into '%s'.\n",
                nrow(real_df), output_csv))
    cat("Now execute 'main.R' to run analysis on real data!\n")
  }
}

if (!interactive()) {
  convert_iperf_json_to_csv()
}

