#!/bin/sh
# CGI Script - System Information API for EmiROS Dashboard
# Returns JSON with system metrics

echo "Content-Type: application/json"
echo "Cache-Control: no-cache"
echo ""

# Get CPU usage
get_cpu_usage() {
    # Read /proc/stat for CPU usage calculation
    if [ -f /proc/loadavg ]; then
        load=$(cat /proc/loadavg | awk '{print $1}')
        # Convert load to percentage (assuming 4 cores)
        cpu_percent=$(echo "$load * 25" | bc 2>/dev/null || echo "0")
        # Cap at 100
        if [ $(echo "$cpu_percent > 100" | bc 2>/dev/null || echo 0) -eq 1 ]; then
            cpu_percent="100.0"
        fi
        echo "$cpu_percent"
    else
        echo "0.0"
    fi
}

# Get memory info
get_memory_info() {
    if [ -f /proc/meminfo ]; then
        total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        
        # Convert to MB
        total_mb=$((total / 1024))
        available_mb=$((available / 1024))
        used_mb=$((total_mb - available_mb))
        
        # Calculate percentage
        if [ $total_mb -gt 0 ]; then
            percent=$((used_mb * 100 / total_mb))
        else
            percent=0
        fi
        
        echo "$total_mb $used_mb $percent"
    else
        echo "0 0 0"
    fi
}

# Get disk usage
get_disk_usage() {
    df_output=$(df -h / | tail -1)
    total=$(echo "$df_output" | awk '{print $2}')
    used=$(echo "$df_output" | awk '{print $3}')
    percent=$(echo "$df_output" | awk '{print $5}' | sed 's/%//')
    echo "$total $used $percent"
}

# Get uptime
get_uptime() {
    if [ -f /proc/uptime ]; then
        uptime_sec=$(cat /proc/uptime | awk '{print $1}' | cut -d. -f1)
        days=$((uptime_sec / 86400))
        hours=$(((uptime_sec % 86400) / 3600))
        minutes=$(((uptime_sec % 3600) / 60))
        
        if [ $days -gt 0 ]; then
            echo "${days}d ${hours}h ${minutes}m"
        elif [ $hours -gt 0 ]; then
            echo "${hours}h ${minutes}m"
        else
            echo "${minutes}m"
        fi
    else
        echo "unknown"
    fi
}

# Get IP address
get_ip_address() {
    ip addr show eth0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1 | head -1 || echo "N/A"
}

# Get kernel version
get_kernel() {
    uname -r 2>/dev/null || echo "unknown"
}

# Get hostname
get_hostname() {
    hostname 2>/dev/null || echo "emiros"
}

# Check if XFCE is running
is_xfce_running() {
    if pgrep -x "xfce4-session" > /dev/null; then
        echo "true"
    else
        echo "false"
    fi
}

# Get load average
get_load_average() {
    if [ -f /proc/loadavg ]; then
        cat /proc/loadavg | awk '{print $1, $2, $3}'
    else
        echo "0.00 0.00 0.00"
    fi
}

# Collect all data
CPU_USAGE=$(get_cpu_usage)
MEMORY_INFO=$(get_memory_info)
DISK_INFO=$(get_disk_usage)
UPTIME=$(get_uptime)
IP_ADDR=$(get_ip_address)
KERNEL=$(get_kernel)
HOSTNAME=$(get_hostname)
XFCE_RUNNING=$(is_xfce_running)
LOAD_AVG=$(get_load_average)

# Parse memory info
MEM_TOTAL=$(echo $MEMORY_INFO | awk '{print $1}')
MEM_USED=$(echo $MEMORY_INFO | awk '{print $2}')
MEM_PERCENT=$(echo $MEMORY_INFO | awk '{print $3}')

# Parse disk info
DISK_TOTAL=$(echo $DISK_INFO | awk '{print $1}')
DISK_USED=$(echo $DISK_INFO | awk '{print $2}')
DISK_PERCENT=$(echo $DISK_INFO | awk '{print $3}')

# Output JSON
cat << EOF
{
  "cpu_usage": "$CPU_USAGE",
  "memory_total": "$MEM_TOTAL",
  "memory_used": "$MEM_USED",
  "memory_percent": "$MEM_PERCENT",
  "disk_total": "$DISK_TOTAL",
  "disk_used": "$DISK_USED",
  "disk_percent": "$DISK_PERCENT",
  "uptime": "$UPTIME",
  "hostname": "$HOSTNAME",
  "kernel": "$KERNEL",
  "ip_address": "$IP_ADDR",
  "xfce_running": $XFCE_RUNNING,
  "load_average": "$LOAD_AVG"
}
EOF
