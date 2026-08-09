#!/usr/bin/env bash
# ==============================================================================
# Script: acr-push.sh
# Description: Build, tag, and push Docker images to Azure Container Registry
# Usage: ./acr-push.sh [ACR_NAME] [IMAGE_NAME] [TAG] [DOCKERFILE_PATH]
# ==============================================================================

set -euo pipefail

ACR_NAME="${1:-devopsacr}"
IMAGE_NAME="${2:-myapp}"
TAG="${3:-latest}"
DOCKERFILE_PATH="${4:-.}"
FULL_IMAGE="${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${TAG}"

if ! command -v az &>/dev/null; then
  echo "[ERROR] Azure CLI (az) not found. Run ./setup.sh first."; exit 1
fi

if ! command -v docker &>/dev/null; then
  echo "[ERROR] Docker not found. Install Docker first."; exit 1
fi

echo "[INFO] Azure Container Registry: ${ACR_NAME}"
echo "[INFO] Target image: ${FULL_IMAGE}"

# ─── Login to ACR ─────────────────────────────────────────────────────────────
echo "[INFO] Logging in to ACR..."
az acr login --name "$ACR_NAME"

# ─── Build Image ──────────────────────────────────────────────────────────────
echo "[INFO] Building Docker image from: ${DOCKERFILE_PATH}..."
docker build \
  -t "$FULL_IMAGE" \
  -f "${DOCKERFILE_PATH}/Dockerfile" \
  "$DOCKERFILE_PATH"

echo "[INFO] Also tagging as 'latest'..."
docker tag "$FULL_IMAGE" "${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest"

# ─── Push Image ───────────────────────────────────────────────────────────────
echo "[INFO] Pushing ${FULL_IMAGE} to ACR..."
docker push "$FULL_IMAGE"
docker push "${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest"

# ─── Verify ───────────────────────────────────────────────────────────────────
echo ""
echo "[INFO] Listing images in ACR: ${ACR_NAME}..."
az acr repository show-tags \
  --name "$ACR_NAME" \
  --repository "$IMAGE_NAME" \
  --orderby time_desc \
  --output table 2>/dev/null || true

echo ""
echo "[SUCCESS] Image pushed successfully!"
echo "  Pull: docker pull ${FULL_IMAGE}"
echo "  Use in K8s: image: ${FULL_IMAGE}"
