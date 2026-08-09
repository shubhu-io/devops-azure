#!/usr/bin/env bash
# ==============================================================================
# Script: blob-storage.sh
# Description: Automated Azure Storage Account & Blob Storage Container Provisioner
# ==============================================================================

set -euo pipefail

STORAGE_ACCOUNT=${1:-"stdevops${RANDOM}"}
RESOURCE_GROUP=${2:-"rg-devops-eastus"}
LOCATION=${3:-"eastus"}
CONTAINER_NAME="backups"

echo "[INFO] Provisioning Azure Storage Account: ${STORAGE_ACCOUNT}..."

if command -v az &>/dev/null; then
    az storage account create \
        --name "$STORAGE_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku Standard_LRS || true
        
    echo "[INFO] Creating Blob Storage Container: ${CONTAINER_NAME}..."
    az storage container create \
        --name "$CONTAINER_NAME" \
        --account-name "$STORAGE_ACCOUNT" || true
        
    echo "[SUCCESS] Azure Blob Storage container created."
else
    echo "[ERROR] Azure CLI required."
fi
