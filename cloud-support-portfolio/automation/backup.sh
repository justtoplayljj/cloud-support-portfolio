#!/usr/bin/env bash
# ==================================
# MySQL Backup Script
# ==================================
BACKUP_DIR="/backup/mysql"
DATE=$(date +%F)
LOG_FILE="/var/log/mysql_backup.log"
MYSQL_USER="root"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"
mkdir -p "${BACKUP_DIR}"
echo "[$(date '+%F %T')] Backup Started" >> "${LOG_FILE}"
mysqldump \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    --single-transaction \
    --all-databases \
    > "${BACKUP_DIR}/mysql_${DATE}.sql"
if [ $? -eq 0 ]; then
    gzip "${BACKUP_DIR}/mysql_${DATE}.sql"
    echo "[$(date '+%F %T')] Backup Success" >> "${LOG_FILE}"
else
    echo "[$(date '+%F %T')] Backup Failed" >> "${LOG_FILE}"
    exit 1
fi
find "${BACKUP_DIR}" \
    -name "*.gz" \
    -mtime +7 \
    -delete
echo "[$(date '+%F %T')] Old Backups Cleaned" >> "${LOG_FILE}"
echo "[$(date '+%F %T')] Backup Completed" >> "${LOG_FILE}"
