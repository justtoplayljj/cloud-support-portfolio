#!/usr/bin/env bash

set -euo pipefail

LOG_DIR="/var/log/myapp"
ARCHIVE_DIR=""
MAX_SIZE_MB=100
EXECUTE=false

usage() {
    printf '%s\n' 'Usage: rotate-log.sh [--log-dir DIR] [--archive-dir DIR]'
    printf '%s\n' '                     [--max-size MB] [--execute]'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --log-dir) LOG_DIR="${2:?--log-dir requires a value}"; shift 2 ;;
        --archive-dir) ARCHIVE_DIR="${2:?--archive-dir requires a value}"; shift 2 ;;
        --max-size) MAX_SIZE_MB="${2:?--max-size requires a value}"; shift 2 ;;
        --execute) EXECUTE=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
    esac
done

[[ "${MAX_SIZE_MB}" =~ ^[1-9][0-9]*$ ]] || {
    printf 'Error: --max-size must be a positive integer.\n' >&2
    exit 2
}
[[ -d "${LOG_DIR}" ]] || {
    printf 'Error: directory does not exist: %s\n' "${LOG_DIR}" >&2
    exit 1
}

ARCHIVE_DIR="${ARCHIVE_DIR:-${LOG_DIR}/archive}"
MAX_SIZE_BYTES=$((MAX_SIZE_MB * 1024 * 1024))
FOUND=false

while IFS= read -r -d '' log_file; do
    FOUND=true
    timestamp="$(date '+%Y%m%d-%H%M%S')"
    archive_file="${ARCHIVE_DIR}/$(basename "${log_file}").${timestamp}"
    printf 'Rotate: %s -> %s.gz\n' "${log_file}" "${archive_file}"

    if [[ "${EXECUTE}" == true ]]; then
        mkdir -p "${ARCHIVE_DIR}"
        cp --preserve=mode,timestamps "${log_file}" "${archive_file}"
        gzip "${archive_file}"
        : > "${log_file}"
    fi
done < <(find "${LOG_DIR}" -maxdepth 1 -type f -name '*.log' \
    -size "+${MAX_SIZE_BYTES}c" -print0)

if [[ "${FOUND}" != true ]]; then
    printf 'No log files exceed %s MB.\n' "${MAX_SIZE_MB}"
elif [[ "${EXECUTE}" != true ]]; then
    printf 'Dry run only. Use --execute to rotate listed files.\n'
fi
