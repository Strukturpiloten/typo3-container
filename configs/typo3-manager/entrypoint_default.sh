#!/usr/bin/env sh
set -e

echo "Service: Starting cron"
# Run supercronic in foreground
supercronic -split-logs "${PODMAN_TYPO3MANAGER_CRON_ROOT_FILE_CONTAINER}"
