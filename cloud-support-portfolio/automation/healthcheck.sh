#!/usr/bin/env bash
# Server Health Check Script
REPORT_TIME=$(date "+%F %T")
HOST_NAME=$(hostname)

echo "================================="
echo "Server Health Check Report"
echo "Host: ${HOST_NAME}"
echo "Time: ${REPORT_TIME}"
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
