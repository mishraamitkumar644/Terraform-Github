# Terraform Enterprise Pipeline — Azure

## Architecture
```
One Resource Group + One Storage Account per environment
Environments: dev | qa | prod
State: Separate tfstate per environment in Azure Blob Storage
Auth: OIDC (no long-lived secrets)
```

## Folder Structure
```
.
├── .github/workflows/          # 15 reusable workflow templates
├── environments/               # Per-env .tfvars files
│   ├── dev.tfvars
│   ├── qa.tfvars
│   └── prod.tfvars
├── modules/
│   ├── resource_group/         # azurerm_resource_group
│   └── storage_account/        # azurerm_storage_account (hardened)
├── policies/                   # OPA Rego policies
│   ├── azure_storage.rego      # D1-D6 deny + W1-W3 warn
│   └── azure_resource_group.rego # D7-D8 deny
├── tests/                      # Terraform native tests (.tftest.hcl)
├── main.tf
├── variables.tf
├── locals.tf
├── outputs.tf
└── .tflint.hcl
```

## Pipeline Flow
```
Setup → Init → Validate → [TFLint + TFSec + Terrascan + TF Test] → Plan
→ Plan-to-JSON → OPA → Publish → Manual Approval → Download → Apply
```

## GitHub Secrets & Variables Setup
See SECRETS_SETUP.md for detailed configuration per environment.
