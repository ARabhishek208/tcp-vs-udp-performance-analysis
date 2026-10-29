# TCP vs UDP Protocol Performance Analysis Using R Programming

> **Subtitle:** A Comparative Study of Throughput, Latency, Packet Loss, Jitter, and Reliability  
> **Target Audience:** Bachelor of Computer Applications (BCA) – 3rd Year Final Academic Project  
> **Academic Subject Integration:**
> 1. Introduction to Data Communication and Computer Networks (IDCCN)
> 2. R Programming Language
> 3. Computational Data Analytics (CDA)

---

## 1. Project Overview

In computer networking, the Transport Layer (Layer 4 of the OSI model) is tasked with process-to-process message delivery. The two foundational workhorses of this layer are:
- **Transmission Control Protocol (TCP - RFC 793):** Connection-oriented, reliable, byte-stream protocol providing full error detection, flow control (sliding window), and congestion management (Slow Start, Congestion Avoidance, Fast Retransmit).
- **User Datagram Protocol (UDP - RFC 768):** Connectionless, lightweight, message-oriented datagram protocol providing best-effort delivery without connection handshakes, acknowledgements, or flow control.

This project bridges **networking theory** with **practical computational data analytics using R**. Through a rigorous experimental design covering **240 controlled experimental observations across 120 matched conditions**, this project quantitatively analyzes the engineering trade-offs between speed and reliability across multiple packet sizes (64, 512, 1024, 1460 Bytes) and network conditions (*Ideal LAN*, *Moderate Congestion*, and *Severe Loss & Jitter*).

---

## 2. Directory Structure

```text
tcp_udp_performance_analysis/
│
├── README.md                           <- Master project manual & execution guide
├── main.R                              <- Master orchestrator (Installs pkgs, runs pipeline)
├── generate_data.R                     <- Reproducible synthetic dataset generator (Seed 42)
├── analyze_data.R                      <- Data cleaning, summary stats, inferential t-tests
├── plots.R                             <- High-resolution ggplot2 visualization generator
├── app.R                               <- [Optional] Interactive R Shiny Dashboard for Viva
│
├── data/
│   └── network_performance.csv         <- Primary benchmark dataset (240 observations)
│
├── output/
│   ├── cleaned_network_performance.csv <- Validated dataset
│   ├── protocol_summary.csv            <- Mean, Median, SD, Min, Max across protocols
│   ├── condition_summary.csv           <- Breakdown by network condition
│   ├── statistical_results.csv         <- Paired t-test, Wilcoxon test, p-values, 95% CIs
│   ├── analysis_report.txt             <- Full textual academic analysis report
│   ├── throughput_comparison.png       <- Boxplot of Throughput (Mbps)
│   ├── latency_comparison.png          <- Latency inflation under congestion (ms)
│   ├── packet_loss_comparison.png      <- Application vs Wire loss rates (%)
│   ├── jitter_comparison.png           <- Delay variation stability (ms)
│   ├── packet_size_comparison.png      <- MTU throughput scaling (64B to 1460B)
│   └── network_condition_comparison.png<- Multi-panel faceted performance overview
│
├── real_world_iperf3/                  <- [Optional] Real hardware testing module
│   ├── README_iperf3.md                <- Guide for live network benchmarking with iperf3
│   ├── run_iperf3_tests.bat            <- Windows batch automation script for iperf3
│   └── convert_iperf3_to_csv.R         <- R parser to convert iperf3 logs to project CSV
│
└── report/
    ├── project_report.md               <- 19-Chapter University Academic Project Report
    └── viva_questions_answers.md       <- 30 Viva Voce Q&As + Faculty Live Demo Script
```

---

## 3. Software Requirements & Setup

### Requirements
- **R**: Version 4.0.0 or higher (Free from [CRAN](https://cran.r-project.org/)).
- **RStudio Desktop**: (Recommended IDE, free from [Posit](https://posit.co/download/rstudio-desktop/)) or VS Code with R extension.
- **R Packages**: `ggplot2`, `dplyr`, `readr`, `tidyr`, and optionally `shiny`.
- No paid software, cloud subscriptions, or database servers required.

### One-Time Package Installation (in R or RStudio Console)
```R
install.packages(c("ggplot2", "dplyr", "readr", "tidyr", "shiny"))
```

---

## 4. How to Run the Project (Step-by-Step)

### Option A: From RStudio (Recommended)
1. Open RStudio.
2. Go to **File -> Open Project...** or set your working directory to this folder:
   ```R
   setwd("c:/Users/hp/Desktop/integrated")
   ```
3. Open `main.R` in the editor.
4. Click the **Source** button (top right of editor) or press `Ctrl + Shift + S`.
5. Observe the automated package check, dataset verification, statistical calculations, and chart generation in the Console.
6. Open the `output/` folder to view the generated CSVs, PNG charts, and `analysis_report.txt`.

### Option B: From Command Prompt / PowerShell (Windows)
```powershell
cd c:\Users\hp\Desktop\integrated
Rscript main.R
```

### Option C: Launching the Interactive Shiny Dashboard
```R
# Inside RStudio, open app.R and click "Run App", or run:
shiny::runApp("app.R")
```

---

## 5. Performance Parameters Analyzed

| Metric | Formula | Unit | Preferred Direction | Networking Significance |
| :--- | :--- | :---: | :---: | :--- |
| **Throughput** | $\frac{\text{Packets Received} \times \text{Size (Bytes)} \times 8}{\text{Time (s)} \times 10^6}$ | Mbps | Higher $\uparrow$ | Effective data transmission rate delivered to application. |
| **Latency (RTT)** | $T_{\text{receipt}} - T_{\text{send}}$ | ms | Lower $\downarrow$ | Delay incurred in traversing the link, including queueing and retransmission. |
| **Packet Loss** | $\frac{\text{Sent} - \text{Received}}{\text{Sent}} \times 100\%$ | % | Lower $\downarrow$ | Proportion of datagrams dropped by router buffer overflows or line noise. |
| **Jitter** | $|D_{i} - D_{i-1}|$ (Inter-arrival variation) | ms | Lower $\downarrow$ | Variation in delay affecting real-time audio/video buffer underrun. |
| **Reliability** | $\frac{\text{Delivered distinct packets}}{\text{Offered distinct packets}} \times 100\%$ | % | Higher $\uparrow$ | Transport protocol guarantee of complete and ordered delivery. |

---

## 6. Key Scientific Findings

1. **Throughput Parity on Ideal Links**: Under LAN conditions without line noise, both protocols saturate the link (>90 Mbps), with UDP marginally higher due to an 8-byte header vs TCP's 20–40 bytes.
2. **TCP Congestion Degradation**: Under severe loss and jitter, TCP throughput plummets to ~19.5 Mbps (a ~78% drop) due to Multiplicative Decrease and Retransmission Timeouts (RTO), resetting its congestion window ($cwnd$).
3. **UDP Latency Superiority Under Loss**: UDP latency remains low (~98 ms) even under severe loss because it drops lost packets and never stalls. In contrast, TCP latency surges to >135 ms due to head-of-line blocking and ARQ wait states.
4. **Reliability Paradox**: TCP guarantees **100.0%** delivery to the application across all environments. UDP delivery drops to **81.6%** in severe conditions.
5. **Packet Size Efficiency**: Both protocols gain ~400% higher throughput moving from 64-byte to 1460-byte packets, proving that larger payload sizes amortize per-packet header overhead.

