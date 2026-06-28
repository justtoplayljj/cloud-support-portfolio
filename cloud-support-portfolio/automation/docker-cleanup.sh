#!/usr/bin/env bash

set -euo pipefail

EXECUTE=false

usage() {
    printf '%s\n' 'Usage: docker-cleanup.sh [--execute]'
    printf '%s\n' 'Default: report reclaimable resources without deleting them.'
}

case "${1:-}" in
    "") ;;
    --execute) EXECUTE=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
esac

command -v docker >/dev/null 2>&1 || {
    printf 'Error: docker is not installed.\n' >&2
    exit 1
}
docker info >/dev/null 2>&1 || {
    printf 'Error: cannot connect to the Docker daemon.\n' >&2
    exit 1
}

printf '%s\n' 'Docker disk usage:'
docker system df
printf '\nStopped containers:\n'
docker ps --all --filter status=exited --format '  {{.ID}}  {{.Names}}  {{.Status}}'
printf '\nDangling images:\n'
docker images --filter dangling=true --format '  {{.ID}}  {{.Repository}}:{{.Tag}}  {{.Size}}'

if [[ "${EXECUTE}" != true ]]; then
    printf '\nDry run only. Use --execute to run docker system prune.\n'
    exit 0
fi

docker system prune --force
printf '\nDocker disk usage after cleanup:\n'
docker system df
