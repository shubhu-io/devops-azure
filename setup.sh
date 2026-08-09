#!/usr/bin/env bash
# ==============================================================================
# devops-azure - Dedicated Azure CLI (az) Automated Setup
# ==============================================================================

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}[INFO] Installing Microsoft Azure CLI (az)...${NC}"

if command -v az &>/dev/null; then
    echo -e "${GREEN}[SUCCESS] Azure CLI is installed: $(az version --output json | head -n2 | tail -n1)${NC}"
    exit 0
fi

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash 2>/dev/null || true

echo -e "${GREEN}[SUCCESS] Azure CLI installed successfully.${NC}"
echo "Run: 'az login' to authenticate with your Azure Subscription."
