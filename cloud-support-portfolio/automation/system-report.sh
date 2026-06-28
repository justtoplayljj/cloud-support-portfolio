#!/usr/bin/env bash

set -euo pipefail

OUTPUT_FILE=""

if [[ "${1:-}" == "--output" ]]; then
    OUTPUT_FILE="${2:?--output requires a file path}"
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    printf '%s\n' 'Usage: system-report.sh [--output FILE]'
    exit 0
elif [[ $# -gt 0 ]]; then
    printf 'Unknown option: %s\n' "$1" >&2
    exit 2
fi

if [[ -n "${OUTPUT_FILE}" ]]; then
    mkdir -p "$(dirname "${OUTPUT_FILE}")"
    exec > >(tee "${OUTPUT_FILE}")
fi

section() {
    printf '\n===== %s =====\n' "$1"
}

printf 'System Report\nGenerated: %s\nHostname: %s\n' \
    "$(date '+%F %T %Z')" "$(hostname)"

section "Operating System"
if [[ -r /etc/os-release ]]; then
    sed -n 's/^PRETTY_NAME=//p' /etc/os-release | tr -d '"'
else
    uname -a
fi

section "Uptime and Load"
uptime
section "CPU"
printf 'Logical CPUs: %s\n' "$(getconf _NPROCESSORS_ONLN)"
lscpu | sed -n '/^Model name:/p' || true
section "Memory"
free -h
section "Disk"
df -hT
section "Top Memory Processes"
ps aux --sort=-%mem | head -n 6
section "Failed systemd Units"
systemctl --failed --no-pager 2>/dev/null || printf 'systemd status unavailable.\n'
section "Docker"
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null || \
    printf 'Docker is unavailable or inaccessible.\n'
