#!bin/bash

PROJECT="cloud-support-portfolio"

mkdir -p $PROJECT/{architecture,incidents,runbooks,monitoring,automation,kubernetes,cloud,tickets,postmortems,docs}

touch $PROJECT/README.md

# incidents
for i in \
001-high-cpu \
002-disk-full \
003-nginx-502 \
004-dns-failure \
005-cert-expired \
006-container-crash \
007-memory-leak \
008-node-down \
009-pod-crashloop \
010-ingress-failure
do
    touch "$PROJECT/incidents/${i}.md"
done

# runbooks
for i in \
cpu-troubleshooting \
disk-troubleshooting \
dns-troubleshooting \
ssl-troubleshooting \
network-troubleshooting \
k8s-pod-troubleshooting
do
    touch "$PROJECT/runbooks/${i}.md"
done

# automation
touch $PROJECT/automation/healthcheck.sh
touch $PROJECT/automation/backup.sh
touch $PROJECT/automation/rotate-log.sh
touch $PROJECT/automation/docker-cleanup.sh
touch $PROJECT/automation/system-report.sh

echo "Portfolio structure created."
