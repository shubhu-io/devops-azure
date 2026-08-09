# 🔷 devops-azure — Microsoft Azure Execution Repository

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![CI](https://github.com/shubhu-io/devops-azure/actions/workflows/azure-ci.yml/badge.svg)](https://github.com/shubhu-io/devops-azure/actions/workflows/azure-ci.yml)
[![Learning Hub](https://img.shields.io/badge/DevOps-Learning%20Hub-blue.svg)](https://github.com/shubhu-io/devops-learning)

Production Microsoft Azure automation scripts covering Virtual Networks, AKS cluster management, Azure Container Registry, Blob Storage, and Azure Monitor alerting using the `az` CLI.

> 🚨 **Cost Alert**: AKS clusters incur Azure billing. Run `az group delete` or use `./uninstall.sh` when finished!

---

## ⚡ Quick Start

```bash
git clone https://github.com/shubhu-io/devops-azure.git
cd devops-azure
chmod +x setup.sh
./setup.sh              # Installs Azure CLI (az)
az login                # Authenticate with your Azure account
az account set --subscription YOUR_SUBSCRIPTION_ID
```

---

## 📂 Repository Structure

```
devops-azure/
├── setup.sh                         # Azure CLI installer
├── uninstall.sh                     # Remove Azure CLI
└── scripts/
    ├── azure-vnet.sh                # Create Resource Group & Virtual Network
    ├── blob-storage.sh              # Create Storage Account & Blob container
    ├── aks-deploy.sh                # Create/manage AKS Kubernetes cluster
    ├── acr-push.sh                  # Build & push Docker images to ACR
    └── azure-monitor.sh             # Set up VM CPU/memory/disk alerts
```

---

## 🛠️ Scripts Reference

| Script | Description | Usage |
|--------|-------------|-------|
| `azure-vnet.sh` | Create Resource Group + VNet + subnet | `./scripts/azure-vnet.sh rg-devops eastus vnet-main` |
| `blob-storage.sh` | Create Storage Account & Blob container | `./scripts/blob-storage.sh rg-devops eastus mystorageacct` |
| `aks-deploy.sh` | Create/delete/get-credentials AKS cluster | `./scripts/aks-deploy.sh create my-aks rg-devops eastus` |
| `acr-push.sh` | Build Docker image & push to ACR | `./scripts/acr-push.sh myregistry myapp latest .` |
| `azure-monitor.sh` | Create VM CPU/memory/disk alerts | `./scripts/azure-monitor.sh rg-devops my-vm alert@email.com` |

---

## 🔒 Security Best Practices

- Use **Managed Identity** for AKS — no service principal key files needed
- Enable **Azure Defender for Containers** on AKS clusters
- **NEVER** commit `az login` tokens or service principal credentials to Git
- Use **Azure Key Vault** for secrets management

---

## 📚 Learning Hub

For Azure architecture, ARM templates, VNet peering, and AKS theory, visit the [DevOps Learning Hub](https://github.com/shubhu-io/devops-learning).

---

## 📄 License

Licensed under [MIT](LICENSE).
