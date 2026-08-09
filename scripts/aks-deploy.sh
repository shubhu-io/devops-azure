#!/usr/bin/env bash
# ==============================================================================
# Script: aks-deploy.sh
# Description: Create/manage an Azure Kubernetes Service (AKS) cluster
# Usage: ./aks-deploy.sh [ACTION] [CLUSTER_NAME] [RESOURCE_GROUP] [LOCATION]
#   ACTION: create | delete | credentials | status
# ==============================================================================

set -euo pipefail

ACTION="${1:-create}"
CLUSTER_NAME="${2:-devops-aks-cluster}"
RESOURCE_GROUP="${3:-rg-devops-eastus}"
LOCATION="${4:-eastus}"
NODE_COUNT="${5:-2}"
NODE_VM_SIZE="${6:-Standard_B2s}"
K8S_VERSION="${7:-1.29}"

if ! command -v az &>/dev/null; then
  echo "[ERROR] Azure CLI (az) not found. Run ./setup.sh first."; exit 1
fi

create_cluster() {
  echo "[INFO] Creating AKS Cluster: ${CLUSTER_NAME}..."
  echo "[INFO] Resource Group: ${RESOURCE_GROUP} | Location: ${LOCATION}"

  # Login check
  az account show &>/dev/null || { echo "[ERROR] Not logged in. Run: az login"; exit 1; }

  # Create Resource Group
  az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags "ManagedBy=devops-azure" "Environment=dev" \
    --output none

  echo "[INFO] Resource Group ready: ${RESOURCE_GROUP}"

  # Create AKS cluster
  az aks create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CLUSTER_NAME" \
    --location "$LOCATION" \
    --node-count "$NODE_COUNT" \
    --node-vm-size "$NODE_VM_SIZE" \
    --kubernetes-version "$K8S_VERSION" \
    --enable-managed-identity \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 5 \
    --network-plugin azure \
    --network-policy azure \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --tags "ManagedBy=devops-azure" "Environment=dev" \
    --output none

  get_credentials
  echo ""
  echo "[SUCCESS] AKS Cluster ${CLUSTER_NAME} ready!"
  echo "  Run: kubectl get nodes"
}

get_credentials() {
  echo "[INFO] Fetching kubeconfig for: ${CLUSTER_NAME}..."
  az aks get-credentials \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CLUSTER_NAME" \
    --overwrite-existing
  echo "[SUCCESS] kubeconfig updated. Context: ${CLUSTER_NAME}"
}

cluster_status() {
  echo "[INFO] Status of AKS Cluster: ${CLUSTER_NAME}..."
  az aks show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CLUSTER_NAME" \
    --query "{Name:name,State:provisioningState,KubeVersion:kubernetesVersion,NodeCount:agentPoolProfiles[0].count,FQDN:fqdn}" \
    --output table
  echo ""
  az aks nodepool list \
    --resource-group "$RESOURCE_GROUP" \
    --cluster-name "$CLUSTER_NAME" \
    --query "[*].{Name:name,Count:count,VMSize:vmSize,Mode:mode,State:provisioningState}" \
    --output table
}

delete_cluster() {
  echo "[WARN] Deleting AKS Cluster: ${CLUSTER_NAME}..."
  read -rp "Are you sure? Type 'yes' to confirm: " CONFIRM
  if [ "$CONFIRM" = "yes" ]; then
    az aks delete \
      --resource-group "$RESOURCE_GROUP" \
      --name "$CLUSTER_NAME" \
      --yes \
      --no-wait
    echo "[SUCCESS] Deletion initiated for: ${CLUSTER_NAME}"
  else
    echo "[ABORTED]"
  fi
}

case "$ACTION" in
  create)      create_cluster ;;
  credentials) get_credentials ;;
  status)      cluster_status ;;
  delete)      delete_cluster ;;
  *)
    echo "Usage: $0 {create|credentials|status|delete} [CLUSTER_NAME] [RG] [LOCATION]"
    exit 1
    ;;
esac
