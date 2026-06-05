# Terraform Enterprise CI/CD Pipeline — GitHub Actions

A complete, production-grade GitHub Actions pipeline for Terraform deployments to Azure
with OIDC authentication, policy-as-code (OPA), security scanning, and manual approvals.

---

## Pipeline Flow

```
workflow_dispatch (environment input)
        │
        ▼
[1] setup           → Install Terraform + Azure OIDC login
        │
        ▼
[2] init            → terraform init (environment-specific backend)
        │
        ▼
[3] validate        → terraform fmt -check + terraform validate
        │
    ┌───┴───────────────────┐
    ▼           ▼           ▼           ▼
[4a] tflint  [4b] tfsec  [4c] terrascan  [4d] terraform test
    └───┬───────────────────┘
        │ (all must pass)
        ▼
[5] plan            → terraform plan -out=tfplan  → upload artifact
        │
        ▼
[6] plan-to-json    → terraform show -json tfplan > tfplan.json → upload artifact
        │
        ▼
[7] opa             → opa eval data.terraform.deny  (fail on violations)
        │
        ▼
[8] publish         → Job summary + PR comment with plan & OPA results
        │
        ▼
[9] approval        → GitHub Environment required-reviewer gate (per env)
        │
        ▼
[10] download       → Download + verify approved tfplan artifact
        │
        ▼
[11] apply          → terraform apply tfplan  (ONLY on refs/heads/main)
```

---

## Repository Structure

```
.
├── .github/
│   ├── workflows/
│   │   └── terraform-ci-cd.yml        ← Main orchestrator (trigger here)
│   └── templates/
│       ├── setup-terraform.yml
│       ├── terraform-init.yml
│       ├── terraform-validate.yml
│       ├── tflint.yml
│       ├── tfsec.yml
│       ├── terrascan.yml
│       ├── terraform-test.yml
│       ├── terraform-plan.yml
│       ├── plan-to-json.yml
│       ├── opa-validation.yml
│       ├── publish-results.yml
│       ├── manual-approval.yml
│       ├── download-plan.yml
│       └── terraform-apply.yml
├── environments/
│   ├── dev.tfvars
│   ├── qa.tfvars
│   ├── preprod.tfvars
│   └── prod.tfvars
└── policies/
    └── terraform.rego               ← OPA policies (data.terraform.deny)
```

---

## GitHub Environments Setup

Create four GitHub Environments under **Settings → Environments**:

| Environment | Required Reviewers | Protection Rules |
|-------------|-------------------|-----------------|
| `dev`       | None (auto-approve) | — |
| `qa`        | 1 reviewer         | — |
| `preprod`   | 1 reviewer         | — |
| `prod`      | 2 reviewers        | Deployment branches: `main` only |

---

## Secrets — Per GitHub Environment

Each environment needs these secrets configured in **Settings → Environments → \<env\> → Secrets**:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | App Registration Client ID (OIDC) |
| `AZURE_TENANT_ID` | Azure Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Target Subscription ID |
| `TF_BACKEND_RESOURCE_GROUP` | Resource group containing the state storage account |
| `TF_BACKEND_STORAGE_ACCOUNT` | Storage account name for Terraform state |
| `TF_BACKEND_CONTAINER` | Blob container name for state files |

### Azure OIDC Setup

On your App Registration, add a **Federated Credential** for each environment:

```
Issuer:   https://token.actions.githubusercontent.com
Subject:  repo:<org>/<repo>:environment:<env-name>
Audience: api://AzureADTokenExchange
```

This enables passwordless authentication — no client secrets stored anywhere.

---

## OPA Policies

Create `policies/terraform.rego`:

```rego
package terraform

# deny contains msg if {
#   r := input.resource_changes[_]
#   r.type == "azurerm_storage_account"
#   r.change.after.enable_https_traffic_only == false
#   msg := sprintf("Storage account '%v' must enforce HTTPS", [r.address])
# }

deny contains msg if {
  r := input.resource_changes[_]
  r.change.actions[_] == "delete"
  r.type == "azurerm_key_vault"
  msg := sprintf("Deletion of Key Vault '%v' is not permitted via pipeline", [r.address])
}
```

---

## Environment-specific Variable Files

Create `environments/<env>.tfvars` for each environment:

```hcl
# environments/dev.tfvars
environment     = "dev"
location        = "eastus"
instance_count  = 1
sku             = "Standard_B2s"
```

---

## Triggering the Pipeline

1. Go to **Actions → Terraform Enterprise Pipeline → Run workflow**
2. Select the target **environment** (dev / qa / preprod / prod)
3. Optionally specify a `working_directory` if Terraform files are not in repo root
4. Click **Run workflow**

Apply will only execute automatically if the run was triggered from the `main` branch.
