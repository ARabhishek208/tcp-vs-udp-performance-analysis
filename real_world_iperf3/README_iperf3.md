# Real-World Network Benchmarking Guide Using iperf3

## 1. Overview
While the primary project utilizes a mathematically modeled, reproducible synthetic dataset (`data/network_performance.csv`), this module explains how to collect **actual hardware-level network measurements** using `iperf3`.

`iperf3` is the industry-standard, open-source active measurement tool for testing maximum achievable bandwidth, latency, jitter, and packet loss across IP networks.

---

## 2. Ethical and Authorization Notice
> [!CAUTION]
> Network performance testing saturates transmission links and can disrupt business or institutional services. Execute tests **ONLY** on private test networks, local laboratory machines, or networks where you have explicit authorization. Do not run UDP flooding tests on public Wi-Fi or production university backbones.

---

## 3. Installation and Verification

### On Windows
1. Download the latest compiled 64-bit binary from [iperf.fr](https://iperf.fr/iperf-download.php).
2. Extract `iperf3.exe` and `cygwin1.dll` to `C:\iperf3` or into your project folder `real_world_iperf3/`.
3. Open Command Prompt or PowerShell and verify:
   ```cmd
   iperf3.exe --version
   ```

### On Linux (Ubuntu / Debian / Kali)
```bash
sudo apt update
sudo apt install iperf3 -y
iperf3 --version
```

---

## 4. Test Topology Setup
You need two machines connected over an Ethernet switch, Wi-Fi, or direct cable:
- **Server Machine (Receiver)**: IP e.g., `192.168.1.100`
- **Client Machine (Sender)**: IP e.g., `192.168.1.101`

### Step 1: Start the iperf3 Server
On the server machine, start the listener on default port `5201`:
```cmd
iperf3 -s
```
*(Ensure Windows Firewall allows inbound connections on TCP and UDP port 5201).*

---

## 5. Running TCP and UDP Tests

### A. Running a TCP Test
TCP automatically negotiates window sizes and attempts to maximize link throughput:
```cmd
iperf3 -c 192.168.1.100 -t 10 -l 1460 --json > tcp_test_1460.json
```
- `-c 192.168.1.100`: Connect to server IP.
- `-t 10`: Test duration (10 seconds).
- `-l 1460`: Buffer length / packet size (Bytes).
- `--json`: Output full metrics in structured JSON format.

### B. Running a UDP Test
> [!IMPORTANT]
> By default, `iperf3 -u` sends at only **1 Mbps**! In order to benchmark UDP fairly against TCP, you **must explicitly configure the target offered bitrate** using the `-b` flag (e.g., `-b 100M` for 100 Mbps or `-b 0` for unlimited).

```cmd
iperf3 -c 192.168.1.100 -u -b 100M -t 10 -l 1460 --json > udp_test_1460.json
```
- `-u`: Enable UDP mode.
- `-b 100M`: Target bandwidth of 100 Mbps.
- `-l 1460`: Datagram payload size.

---

## 6. Understanding the Metrics Reported by iperf3

| Metric | TCP Output | UDP Output |
| :--- | :--- | :--- |
| **Throughput** | Measured in Mbits/sec (actual delivered payload). | Measured at sender (offered) and receiver (delivered). Always report **receiver** throughput. |
| **Packet Loss** | 0% (TCP retransmits lost packets; reported as `retransmits` count). | Reported as `lost_packets / total_packets (loss_percent %)`. |
| **Latency / RTT** | Reported in JSON under `end.streams.sender.mean_rtt` (ms). | Measured via round-trip probe or receiver timestamping. |
| **Jitter** | Not reported in standard TCP output (TCP is stream-oriented). | Explicitly measured in milliseconds (`end.sum.jitter_ms`). |

---

## 7. Converting Real Measurements into Project CSV

We provide an automated R parser: `real_world_iperf3/convert_iperf3_to_csv.R`.

### Procedure:
1. Run test sequences using the automated batch script:
   ```cmd
   cd real_world_iperf3
   run_iperf3_tests.bat 192.168.1.100
   ```
2. The batch script generates a series of JSON files (`tcp_64.json`, `udp_64.json`, etc.).
3. Run the conversion script in R:
   ```R
   source("real_world_iperf3/convert_iperf3_to_csv.R")
   convert_iperf_json_to_csv(json_dir = "real_world_iperf3/raw_logs", output_csv = "data/network_performance.csv")
   ```
4. Re-run `main.R`. All plots, summaries, and hypothesis tests will now reflect your real laboratory network measurements!

