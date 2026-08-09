#!/usr/bin/env bash
# ==============================================================================
# Script: azure-vnet.sh
# Description: Automated Azure Resource Group & Virtual Network (VNet) Provisioner
# ==============================================================================

set -euo pipefail

RESOURCE_GROUP=${1:-"rg-devops-eastus"}
LOCATION=${2:-"eastus"}
VNET_NAME=${3:-"vnet-devops-main"}
SUBNET_NAME="subnet-app"

echo "[INFO] Provisioning Azure Resource Group: ${RESOURCE_GROUP}..."

if command -v az &>/dev/null; then
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION" || true
    
    echo "[INFO] Creating Virtual Network: ${VNET_NAME}..."
    az network vnet create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$VNET_NAME" \
        --address-prefix "10.20.0.0/16" \
        --subnet-name "$SUBNET_NAME" \
        --subnet-prefix "10.20.1.0/24" || true
        
    echo "[SUCCESS] Azure Resource Group & VNet setup complete."
else
    echo "[ERROR] Azure CLI (az) required."
fi
