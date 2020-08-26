#!/usr/bin/env bash

set -euo pipefail

sudo ls &> /dev/null

INSTANCE_NAME="dvvs-$(openssl rand -hex 3)"
REGION=$(jq -r --arg region "${1:-nl}" '.[$region]' regions.json)
ZONE="${REGION}-c"
GCLOUD_PROJECT=$GCP_PROJECT

trap "echo Cleaning up && gcloud beta compute instances delete ${INSTANCE_NAME} --quiet --project=$GCLOUD_PROJECT --zone=$ZONE && rm ${INSTANCE_NAME}.json" INT

echo "Creating VM"

gcloud beta compute instances create "${INSTANCE_NAME}" \
  --project=$GCLOUD_PROJECT \
  --zone="${ZONE}" \
  --machine-type=f1-micro \
  --preemptible \
  --format=json > "${INSTANCE_NAME}.json"

INSTANCE_IP=$(jq -r '.[0].networkInterfaces[0].accessConfigs[0].natIP' ${INSTANCE_NAME}.json)

echo "Created VM with IP ${INSTANCE_IP}"

echo "Waiting for SSH to come available..."
while ! nc -zv ${INSTANCE_IP} 22 &> /dev/null; do sleep 1; done
sleep 1

echo "Started VPN, stop with Ctrl+C"

sshuttle \
  --ssh-cmd 'ssh -q -o CheckHostIP=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' \
  --remote "${INSTANCE_IP}" \
  --syslog \
  0.0.0.0/0
