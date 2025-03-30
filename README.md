# ShadowProxy: Tor Proxy with User-Agent Rotation

This repository provides a **Bash script** that automates the setup of a **Tor proxy with User-Agent rotation**, ensuring anonymity and privacy when accessing the web. This script is particularly useful for **Reddit bots** or **web scrapers** that need to cycle IPs and avoid detection.

## 🚀 Features

✅ Installs and configures **Tor** automatically\
✅ Rotates IP every **10 minutes** using Tor’s control port\
✅ Randomizes **User-Agent** every **5 minutes** to evade detection\
✅ Verifies that the Tor proxy is working correctly\
✅ Supports **Linux** and **macOS**

---

## 📌 Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Running in Google Colab](#running-in-google-colab)
- [How It Works](#how-it-works)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## ⚙️ Requirements

Before running the script, make sure you have the following:

- **Linux or macOS** (Windows users can use **WSL or a virtual machine**)
- **Git installed**
- **Tor and Torsocks** (automatically installed by the script if missing)

---

## 🛠️ Installation

### **1️⃣ Clone the Repository**

```bash
git clone https://github.com/GraveEaterMadison/ShadowProxy.git
cd ShadowProxy
```

### **2️⃣ Give Execute Permission**

```bash
chmod +x shadowproxy_setup.sh
```

---

## ▶️ Usage

### **Run the Script**

```bash
./shadowproxy_setup.sh
```

This will:

- Install **Tor** if it's missing
- Configure **Tor proxy** (Socks5 on `127.0.0.1:9050`)
- Rotate IP every **10 minutes**
- Change User-Agent every **5 minutes**
- Verify that the proxy is working

### **Check if Tor Proxy is Working**

```bash
torsocks curl https://check.torproject.org/
```

If the setup was successful, you should see:

✅ *Congratulations! This browser is configured to use Tor.*

---

## 📡 Running in Google Colab

You can run this script in **Google Colab** using the following steps:

### **1️⃣ Open Google Colab**

Go to [Google Colab](https://colab.research.google.com/).

### **2️⃣ Run the following commands in a Colab notebook**

```python
!apt update && apt install -y tor torsocks
!echo -e "SocksPort 9050\nControlPort 9051\nCookieAuthentication 1\nRunAsDaemon 1" > /etc/tor/torrc
!service tor start
```

### **3️⃣ Check if Tor is Running**

```python
!torsocks curl https://check.torproject.org/
```

---

## 🔍 How It Works

### **1️⃣ Installing Dependencies**

The script checks for **Tor** and **Torsocks**. If they are not installed, it installs them based on the operating system:

- **Linux:** `sudo apt install -y tor torsocks`
- **macOS:** `brew install tor torsocks`

### **2️⃣ Configuring Tor**

It modifies the **Tor configuration file** (`/etc/tor/torrc`) to ensure the proxy runs correctly:

```bash
SocksPort 9050
ControlPort 9051
CookieAuthentication 1
RunAsDaemon 1
```

### **3️⃣ Rotating IPs**

Every **10 minutes**, the script sends a **NEWNYM** signal to Tor to change the IP address:

```bash
echo -e "AUTHENTICATE \"$COOKIE\"\r\nSIGNAL NEWNYM\r\nQUIT" | nc localhost 9051
```

### **4️⃣ Changing User-Agents**

Every **5 minutes**, the script selects a random User-Agent from a predefined list:

```bash
export USER_AGENT="$RANDOM_USER_AGENT"
```

---

## 🛠️ Troubleshooting

❌ **Tor service is not starting**\
➡ Try restarting it manually:

```bash
sudo systemctl restart tor
```

❌ **Proxy test failed**\
➡ Check if Tor is running:

```bash
ps aux | grep tor
```

➡ Try running manually:

```bash
torsocks curl https://check.torproject.org/
```

---

## 📜 License

This project is licensed under the **MIT License**. Feel free to use and modify it.

