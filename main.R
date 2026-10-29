# ==============================================================================
# SCRIPT: main.R (MASTER EXECUTION ORCHESTRATOR)
# PROJECT: TCP vs UDP Protocol Performance Analysis Using R Programming
# SUBTITLE: A Comparative Study of Throughput, Latency, Packet Loss, Jitter,
#           and Reliability
# AUTHOR: BCA 3rd Year Student Project
# SUBJECTS: Introduction to Data Communication and Computer Networks (IDCCN)
#           R Programming Language
#           Computational Data Analytics (CDA)
# ==============================================================================
# INSTRUCTIONS:
# Open this script in RStudio and click 'Source', or run via terminal:
#   Rscript main.R
# ==============================================================================

cat("\n")
cat("################################################################################\n")
cat("#       TCP vs UDP PROTOCOL PERFORMANCE ANALYSIS BENCHMARK SYSTEM              #\n")
cat("#         BCA 3rd Year Academic Project in Networking & Data Analytics         #\n")
cat("################################################################################\n\n")

# ------------------------------------------------------------------------------
# STEP 1: Automated Package Management (Check and Install Dependencies)
# ------------------------------------------------------------------------------
required_packages <- c("ggplot2", "dplyr", "readr", "tidyr")

cat("[STEP 1/5] Checking and loading required R packages...\n")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("          - Package '%s' is not installed. Installing now...\n", pkg))
    install.packages(pkg, repos = "https://cloud.r-project.org", dependencies = TRUE)
  }
  library(pkg, character.only = TRUE)
  cat(sprintf("          [OK] Loaded '%s' (v%s)\n", pkg, packageVersion(pkg)))
}

# ------------------------------------------------------------------------------
# STEP 2: Directory Architecture Verification
# ------------------------------------------------------------------------------
cat("\n[STEP 2/5] Initializing workspace directories...\n")
dirs <- c("data", "output", "report")
for (d in dirs) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = TRUE)
    cat(sprintf("          - Created directory: %s/\n", d))
  } else {
    cat(sprintf("          [OK] Directory exists: %s/\n", d))
  }
}

# ------------------------------------------------------------------------------
# STEP 3: Dataset Generation / Validation
# ------------------------------------------------------------------------------
cat("\n[STEP 3/5] Checking experimental dataset...\n")
source("generate_data.R")

dataset_path <- "data/network_performance.csv"
if (!file.exists(dataset_path)) {
  cat("          - Dataset not found. Generating reproducible simulation...\n")
  generate_network_data(dataset_path)
} else {
  cat(sprintf("          [OK] Existing dataset found at: %s\n", dataset_path))
}

# ------------------------------------------------------------------------------
# STEP 4: Computational Data Analysis & Statistical Testing
# ------------------------------------------------------------------------------
cat("\n[STEP 4/5] Running statistical analysis pipeline...\n")
source("analyze_data.R")
analysis_results <- run_network_analysis(input_file = dataset_path, output_dir = "output")

# ------------------------------------------------------------------------------
# STEP 5: Data Visualization Engine (ggplot2)
# ------------------------------------------------------------------------------
cat("\n[STEP 5/5] Generating publication-quality charts...\n")
source("plots.R")
generate_network_plots(input_file = "output/cleaned_network_performance.csv", output_dir = "output")

# ------------------------------------------------------------------------------
# CONSOLE SUMMARY & VIVA TAKEAWAYS
# ------------------------------------------------------------------------------
cat("\n")
cat("================================================================================\n")
cat("                       FINAL PROJECT EXECUTION COMPLETE                         \n")
cat("================================================================================\n")
cat("Generated Output Artifacts:\n")
cat("  1. Cleaned Dataset     : output/cleaned_network_performance.csv\n")
cat("  2. Protocol Summary    : output/protocol_summary.csv\n")
cat("  3. Condition Summary   : output/condition_summary.csv\n")
cat("  4. Statistical Tests   : output/statistical_results.csv\n")
cat("  5. Academic Report     : output/analysis_report.txt\n")
cat("  6. Charts Generated    :\n")
cat("     - output/throughput_comparison.png\n")
cat("     - output/latency_comparison.png\n")
cat("     - output/packet_loss_comparison.png\n")
cat("     - output/jitter_comparison.png\n")
cat("     - output/packet_size_comparison.png\n")
cat("     - output/network_condition_comparison.png\n")
cat("================================================================================\n")
cat("\nKEY ACADEMIC CONCLUSIONS (VIVA SUMMARY):\n")
cat(" 1. Throughput: In clean LANs, TCP and UDP perform similarly (~90-95 Mbps).\n")
cat("    Under congestion, TCP throughput declines steeply due to congestion backoff,\n")
cat("    whereas UDP sends at line speed but suffers heavy unrecovered drops.\n")
cat(" 2. Latency: UDP maintains consistently lower latency (up to 3x lower in congestion)\n")
cat("    because it avoids head-of-line blocking and ARQ retransmission wait times.\n")
cat(" 3. Reliability: TCP achieves 100% application delivery via 3-way handshakes\n")
cat("    and acknowledgements. UDP provides 0% delivery guarantee, losing up to 24%\n")
cat("    of packets under severe congestion.\n")
cat(" 4. MTU Impact: Both protocols achieve significantly higher throughput with\n")
cat("    larger packets (1460 bytes) due to reduced header-to-payload overhead.\n")
cat("================================================================================\n\n")

