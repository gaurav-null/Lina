#!/bin/bash
sudo mkdir -p /opt/lina/serverBlocker
LOG_FILE="/opt/lina/serverBlocker/meBlocked.log"
# Writing a log // ToDo: find a better file directory
write_log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
  echo "$1"
}
# Function to block an IP one by one
block_ip() {
  ip=$1
  # If already blocked, skip
  if iptables -L INPUT -n | grep -q "$ip"; then
    write_log "Already blocked: $ip"
    return
  fi

  # Blocks ranges that has - in the iprange
  if [[ "$ip" =~ - ]]; then
    iptables -A INPUT -m iprange --src-range "$ip" -j DROP
    write_log "Blocked IP range: $ip"
    return
  fi

  # Block single ip or with / iprange
  iptables -A INPUT -s "$ip" -j DROP
  write_log "Blocked IP/CIDR: $ip"
}

block_from_file() {
  # Looks for the ME file
  file="$(dirname "$0")/me_block.txt"
  if [[ ! -f "$file" ]]; then
    echo "Error: File not found: $file"
    exit 1
  fi

  while IFS= read -r ip; do
    [[ -z "$ip" || "$ip" =~ ^# ]] && continue
    block_ip "$ip"
  done < "$file"
}

# Runs the function // I forgot this line and was working to fix it for like 2hrs TwT
block_from_file
