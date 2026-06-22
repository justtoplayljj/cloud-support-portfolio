#!/bin/bash

# ==================================

# Server Health Check Script

# ==================================

DATE=$(date "+%F %T")
HOSTNAME=$(hostname)

echo "================================="
echo "Server Health Check Report"
echo "Host: $HOSTNAME"
echo "Time: $DATE"
echo "================================="

echo
echo "[CPU Usage]"

CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d"." -f1)
CPU_USAGE=$((100 - CPU_IDLE))

echo "CPU Usage: ${CPU_USAGE}%"

echo
echo "[Memory Usage]"

free -h

echo
echo "[Disk Usage]"

df -h | grep '^/dev'

echo
echo "[Nginx Status]"

systemctl is-active nginx

echo
echo "[MySQL Status]"

systemctl is-active mysql

echo
echo "[Top 5 Memory Processes]"

ps aux --sort=-%mem | head -6

echo
echo "Health Check Completed."
