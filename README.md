# Secure Hybrid DevOps (Azure)

This repo demonstrates a DevOps Engineer I skillset:
- IaC (Terraform) provisioning Azure resources (RG, ACR, AKS, VM)
- CI/CD (GitHub Actions) with security gates (pip-audit + Trivy)
- Container build/push to ACR
- Deploy to AKS (Kubernetes) + optional VM deployment (hybrid)
- Monitoring-ready app (/metrics) + health endpoint (/health)

## 1) Prereqs
- Azure CLI
- Terraform >= 1.6
- kubectl
- GitHub repo with Actions enabled

## 2) Provision Azure (Terraform)
From `terraform/`:

```bash
terraform init
terraform apply \
  -var="prefix=YOUR_PREFIX" \
  -var="location=eastus" \
  -var="admin_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"