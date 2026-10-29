# ==============================================================================
# SCRIPT: generate_data.R
# PROJECT: TCP vs UDP Protocol Performance Analysis Using R Programming
# SUBTITLE: A Comparative Study of Throughput, Latency, Packet Loss, Jitter,
#           and Reliability
# AUTHOR: BCA 3rd Year Student Project
# SUBJECTS: IDCCN, R Programming Language, Computational Data Analytics (CDA)
# ==============================================================================
# PURPOSE:
# This script generates a reproducible, realistic synthetic dataset simulating
# network performance metrics for TCP and UDP across various packet sizes and
# network conditions.
#
# NOTE ON SIMULATION INTEGRITY:
# In accordance with academic honesty guidelines, this dataset is explicitly
# labeled as SIMULATED. It models physical transport-layer dynamics governed
# by RFC 793 (TCP) and RFC 768 (UDP) under controlled network conditions.
# ==============================================================================

generate_network_data <- function(output_file = "data/network_performance.csv") {
  # 1. Ensure target directory exists
  if (!dir.exists("data")) {
    dir.create("data", recursive = TRUE)
  }
  
  # 2. Set seed for strict experimental reproducibility
  set.seed(42)
  
  # 3. Define experimental design parameters
  packet_sizes <- c(64, 512, 1024, 1460)  # Bytes (VoIP/Gaming up to standard Ethernet MTU MSS)
  network_conditions <- c("Ideal_LAN", "Moderate_Congestion", "Severe_Loss_High_Jitter")
  replications <- 10  # 10 trials per condition combination
  
  # Total trials = 4 packet sizes * 3 conditions * 10 replications = 120 matched trials
  # Since each trial is executed for both TCP and UDP, total observations = 240 (120 per protocol)
  
  trials_list <- list()
  trial_counter <- 1
  obs_counter <- 1
  
  for (cond in network_conditions) {
    for (psize in packet_sizes) {
      for (rep in 1:replications) {
        
        # Base trial identifier for matched-pair comparison
        trial_id <- sprintf("TR_%03d", trial_counter)
        
        # Nominal packet count sent per experiment trial
        packets_sent <- 1000
        
        # ----------------------------------------------------------------------
        # PHYSICAL & TRANSPORT LAYER SIMULATION LOGIC
        # ----------------------------------------------------------------------
        # Condition 1: Ideal_LAN (Low latency, zero line error, high bandwidth)
        if (cond == "Ideal_LAN") {
          base_rtt <- runif(1, 1.2, 2.5) # ms
          
          # TCP: 3-way handshake + ACK processing adds slight round-trip overhead
          tcp_latency <- base_rtt + runif(1, 0.4, 0.9)
          tcp_jitter  <- runif(1, 0.2, 0.8)
          tcp_loss    <- 0.0 # Reliable LAN, no buffer drops
          tcp_recv    <- packets_sent
          # High throughput, scaled by packet size (efficiency increases with payload size)
          size_factor <- (psize / 1460)^0.35
          tcp_tp      <- round(runif(1, 88.0, 96.0) * size_factor, 2)
          
          # UDP: Minimal 8-byte header overhead, no connection handshake, no ACKs
          udp_latency <- base_rtt + runif(1, 0.1, 0.4) # Slightly lower than TCP
          udp_jitter  <- runif(1, 0.15, 0.6)
          udp_loss    <- 0.0
          udp_recv    <- packets_sent
          udp_tp      <- round(runif(1, 91.0, 98.5) * size_factor, 2) # Slightly higher wire efficiency
          
        # Condition 2: Moderate_Congestion (Queueing delay, buffer drops)
        } else if (cond == "Moderate_Congestion") {
          base_rtt <- runif(1, 28.0, 42.0) # ms
          
          # TCP: Packet drops trigger TCP Fast Retransmit / Halving of cwnd
          # Retransmission guarantees application-level delivery (100%), but
          # retransmission timeouts and ACK round-trips penalize latency & throughput
          tcp_retrans_penalty <- runif(1, 15.0, 25.0)
          tcp_latency <- base_rtt + tcp_retrans_penalty
          tcp_jitter  <- runif(1, 4.0, 8.5)
          tcp_loss    <- 0.0 # Transport-level reliability guarantees 100% receipt
          tcp_recv    <- packets_sent
          size_factor <- (psize / 1460)^0.40
          tcp_tp      <- round(runif(1, 42.0, 64.0) * size_factor, 2)
          
          # UDP: No congestion backoff, no retransmission. Dropped packets are lost forever!
          udp_loss_pct <- runif(1, 2.5, 6.0) # 2.5% to 6.0% packet loss
          udp_loss     <- round(udp_loss_pct, 2)
          udp_recv     <- round(packets_sent * (1 - (udp_loss / 100)))
          # Latency of delivered packets remains lower because it does not wait for retransmissions!
          udp_latency  <- base_rtt + runif(1, 1.0, 5.0)
          udp_jitter   <- runif(1, 5.0, 10.5)
          size_factor  <- (psize / 1460)^0.38
          # Delivered throughput is reduced by packet loss
          udp_tp       <- round((runif(1, 55.0, 75.0) * (udp_recv / packets_sent)) * size_factor, 2)
          
        # Condition 3: Severe_Loss_High_Jitter (Noisy wireless / heavily congested link)
        } else {
          base_rtt <- runif(1, 85.0, 120.0) # ms
          
          # TCP: Multiple drops trigger RTO (Retransmission Time Out), resetting cwnd to 1 MSS.
          # Substantial latency inflation due to Head-of-Line blocking and backoff.
          tcp_timeout_penalty <- runif(1, 45.0, 85.0)
          tcp_latency <- base_rtt + tcp_timeout_penalty
          tcp_jitter  <- runif(1, 14.0, 28.0)
          tcp_loss    <- 0.0 # Delivery guarantee maintained
          tcp_recv    <- packets_sent
          size_factor <- (psize / 1460)^0.50
          tcp_tp      <- round(runif(1, 12.0, 26.0) * size_factor, 2)
          
          # UDP: Severe packet drops (12% to 24%), but packets that do arrive suffer NO head-of-line delay
          udp_loss_pct <- runif(1, 12.0, 24.0)
          udp_loss     <- round(udp_loss_pct, 2)
          udp_recv     <- round(packets_sent * (1 - (udp_loss / 100)))
          udp_latency  <- base_rtt + runif(1, 5.0, 18.0) # Substantially lower latency than TCP!
          udp_jitter   <- runif(1, 16.0, 32.0)
          size_factor  <- (psize / 1460)^0.45
          udp_tp       <- round((runif(1, 28.0, 48.0) * (udp_recv / packets_sent)) * size_factor, 2)
        }
        
        # ----------------------------------------------------------------------
        # RECORD TCP OBSERVATION
        # ----------------------------------------------------------------------
        tcp_deliv_success <- round((tcp_recv / packets_sent) * 100, 2)
        obs_tcp <- data.frame(
          observation_id        = sprintf("OBS_%03d", obs_counter),
          trial_id              = trial_id,
          protocol              = "TCP",
          packet_size_bytes     = as.integer(psize),
          network_condition     = cond,
          packets_sent          = as.integer(packets_sent),
          packets_received      = as.integer(tcp_recv),
          packet_loss_pct       = as.numeric(tcp_loss),
          delivery_success_pct  = as.numeric(tcp_deliv_success),
          throughput_mbps       = as.numeric(tcp_tp),
          latency_ms            = round(as.numeric(tcp_latency), 2),
          jitter_ms             = round(as.numeric(tcp_jitter), 2),
          data_source           = "Simulated_RFC_Model",
          stringsAsFactors      = FALSE
        )
        obs_counter <- obs_counter + 1
        
        # ----------------------------------------------------------------------
        # RECORD UDP OBSERVATION
        # ----------------------------------------------------------------------
        udp_deliv_success <- round((udp_recv / packets_sent) * 100, 2)
        obs_udp <- data.frame(
          observation_id        = sprintf("OBS_%03d", obs_counter),
          trial_id              = trial_id,
          protocol              = "UDP",
          packet_size_bytes     = as.integer(psize),
          network_condition     = cond,
          packets_sent          = as.integer(packets_sent),
          packets_received      = as.integer(udp_recv),
          packet_loss_pct       = as.numeric(udp_loss),
          delivery_success_pct  = as.numeric(udp_deliv_success),
          throughput_mbps       = as.numeric(udp_tp),
          latency_ms            = round(as.numeric(udp_latency), 2),
          jitter_ms             = round(as.numeric(udp_jitter), 2),
          data_source           = "Simulated_RFC_Model",
          stringsAsFactors      = FALSE
        )
        obs_counter <- obs_counter + 1
        
        # Append observations to list
        trials_list[[length(trials_list) + 1]] <- obs_tcp
        trials_list[[length(trials_list) + 1]] <- obs_udp
        
        trial_counter <- trial_counter + 1
      }
    }
  }
  
  # 4. Combine into final dataframe
  dataset <- do.call(rbind, trials_list)
  
  # 5. Export to CSV
  write.csv(dataset, file = output_file, row.names = FALSE)
  
  message(sprintf("[SUCCESS] Dataset successfully generated with %d observations (%d TCP, %d UDP).",
                  nrow(dataset), sum(dataset$protocol == "TCP"), sum(dataset$protocol == "UDP")))
  message(sprintf("[SAVED] Saved to: %s", output_file))
  
  return(dataset)
}

# Execute function if called directly from command line / Rscript
if (!interactive()) {
  generate_network_data()
}

