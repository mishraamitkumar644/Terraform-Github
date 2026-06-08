# GitHub Secrets & Variables Setup Guide

This document explains exactly what goes where in GitHub for this pipeline to work.

---

## Overview

GitHub has two places to store configuration:
- **Secrets** → encrypted, never visible in logs → use for credentials
- **Variables** → visible in logs → use for non-sensitive config

The pipeline uses **GitHub Environments** (`dev`, `qa`, `prod`).
Each environment has its own secrets so credentials are isolated.

---

## Step 1 — Create GitHub Environments

Go to: `Repo → Settings → Environments → New environment`

Create three environments:
- `dev`
- `qa`
- `prod`

For `qa` and `prod`, add **Required reviewers** (manual approval gate).

---

## Step 2 — Secrets per Environment

Go to: `Settings → Environments → <env> → Add secret`

Add these **6 secrets** to EACH environment (`dev`, `qa`, `prod`):

| Secret Name | Description | Example Value |
|---|---|---|
| `AZURE_CLIENT_ID` | App Registration Client ID (OIDC) | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_TENANT_ID` | Azure AD Tenant ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_SUBSCRIPTION_ID` | Target Azure Subscription ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `TF_BACKEND_RESOURCE_GROUP` | RG where tfstate Storage Account lives | `rg-terraform-backend` |
| `TF_BACKEND_STORAGE_ACCOUNT` | Storage Account name for tfstate | `stterraformbackend001` |
| `TF_BACKEND_CONTAINER` | Blob container name for tfstate | `tfstate` |

> **Note:** Each environment can have a different Service Principal (Client ID).
> This is the recommended approach — dev SP has dev permissions, prod SP has prod permissions.

### How tfstate isolation works

The backend `key` is set dynamically per environment in the pipeline:
```
key = "<environment>/terraform.tfstate"
```
So in the same container you get:
```
tfstate/dev/terraform.tfstate
tfstate/qa/terraform.tfstate
tfstate/prod/terraform.tfstate
```
One storage account, three isolated state files.

---

## Step 3 — OIDC Federated Credential Setup (Azure side)

For EACH environment, configure a Federated Credential on the App Registration:

Go to: `Azure Portal → App Registrations → <your-app> → Certificates & secrets → Federated credentials → Add`

| Field | Value |
|---|---|
| Scenario | GitHub Actions |
| Organization | your-github-org |
| Repository | your-repo-name |
| Entity type | **Environment** |
| GitHub environment name | `dev` (or `qa` or `prod`) |
| Name | `github-actions-dev` |

> **Critical:** Entity type must be `Environment` (not Branch), because the workflows use `environment:` in jobs.

---

## Step 4 — Repository-level Secrets (optional, if shared across envs)

Go to: `Settings → Secrets and variables → Actions → New repository secret`

These are only needed if you have values shared across ALL environments:

| Secret Name | When to use |
|---|---|
| *(none required by default)* | All secrets are per-environment above |

---

## Step 5 — Repository Variables (non-sensitive config)

Go to: `Settings → Secrets and variables → Actions → Variables tab → New variable`

No repository variables are required by default. The `environment` input is passed at workflow dispatch time.

---

## Summary — What Goes Where

```
GitHub Environment: dev
├── Secret: AZURE_CLIENT_ID          → Dev Service Principal Client ID
├── Secret: AZURE_TENANT_ID          → Your Azure AD Tenant ID
├── Secret: AZURE_SUBSCRIPTION_ID    → Dev Subscription ID
├── Secret: TF_BACKEND_RESOURCE_GROUP → rg-terraform-backend
├── Secret: TF_BACKEND_STORAGE_ACCOUNT → stterraformbackend001
└── Secret: TF_BACKEND_CONTAINER     → tfstate

GitHub Environment: qa
├── Secret: AZURE_CLIENT_ID          → QA Service Principal Client ID
├── Secret: AZURE_TENANT_ID          → Your Azure AD Tenant ID
├── Secret: AZURE_SUBSCRIPTION_ID    → QA Subscription ID
├── Secret: TF_BACKEND_RESOURCE_GROUP → rg-terraform-backend
├── Secret: TF_BACKEND_STORAGE_ACCOUNT → stterraformbackend001
└── Secret: TF_BACKEND_CONTAINER     → tfstate

GitHub Environment: prod
├── Secret: AZURE_CLIENT_ID          → Prod Service Principal Client ID
├── Secret: AZURE_TENANT_ID          → Your Azure AD Tenant ID
├── Secret: AZURE_SUBSCRIPTION_ID    → Prod Subscription ID
├── Secret: TF_BACKEND_RESOURCE_GROUP → rg-terraform-backend
├── Secret: TF_BACKEND_STORAGE_ACCOUNT → stterraformbackend001
└── Secret: TF_BACKEND_CONTAINER     → tfstate
```

---

## Backend Storage Account Bootstrap

Before running the pipeline, you need the backend storage account (for tfstate) to already exist.

Create it once manually or via a bootstrap script:

```bash
# One-time bootstrap — run locally with your Azure CLI
az group create \
  --name rg-terraform-backend \
  --location eastus

az storage account create \
  --name stterraformbackend001 \
  --resource-group rg-terraform-backend \
  --location eastus \
  --sku Standard_LRS \
  --min-tls-version TLS1_2 \
  --https-only true

az storage container create \
  --name tfstate \
  --account-name stterraformbackend001 \
  --auth-mode login
```

Then assign your Service Principals **Storage Blob Data Contributor** role on this storage account.

---

## Triggering the Pipeline

Go to: `Actions → Terraform Enterprise Pipeline → Run workflow`

Select:
- **environment**: `dev` / `qa` / `prod`
- **working_directory**: `.` (default, or path to your Terraform root)

Apply only runs if triggered from `main` branch.
