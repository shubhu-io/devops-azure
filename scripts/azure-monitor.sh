#!/usr/bin/env bash
# ==============================================================================
# Script: azure-monitor.sh
# Description: Set up Azure Monitor alerts for VM CPU, memory, and disk
# Usage: ./azure-monitor.sh [RESOURCE_GROUP] [VM_NAME] [EMAIL]
# ==============================================================================

set -euo pipefail

RESOURCE_GROUP="${1:-rg-devops-eastus}"
VM_NAME="${2:-devops-vm}"
ALERT_EMAIL="${3:-}"
ACTION_GROUP_NAME="devops-alerts-ag"

if ! command -v az &>/dev/null; then
  echo "[ERROR] Azure CLI not found. Run ./setup.sh first."; exit 1
fi

if [ -z "$ALERT_EMAIL" ]; then
  echo "Usage: $0 <RESOURCE_GROUP> <VM_NAME> <EMAIL>"
  exit 1
fi

echo "[INFO] Setting up Azure Monitor for VM: ${VM_NAME}"

# ─── Get VM Resource ID ───────────────────────────────────────────────────────
VM_ID=$(az vm show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --query "id" \
  --output tsv)

echo "[INFO] VM Resource ID: ${VM_ID}"

# ─── Create Action Group ──────────────────────────────────────────────────────
echo "[INFO] Creating Action Group: ${ACTION_GROUP_NAME}..."
az monitor action-group create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACTION_GROUP_NAME" \
  --short-name "devopsag" \
  --action email "devops-email" "$ALERT_EMAIL" \
  --output none 2>/dev/null || echo "[INFO] Action group already exists."

AG_ID=$(az monitor action-group show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACTION_GROUP_NAME" \
  --query "id" \
  --output tsv)

# ─── CPU High Alert ───────────────────────────────────────────────────────────
echo "[INFO] Creating CPU > 80% alert..."
az monitor metrics alert create \
  --resource-group "$RESOURCE_GROUP" \
  --name "${VM_NAME}-cpu-high" \
  --scopes "$VM_ID" \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --severity 2 \
  --description "VM CPU utilization exceeded 80%" \
  --action "$AG_ID" \
  --output none
echo "  ✅ CPU alert created"

# ─── Available Memory Alert ───────────────────────────────────────────────────
echo "[INFO] Creating Available Memory < 500MB alert..."
az monitor metrics alert create \
  --resource-group "$RESOURCE_GROUP" \
  --name "${VM_NAME}-mem-low" \
  --scopes "$VM_ID" \
  --condition "avg Available Memory Bytes < 524288000" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --severity 2 \
  --description "VM Available Memory below 500MB" \
  --action "$AG_ID" \
  --output none
echo "  ✅ Memory alert created"

# ─── OS Disk IOPS Alert ───────────────────────────────────────────────────────
echo "[INFO] Creating OS Disk IOPS > 400 alert..."
az monitor metrics alert create \
  --resource-group "$RESOURCE_GROUP" \
  --name "${VM_NAME}-disk-iops" \
  --scopes "$VM_ID" \
  --condition "avg OS Disk IOPS Consumed Percentage > 90" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --severity 3 \
  --description "OS Disk IOPS consumed > 90%" \
  --action "$AG_ID" \
  --output none
echo "  ✅ Disk IOPS alert created"

echo ""
echo "[SUCCESS] Azure Monitor alerts configured for: ${VM_NAME}"
echo "  Alerts sent to: ${ALERT_EMAIL}"
echo "  View: https://portal.azure.com/#view/Microsoft_Azure_Monitoring"
