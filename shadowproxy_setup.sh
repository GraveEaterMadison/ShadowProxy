#!/bin/bash

LOG_FILE="tor_proxy_setup.log"

echo "[INFO] Setting up Tor proxy with User-Agent rotation ..." | tee -a "$LOG_FILE"

# Function to log errors
log_error() {
    echo "[ERROR] $1" | tee -a "$LOG_FILE"
    exit 1
}

# Check if required packages are installed
install_packages() {
    echo "[INFO] Checking for required dependencies..." | tee -a "$LOG_FILE"
    if ! command -v tor &> /dev/null; then
        echo "[INFO] Installing Tor..." | tee -a "$LOG_FILE"
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt update && sudo apt install -y tor torsocks || log_error "Failed to install Tor."
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install tor torsocks || log_error "Failed to install Tor."
        else
            log_error "Unsupported OS. Install Tor manually."
        fi
    else
        echo "[INFO] Tor is already installed." | tee -a "$LOG_FILE"
    fi
}

# Configure Tor for proxy usage
configure_tor() {
    TORRC_PATH="/etc/tor/torrc"
    if ! grep -q "SocksPort 9050" "$TORRC_PATH"; then
        echo "[INFO] Configuring Tor..." | tee -a "$LOG_FILE"
        sudo bash -c "cat > $TORRC_PATH" <<EOL
SocksPort 9050
ControlPort 9051
CookieAuthentication 1
RunAsDaemon 1
Log notice file /var/log/tor/notices.log
EOL
        echo "[INFO] Tor configuration updated." | tee -a "$LOG_FILE"
    fi
    
    # Restart Tor service
    echo "[INFO] Restarting Tor service..." | tee -a "$LOG_FILE"
    sudo systemctl restart tor || log_error "Failed to restart Tor service."
    sleep 5
}

# Function to renew Tor IP every 10 minutes
renew_tor_ip() {
    while true; do
        echo "[INFO] Changing Tor IP..." | tee -a "$LOG_FILE"
        COOKIE=$(sudo cat /var/lib/tor/control_auth_cookie | tr -d '\n')
        (echo -e "AUTHENTICATE \"$COOKIE\"\r\nSIGNAL NEWNYM\r\nQUIT") | nc localhost 9051 || log_error "Tor IP change failed."
        sleep 600  # Wait 10 minutes before next change
    done
}

# Function to randomize User-Agent
randomize_user_agent() {
    USER_AGENTS=(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        "Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/537.36"
        "Mozilla/5.0 (Android 11; Mobile; rv:89.0) Gecko/89.0 Firefox/89.0"
    )

    while true; do
        RANDOM_USER_AGENT=${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}
        echo "[INFO] Setting random User-Agent: $RANDOM_USER_AGENT" | tee -a "$LOG_FILE"
        export USER_AGENT="$RANDOM_USER_AGENT"
        sleep 300  # Change User-Agent every 5 minutes
    done
}

# Function to check if Tor proxy is working
check_tor_proxy() {
    echo "[INFO] Checking Tor proxy connection..." | tee -a "$LOG_FILE"
    if torsocks curl --silent --fail https://check.torproject.org/ | grep -q "Congratulations"; then
        echo "[SUCCESS] Tor proxy is working!" | tee -a "$LOG_FILE"
    else
        log_error "Tor proxy test failed. Check Tor settings."
    fi
}

# === Main Execution ===
install_packages
configure_tor

# Start IP rotation and User-Agent randomization in the background
renew_tor_ip &
randomize_user_agent &

# Wait a few seconds before checking the proxy
sleep 5
check_tor_proxy

echo "[INFO] Tor proxy is running with User-Agent rotation." | tee -a "$LOG_FILE"
echo "[INFO] SOCKS5 Proxy: 127.0.0.1:9050" | tee -a "$LOG_FILE"
